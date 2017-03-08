#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install,config nova-compute for compute node
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

############################################

#本机管理IP,
my_ip=`crudini --get $setup_file cluster my_ip`

###########################################



#controller服务器IP 
controller_ip=`crudini --get $setup_file cluster cluster_vip`

#数据库服务器IP 
db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

#rabbitmq服务器IP 
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

db_passwd=`crudini --get $setup_file nova db_passwd`

passwd=`crudini --get $setup_file nova service_passwd`

log "Install nova compute software"
yum install  -y openstack-nova-compute sysfsutils 




log "configuration nova"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config default"

crudini --set  /etc/nova/nova.conf  DEFAULT rpc_backend  rabbit
crudini --set  /etc/nova/nova.conf  DEFAULT auth_strategy  keystone
crudini --set  /etc/nova/nova.conf  DEFAULT my_ip  $my_ip
crudini --set  /etc/nova/nova.conf  DEFAULT use_neutron  True
crudini --set  /etc/nova/nova.conf  DEFAULT verbose True

log "config rabbit"
if [ "$cluster_on" == "0" ];then
    crudini --set  /etc/nova/nova.conf  oslo_messaging_rabbit rabbit_host  ${rabbit_ip}
    crudini --set  /etc/nova/nova.conf  oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set  /etc/nova/nova.conf  oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}
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
crudini --set  /etc/nova/nova.conf  keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set  /etc/nova/nova.conf  keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set  /etc/nova/nova.conf  keystone_authtoken auth_plugin  password
crudini --set  /etc/nova/nova.conf  keystone_authtoken project_domain_id  default
crudini --set  /etc/nova/nova.conf  keystone_authtoken user_domain_id  default
crudini --set  /etc/nova/nova.conf  keystone_authtoken project_name  service
crudini --set  /etc/nova/nova.conf  keystone_authtoken username  nova
crudini --set  /etc/nova/nova.conf  keystone_authtoken password  ${passwd}

log "config nova use neutron"
crudini --set  /etc/nova/nova.conf DEFAULT network_api_class  nova.network.neutronv2.api.API 
crudini --set  /etc/nova/nova.conf DEFAULT security_group_api  neutron
crudini --set  /etc/nova/nova.conf DEFAULT linuxnet_interface_driver  nova.network.linux_net.LinuxOVSInterfaceDriver
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver

log "config vnc"
crudini --set  /etc/nova/nova.conf  vnc enabled  True
crudini --set  /etc/nova/nova.conf  vnc vncserver_listen  0.0.0.0
crudini --set  /etc/nova/nova.conf  vnc vncserver_proxyclient_address  "\$my_ip"
crudini --set  /etc/nova/nova.conf  vnc novncproxy_base_url  http://${controller_ip}:6080/vnc_auto.html

log "config glance"
crudini --set  /etc/nova/nova.conf  glance host ${controller_ip}


log "config lock path"
crudini --set  /etc/nova/nova.conf  oslo_concurrency lock_path  /var/lib/nova/tmp

log "config libvirtd"
sed -i "s/#LIBVIRTD_ARGS=\"--listen\"/LIBVIRTD_ARGS=\"--listen\"/g"  /etc/sysconfig/libvirtd

sed -i "s/#listen_tcp = 1/listen_tcp = 1/g" /etc/libvirt/libvirtd.conf
sed -i "s/#listen_tls = 0/listen_tls = 0/g" /etc/libvirt/libvirtd.conf
sed -i "s/#auth_tcp = \"sasl\"/auth_tcp = \"none\"/g" /etc/libvirt/libvirtd.conf


log "start service.."

systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service

systemctl status libvirtd.service openstack-nova-compute.service


log "****************************************************"
echo ""
echo ""
log "You Should config nova user visit without password between compute host"
echo ""
echo ""
log "****************************************************"

