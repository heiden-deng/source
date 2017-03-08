#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script reset nova db & services
#
#  2016-06-14: create
#

script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh
setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#数据库服务器IP 
db_host=`crudini --get $setup_file cluster db_ip`

db_user=`crudini --get $setup_file cluster db_user`

db_root_passwd=`crudini --get $setup_file cluster db_root_passwd`

db_passwd=`crudini --get $setup_file nova db_passwd`

passwd=`crudini --get $setup_file nova service_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

db_name="nova"

#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

source /root/admin-openrc

read -p "Are you sure to Reinit nova,it will drop nova DB(y/n):" bcontinue
if [ "x$bcontinue" != "xy" ];then
   echo "exit scirpt"
   exit 1
fi

mysql -u$db_user -p$db_root_passwd -h $db_host -e "show databases" | grep $db_name
if [ $? -eq 0 ];then
  log "delete $db_name db"
  mysql -u$db_user -p$db_root_passwd -h $db_host  -e "drop database $db_name"
fi


log "init nova db"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "CREATE DATABASE nova"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '""$db_passwd""'"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%'  IDENTIFIED BY '""$db_passwd""'"

echo "Before delete service:"
openstack service list

for i in `openstack service list | grep nova | awk '{print $2}'`;
do
    echo "delete service id=$i"
    openstack service delete $i
done

echo "after delete service:"
openstack service list


echo "create nova service and user,endpoint"


openstack user create --domain default --password $passwd nova
openstack role add --project service --user nova admin
openstack service create --name nova  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://${controller_ip}:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://${controller_ip}:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://${controller_ip}:8774/v2/%\(tenant_id\)s



log "install nova component"
yum install -y openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient

log "sync db "
su -s /bin/sh -c "nova-manage db sync" nova


log "start nova service"
systemctl restart openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service 


log "setup nova service finish"




