#!/bin/bash

db_host="192.168.1.211"
db_user="root"
db_passwd="123456"
db_name="glance"
sv_user="glance"
sv_passwd="Root1234"
controller_ip="192.168.1.211"
log()
{
   tag=`date`
   echo "[$tag] $1"
}

read -p "Are you sure to Reinit glance,it will drop glance DB(y/n):" bcontiune
if [ "x$bcontinue" == "xy" ];then
   echo "exit scirpt"
   exit 1
fi

mysql -u$db_user -p$db_passwd -h $db_host -e "show databases" | grep $db_name
if [ $? -eq 0 ];then
  log "delete $db_name db"
  mysql -u$db_user -p$db_passwd -h $db_host  -e "drop database $db_name"
fi


log "init glance db"
mysql -u$db_user -p$db_passwd -h $db_host  -e "CREATE DATABASE glance"
mysql -u$db_user -p$db_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '123456'"
mysql -u$db_user -p$db_passwd -h $db_host  -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%'  IDENTIFIED BY '123456'"

echo "Before delete service:"
openstack service list

for i in `openstack service list | grep glance | awk '{print $2}'`;
do
    echo "delete service id=$i"
    openstack service delete $i
done

echo "after delete service:"
openstack service list


echo "create glance service and user,endpoint"
source admin-openrc
openstack user create --domain default --password ${sv_passwd} glance
openstack role add --project service --user glance admin

openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://${controller_ip}:9292
openstack endpoint create --region RegionOne image internal http://${controller_ip}:9292
openstack endpoint create --region RegionOne image admin http://${controller_ip}:9292



log "install glance component"
yum install -y openstack-glance python-glance python-glanceclient

log "sync db "
su -s /bin/sh -c "glance-manage db_sync" glance

log "start glance service"
systemctl restart openstack-glance-api.service openstack-glance-registry.service


log "setup glance service finish"




