#!/bin/bash

db_host="192.168.1.211"
db_user="root"
db_passwd="123456"
db_name="cinder"
sv_user="cinder"
sv_passwd="Root1234"
controller_ip="192.168.1.211"

log()
{
   tag=`date`
   echo "[$tag] $1"
}

read -p "Are you sure to Reinit cinder,it will drop cinder DB(y/n):" bcontiune
if [ "x$bcontinue" == "xy" ];then
   echo "exit scirpt"
   exit 1
fi
source /root/admin-openrc

log "stop cinder service"

systemctl stop openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-backup.service

mysql -u$db_user -p$db_passwd -h $db_host -e "show databases" | grep $db_name
if [ $? -eq 0 ];then
  log "delete $db_name db"
  mysql -u$db_user -p$db_passwd -h $db_host  -e "drop database $db_name"
fi


log "init cinder db"
mysql -u$db_user -p$db_passwd -h $db_host  -e "CREATE DATABASE cinder"
mysql -u$db_user -p$db_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '123456'"
mysql -u$db_user -p$db_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%'  IDENTIFIED BY '123456'"

echo "Before delete service:"
openstack service list

for i in `openstack service list | grep cinder | awk '{print $2}'`;
do
    echo "delete service id=$i"
    openstack service delete $i
done

echo "after delete service:"
openstack service list


echo "create cinder service and user,endpoint"
source /root/admin-openrc
openstack user create --domain default --password ${sv_passwd} cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

openstack endpoint create --region RegionOne volume public http://${controller_ip}:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://${controller_ip}:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://${controller_ip}:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne volumev2 public http://${controller_ip}:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://${controller_ip}:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://${controller_ip}:8776/v2/%\(tenant_id\)s


log "install cinder component"
yum install -y openstack-cinder python-cinderclient


log "sync db "
su -s /bin/sh -c "cinder-manage db sync" cinder

#chmod a+w -R /var/nfs

log "start cinder service"
systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-backup.service 


log "setup cinder service finish"




