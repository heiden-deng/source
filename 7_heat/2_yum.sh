#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install heat software && config heat 
#
#  2016-10-25: create
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

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

#rabbitmq服务IP
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`
rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

heat_db_passwd=`crudini --get $setup_file heat db_passwd`
heat_passwd=`crudini --get $setup_file heat service_passwd`
heat_domain_admin_passwd=`crudini --get $setup_file heat heat_domain_admin_passwd`


log "Install heat software"
yum install  -y openstack-heat-api openstack-heat-api-cfn openstack-heat-engine python-heatclient 



log "configuration heat"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "configuration heat"
#[database]
crudini --set /etc/heat/heat.conf database connection  mysql://heat:${heat_db_passwd}@${db_ip}/heat

#[DEFAULT]
crudini --set /etc/heat/heat.conf DEFAULT rpc_backend   rabbit
crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url   http://${controller_ip}:8000
crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url   http://${controller_ip}:8000/v1/waitcondition

crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin   heat_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password   ${heat_domain_admin_passwd}
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name   heat

crudini --set /etc/heat/heat.conf DEFAULT verbose   True

#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_host   ${rabbit_ip}
    crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_userid   openstack
    crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_password ${rabbit_passwd}
else
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/heat/heat.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi


#[keystone_authtoken]
crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri   http://${controller_ip}:5000
crudini --set /etc/heat/heat.conf keystone_authtoken auth_url   http://${controller_ip}:35357
crudini --set /etc/heat/heat.conf keystone_authtoken auth_plugin   password
crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_id   default
crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_id   default
crudini --set /etc/heat/heat.conf keystone_authtoken project_name   service
crudini --set /etc/heat/heat.conf keystone_authtoken username   heat
crudini --set /etc/heat/heat.conf keystone_authtoken password   ${heat_passwd}

#[trustee]
crudini --set /etc/heat/heat.conf trustee auth_plugin   password
crudini --set /etc/heat/heat.conf trustee auth_url   http://${controller_ip}:35357
crudini --set /etc/heat/heat.conf trustee username   heat
crudini --set /etc/heat/heat.conf trustee password   ${heat_passwd}
crudini --set /etc/heat/heat.conf trustee user_domain_id   default

#[clients_keystone]
crudini --set /etc/heat/heat.conf clients_keystone auth_uri   http://${controller_ip}:5000

#[ec2authtoken]
crudini --set /etc/heat/heat.conf ec2authtoken auth_uri   http://${controller_ip}:5000/v3



#log "sync heat db"
su -s /bin/sh -c "heat-manage db_sync" heat


#log "start heat service"
systemctl enable openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service
systemctl start openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service

systemctl status openstack-heat-api.service openstack-heat-api-cfn.service openstack-heat-engine.service
