#!/bin/bash

controller_ip="192.168.10.128"
db_host="192.168.10.128"
db_user="root"
db_passwd="123456"
admin_token=05551d2f909c8ab156ef


log()
{
   tag=`date`
   echo "[$tag] $1"
}

read -p "Are you sure to Reinit KEYSTONE,it will drop all DB(y/n):" bcontiune
if [ "x$bcontinue" == "xy" ];then
   echo "exit scirpt"
   exit 1
fi

mysql -uroot -p123456 -h hv156 -e "show databases" | grep keystone
if [ $? -eq 0 ];then
  log "delete keystone db"
  mysql -uroot -p123456 -h hv156 -e "drop database keystone"
fi


log "init keystone db"
mysql -uroot -p123456 -h hv156 -e "CREATE DATABASE keystone"
mysql -uroot -p123456 -h hv156 -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '123456'"
mysql -uroot -p123456 -h hv156 -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'  IDENTIFIED BY '123456'"

log "install keystone component"

yum install -y openstack-keystone httpd mod_wsgi memcached python-memcached
#systemctl enable memcached.service
systemctl start memcached.service

log "sync db"
su -s /bin/sh -c "keystone-manage db_sync" keystone

log "start keystone service(httpd)"
systemctl restart httpd.service

log "wait 5s"
sleep 5
log "create keystone service,users,endpoint"

export OS_TOKEN=$admin_token
export OS_URL=http://${controller_ip}:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack service create  --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://${controller_ip}:5000/v2.0
openstack endpoint create --region RegionOne  identity internal http://${controller_ip}:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://${controller_ip}:35357/v2.0

openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default  --password 123456 admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default  --description "Service Project" service
openstack project create --domain default  --description "Demo Project" demo

openstack user create --domain default --password 123456 demo
openstack role create user
openstack role add --project demo --user demo user

log "setup keystone service finish"




