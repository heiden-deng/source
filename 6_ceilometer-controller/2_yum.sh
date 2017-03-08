#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install ceilometer software && config ceilometer service
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

#############################################

#本机IP ，需要根据实际情况修改
my_ip=`crudini --get $setup_file cluster my_ip`

#############################################


mongodb_ip=`crudini --get $setup_file cluster mongodb_host`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

db_passwd=`crudini --get $setup_file ceilometer db_passwd`
passwd=`crudini --get $setup_file ceilometer service_passwd`

dbpath=`crudini --get $setup_file ceilometer dbpath`
time_to_live=`crudini --get $setup_file ceilometer time_to_live`

log "Install ceilometer software"
yum install  -y openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification openstack-ceilometer-central openstack-ceilometer-alarm python-ceilometerclient 




log "configuration ceilometer"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#/etc/ceilometer/ceilometer.conf
#[database]
crudini --set /etc/ceilometer/ceilometer.conf database connection  mongodb://ceilometer:${db_passwd}@${mongodb_ip}:27017/ceilometer
crudini --set /etc/ceilometer/ceilometer.conf database metering_time_to_live ${time_to_live} 
crudini --set /etc/ceilometer/ceilometer.conf database event_time_to_live ${time_to_live} 

#[DEFAULT]
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT verbose  True
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy  keystone

#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_host  $rabbit_ip
    crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
else
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi


#[keystone_authtoken]
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_plugin  password
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_domain_id  default
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken user_domain_id  default
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_name  service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken username  ceilometer
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken password  $passwd

#[service_credentials]
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url  http://${controller_ip}:5000/v2.0
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_username  ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name  service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_password  $passwd
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_endpoint_type  internalURL
crudini --set /etc/ceilometer/ceilometer.conf service_credentials os_region_name  RegionOne


if [ -f "/etc/mongod.conf" ];then
   log "config mongodb dbpath"
   sed_rep="s#^dbpath.*#dbpath = ${dbpath}#g"
   sed -i $sed_rep /etc/mongod.conf
   systemctl restart mongod.service
fi




log "start service"
systemctl enable openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service

systemctl start openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service

systemctl status openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service

