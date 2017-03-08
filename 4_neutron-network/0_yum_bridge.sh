#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set neutron network node work in bridge mode
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

####################################
#本机管理IP ，根据实际情况修改
my_ip=`crudini --get $setup_file cluster my_ip`

ext_intf=`crudini --get $setup_file cluster ext_intf`

vxlan_ip=`crudini --get $setup_file cluster vxlan_ip`

###################################


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
yum install  -y openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge python-neutronclient ebtables ipset 




log "configuration neutron"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config default"
crudini --set  /etc/neutron/neutron.conf DEFAULT rpc_backend  rabbit
crudini --set  /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set  /etc/neutron/neutron.conf DEFAULT service_plugins  router
crudini --set  /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips  True
crudini --set  /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes  True
crudini --set  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes  True
crudini --set  /etc/neutron/neutron.conf DEFAULT nova_url http://${controller_ip}:8774/v2 

crudini --set  /etc/neutron/neutron.conf DEFAULT verbose True

log "config database"
#[database]
crudini --set  /etc/neutron/neutron.conf database connection  mysql://neutron:${db_passwd}@${db_ip}/neutron

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

log "config nova"
#[nova]
crudini --set  /etc/neutron/neutron.conf nova auth_url  http://${controller_ip}:35357
crudini --set  /etc/neutron/neutron.conf nova auth_plugin  password
crudini --set  /etc/neutron/neutron.conf nova project_domain_id  default
crudini --set  /etc/neutron/neutron.conf nova user_domain_id  default
crudini --set  /etc/neutron/neutron.conf nova region_name  RegionOne
crudini --set  /etc/neutron/neutron.conf nova project_name  service
crudini --set  /etc/neutron/neutron.conf nova username  nova
crudini --set  /etc/neutron/neutron.conf nova password  ${nova_passwd}

log "config lock path"
crudini --set  /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

log "config ml2 plugin"

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
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini  securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

log "config l3_agent"
#/etc/neutron/l3_agent.ini 
#[DEFAULT]
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ""
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True

log "config dhcp_agent"
#/etc/neutron/dhcp_agent.ini
#[DEFAULT]
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata  True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file /etc/neutron/dnsmasq-neutron.conf
echo "dhcp-option-force=26,1450" > /etc/neutron/dnsmasq-neutron.conf


log "config metadata_agent"
#/etc/neutron/metadata_agent.ini
#[DEFAULT]
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_uri  http://${controller_ip}:5000
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_url  http://${controller_ip}:35357
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_region  RegionOne
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_plugin  password
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_domain_id  default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT user_domain_id  default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_name  service
crudini --set /etc/neutron/metadata_agent.ini DEFAULT username  neutron
crudini --set /etc/neutron/metadata_agent.ini DEFAULT password  $passwd

crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip  ${controller_ip}
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret  $meta_sec
crudini --set /etc/neutron/metadata_agent.ini DEFAULT verbose  True

log "start neutron-linuxbridge-agent dhcp-agent l3-agent metadata-agent service"

systemctl enable neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-l3-agent.service  neutron-metadata-agent.service
systemctl start neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-l3-agent.service  neutron-metadata-agent.service

systemctl status neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-l3-agent.service  neutron-metadata-agent.service


