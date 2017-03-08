#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config compute support ceilometer component 
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

controller_ip=`crudini --get $setup_file cluster cluster_vip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

passwd=`crudini --get $setup_file ceilometer service_passwd`

log "Install ceilometer software"
yum install  -y openstack-ceilometer-compute python-ceilometerclient python-pecan 



log "configuration ceilometer"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

#[DEFAULT]
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy  keystone
crudini --set /etc/ceilometer/ceilometer.conf DEFAULT verbose  True

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

log "config nova to use ceilometer"
#[DEFAULT]
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit  True
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period  hour
crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change  vm_and_task_state
crudini --set /etc/nova/nova.conf DEFAULT notification_driver  messagingv2

log "start ceilometer service"
systemctl enable openstack-ceilometer-compute.service
systemctl start openstack-ceilometer-compute.service

systemctl status openstack-ceilometer-compute.service


log "restart nova-compute service"
systemctl restart openstack-nova-compute.service


systemctl status openstack-nova-compute.service

