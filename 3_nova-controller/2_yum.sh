#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install nova software && config nova service
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
#本机管理IP

my_ip=`crudini --get $setup_file cluster  my_ip`

#####################################




#数据库服务器IP 
db_ip=`crudini --get $setup_file cluster db_ip`

#controller服务器IP 
controller_ip=`crudini --get $setup_file cluster cluster_vip`

#rabbitmq服务器IP 
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

db_passwd=`crudini --get $setup_file nova db_passwd`

passwd=`crudini --get $setup_file nova service_passwd`


log "Install nova software"
yum install  -y openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient 




log "configuration nova"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config default"
crudini --set  /etc/nova/nova.conf  DEFAULT enabled_apis  osapi_compute,metadata
crudini --set  /etc/nova/nova.conf DEFAULT rpc_backend  rabbit
crudini --set  /etc/nova/nova.conf DEFAULT auth_strategy  keystone
crudini --set  /etc/nova/nova.conf DEFAULT my_ip  $my_ip
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron  True

log "config database"
crudini --set  /etc/nova/nova.conf database connection  mysql://nova:${db_passwd}@${db_ip}/nova

log "config rabbit"
if [ "$cluster_on" == "0" ];then
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host  $rabbit_ip
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}
else
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi

log "config keystone"
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_plugin  password
crudini --set  /etc/nova/nova.conf keystone_authtoken project_domain_id  default
crudini --set  /etc/nova/nova.conf keystone_authtoken user_domain_id  default
crudini --set  /etc/nova/nova.conf keystone_authtoken project_name  service
crudini --set  /etc/nova/nova.conf keystone_authtoken username  nova
crudini --set  /etc/nova/nova.conf keystone_authtoken password  $passwd


log "config nova use neutron"
crudini --set  /etc/nova/nova.conf DEFAULT network_api_class  nova.network.neutronv2.api.API
crudini --set  /etc/nova/nova.conf DEFAULT security_group_api  neutron
crudini --set  /etc/nova/nova.conf DEFAULT linuxnet_interface_driver  nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver

log "config vnc"
crudini --set  /etc/nova/nova.conf vnc vncserver_listen  "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address  "\$my_ip"

log "config glance api"
crudini --set  /etc/nova/nova.conf glance host  ${controller_ip}

log "config lock path"
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path  /var/lib/nova/tmp

log "sync db"

su -s /bin/sh -c "nova-manage db sync" nova



log "start service"
systemctl enable openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start  openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service


systemctl status openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service


