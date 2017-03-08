#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config glance use ceilometer 
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

db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`


glance_db_passwd=`crudini --get $setup_file glance db_passwd`
glance_passwd=`crudini --get $setup_file glance service_passwd`



log "configuration glance support ceilometer"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

#[DEFAULT]
crudini --set /etc/glance/glance-api.conf DEFAULT notification_driver  messagingv2
crudini --set /etc/glance/glance-api.conf DEFAULT rpc_backend  rabbit

#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_host  $rabbit_ip
    crudini --set /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
else
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi

#[DEFAULT]
#crudini --set /etc/glance/glance-registry.conf 
crudini --set /etc/glance/glance-registry.conf DEFAULT notification_driver  messagingv2
crudini --set /etc/glance/glance-registry.conf DEFAULT rpc_backend  rabbit

#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_host  $rabbit_ip
    crudini --set /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
else
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi

systemctl restart openstack-glance-api.service openstack-glance-registry.service

systemctl status openstack-glance-api.service openstack-glance-registry.service
