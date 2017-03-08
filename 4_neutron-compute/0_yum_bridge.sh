#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set compute node to neutron bridge mode
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

##############################################
#本机管理IP ，需要根据实际情况修改
my_ip=`crudini --get $setup_file cluster my_ip`

ext_intf=`crudini --get $setup_file cluster ext_intf`

vxlan_ip=`crudini --get $setup_file cluster vxlan_ip`

##############################################


db_passwd=`crudini --get $setup_file neutron db_passwd`

db_ip=`crudini --get $setup_file cluster db_ip`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

passwd=`crudini --get $setup_file neutron service_passwd`

nova_passwd=`crudini --get $setup_file nova service_passwd`

meta_sec=`crudini --get $setup_file cluster metadata_sec`


echo "********************************************************"
echo "********************************************************"
echo "Before exe this script,You need config interface $ext_intf ip address to $vxlan_ip"
echo "********************************************************"
echo "********************************************************"

log "Install neutron software"
yum install  -y openstack-neutron openstack-neutron-linuxbridge ebtables ipset 




log "configuration neutron"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config default"
crudini --set  /etc/neutron/neutron.conf DEFAULT rpc_backend  rabbit
crudini --set  /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set  /etc/neutron/neutron.conf DEFAULT verbose True


log "config rabbit"
#[oslo_messaging_rabbit]
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host  ${rabbit_ip}
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid  openstack
crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}

log "config keystone"
#[keystone_authtoken]
crudini --set  /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set  /etc/neutron/neutron.conf keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set  /etc/neutron/neutron.conf keystone_authtoken auth_plugin  password
crudini --set  /etc/neutron/neutron.conf keystone_authtoken project_domain_id  default
crudini --set  /etc/neutron/neutron.conf keystone_authtoken user_domain_id  default
crudini --set  /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set  /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set  /etc/neutron/neutron.conf keystone_authtoken password  ${passwd}

log "config lock path"
crudini --set  /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp


#config ml2.ini

#[ml2]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vxlan,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  vxlan,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security

#[ml2_type_flat]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  external

#[ml2_type_vlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges  external,vlan:10:1000

#[ml2_type_vxlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges  10:1000

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver  iptables
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group  True


log "create ml2 plugin link"
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

log "config linuxbridge_agent"

#/etc/neutron/plugins/ml2/linuxbridge_agent.ini
#[linux_bridge]
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  external:${ext_intf}

#[vxlan]
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  vxlan enable_vxlan  True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  vxlan local_ip  ${vxlan_ip}
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  vxlan l2_population  True

#[agent]
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  agent prevent_arp_spoofing True

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  securitygroup enable_security_group  True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  securitygroup firewall_driver iptables 

#log "config l3_agent"
#/etc/neutron/l3_agent.ini 
#[DEFAULT]
#crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.BridgeInterfaceDriver
#crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge 

#log "config dhcp_agent"
#/etc/neutron/dhcp_agent.ini
#[DEFAULT]
#crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.BridgeInterfaceDriver
#crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
#crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata  True

#log "config metadata_agent"
#/etc/neutron/metadata_agent.ini
#[DEFAULT]
#crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip  controller
#crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret  $meta_sec

#neutron compute
#/etc/nova/nova.conf
#[neutron]
crudini --set /etc/nova/nova.conf neutron url  http://${controller_ip}:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://${controller_ip}:35357
crudini --set /etc/nova/nova.conf neutron auth_plugin  password
crudini --set /etc/nova/nova.conf neutron project_domain_id  default
crudini --set /etc/nova/nova.conf neutron user_domain_id  default
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  ${passwd}

crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver  nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver

log "restart openstack-nova-compute.service"
systemctl restart openstack-nova-compute.service

log "start neutron-linuxbridge-agent"

systemctl enable neutron-linuxbridge-agent.service
systemctl start neutron-linuxbridge-agent.service

systemctl status neutron-linuxbridge-agent.service


