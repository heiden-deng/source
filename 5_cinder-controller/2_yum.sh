#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install software && config cinder api & scheduler
#
#  2016-06-17: create
#



script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh
setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

######################################

#本机IP ，需要根据实际情况进行修改
my_ip=`crudini --get $setup_file cluster my_ip`

######################################

db_passwd=`crudini --get $setup_file cinder db_passwd`

db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`
passwd=`crudini --get $setup_file cinder service_passwd`

log "Install cinder software"

yum install -y openstack-cinder python-cinderclient 


log "configuration cinder"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

log "config db"
#/etc/cinder/cinder.conf 
#[database]
crudini --set /etc/cinder/cinder.conf database connection  mysql://cinder:${db_passwd}@${db_ip}/cinder

log "config default"
#[DEFAULT]
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy  keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip  ${my_ip}
crudini --set /etc/cinder/cinder.conf DEFAULT verbose True

log "config rabbit"
#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host  ${rabbit_ip}
    crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}
else
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi

log "config keystone"
#[keystone_authtoken]
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id  default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id  default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  ${passwd}

log "config lock path"
#[oslo_concurrency]
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path  /var/lib/cinder/tmp

log "config nova"
#/etc/nova/nova.conf 
#[cinder]
crudini --set /etc/nova/nova.conf   cinder os_region_name  RegionOne



log "sync db"

su -s /bin/sh -c "cinder-manage db sync" cinder

log "restart nova-api"
systemctl restart openstack-nova-api.service

log "start service"
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service

systemctl status openstack-cinder-api.service openstack-cinder-scheduler.service



