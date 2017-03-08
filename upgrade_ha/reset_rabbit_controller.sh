#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install glance software && config glance 
#
#  2016-06-17: create
#



#script_name="$0"
#script_dir=`dirname $script_name`
#source ${script_dir}/../common/func.sh
#setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

#rabbit服务器IP 
rabbit_host="192.168.1.211"
rabbit_passwd="123456"

echo "update glance"
cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak  
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_retry_interval
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_retry_backoff
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_max_retries
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_ha_queues 
crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --sel  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_host $rabbit_host

cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak  
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_retry_interval  
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_retry_backoff
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_max_retries
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_ha_queues
crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_host $rabbit_host


echo "update nova"
cp /etc/nova/nova.conf /etc/nova/nova.conf.bak  
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_retry_interval 
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_retry_backoff
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_max_retries
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_ha_queues 
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $rabbit_host

echo "update neutron"
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak  
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_interval  
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_backoff
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_max_retries 
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_ha_queues
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $rabbit_host

echo "update cinder"
cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak  
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_interval
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_backoff
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_max_retries
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_ha_queues 
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $rabbit_host


echo "update ceilometer"
cp /etc/ceilometer/ceilometer.conf /etc/ceilometer/ceilometer.conf.bak  
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_hosts
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_retry_interval   
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_retry_backoff 
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_max_retries 
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_durable_queues
crudini --del  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_ha_queues
crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
crudini --set  /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_host $rabbit_host


echo "finished"



