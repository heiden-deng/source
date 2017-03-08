#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install glance software && config glance 
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

#controller服务器IP 
controller_ip=`crudini --get $setup_file cluster cluster_vip`

#数据库服务器IP
db_ip=`crudini --get $setup_file cluster db_ip`

#是否开启集群部署模式
cluster_on=`crudini --get $setup_file cluster cluster_on`


#rabbitmq服务IP
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`
rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`
rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

glance_db_passwd=`crudini --get $setup_file glance db_passwd`
glance_passwd=`crudini --get $setup_file glance service_passwd`


log "Install glance software"
yum install  -y openstack-glance python-glance python-glanceclient 



log "configuration glance"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi
crudini --set  /etc/glance/glance-api.conf database connection mysql://glance:${glance_db_passwd}@${db_ip}/glance

crudini --set  /etc/glance/glance-api.conf keystone_authtoken auth_uri http://${controller_ip}:5000
crudini --set  /etc/glance/glance-api.conf keystone_authtoken auth_url http://${controller_ip}:35357
crudini --set  /etc/glance/glance-api.conf keystone_authtoken auth_plugin password
crudini --set  /etc/glance/glance-api.conf keystone_authtoken project_domain_id default
crudini --set  /etc/glance/glance-api.conf keystone_authtoken user_domain_id default
crudini --set  /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set  /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set  /etc/glance/glance-api.conf keystone_authtoken password $glance_passwd

if [ "$cluster_on" == "0" ];then
    crudini --set  /etc/glance/glance-api.conf DEFAULT rpc_backend rabbit
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_host $rabbit_ip
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set  /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
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



crudini --set  /etc/glance/glance-api.conf paste_deploy flavor keystone


crudini --set  /etc/glance/glance-api.conf DEFAULT notification_driver noop

crudini --set  /etc/glance/glance-api.conf DEFAULT verbose True

#crudini --set  /etc/glance/glance-api.conf glance_store default_store file
#crudini --set  /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/


log "configuration glance-registry"
crudini --set  /etc/glance/glance-registry.conf database connection mysql://glance:${glance_db_passwd}@${db_ip}/glance

crudini --set  /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://${controller_ip}:5000
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken auth_url http://${controller_ip}:35357
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken auth_plugin password
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken project_domain_id default
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken user_domain_id default
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set  /etc/glance/glance-registry.conf keystone_authtoken password $glance_passwd

if [ "$cluster_on" == "0" ];then
    crudini --set  /etc/glance/glance-registry.conf DEFAULT rpc_backend rabbit
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_host $rabbit_ip
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set  /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
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



crudini --set  /etc/glance/glance-registry.conf paste_deploy flavor keystone
 

crudini --set  /etc/glance/glance-registry.conf DEFAULT notification_driver noop
crudini --set  /etc/glance/glance-registry.conf DEFAULT verbose True

#log "sync glance db"
#su -s /bin/sh -c "glance-manage db_sync" glance



#log "start glance service"
#systemctl enable openstack-glance-api.service openstack-glance-registry.service
#systemctl start openstack-glance-api.service openstack-glance-registry.service

#systemctl status openstack-glance-api.service openstack-glance-registry.service
