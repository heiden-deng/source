#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script reset neutron db & services
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

db_passwd=`crudini --get $setup_file neutron db_passwd`

passwd=`crudini --get $setup_file neutron service_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

db_name="neutron"

source /root/admin-openrc
#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

read -p "Are you sure to Reinit neutron,it will drop neutron DB(y/n):" bcontinue
if [ "x$bcontinue" != "xy" ];then
   echo "exit scirpt"
   exit 1
fi

echo "Before delete service:"
openstack service list

for i in `openstack service list | grep neutron | awk '{print $2}'`;
do
    echo "delete service id=$i"
    openstack service delete $i
done

echo "after delete service:"
openstack service list



mysql -u$db_user -p$db_root_passwd -h $db_host -e "show databases" | grep $db_name
if [ $? -eq 0 ];then
  log "delete $db_name db"
  mysql -u$db_user -p$db_root_passwd -h $db_host  -e "drop database $db_name"
fi


log "init neutron db"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "CREATE DATABASE neutron"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '""$db_passwd""'"
mysql -u$db_user -p$db_root_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%'  IDENTIFIED BY '""$db_passwd""'"


echo "create neutron service and user,endpoint"

openstack user create --domain default --password $passwd neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://${controller_ip}:9696
openstack endpoint create --region RegionOne network internal http://${controller_ip}:9696
openstack endpoint create --region RegionOne network admin http://${controller_ip}:9696


log "create link file"
if [ ! -e "/etc/neutron/plugin.ini" ];then
   ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
fi

log "sync db "
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

log "start neutron service"
systemctl restart neutron-server.service 
#systemctl restart neutron-server.service openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service  


log "setup neutron service finish"




