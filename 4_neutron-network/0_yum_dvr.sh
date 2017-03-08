#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set neutron network node work in dvr mode
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

###########################################

#本机管理IP 
my_ip=`crudini --get $setup_file cluster my_ip`

#本机tunnel IP
ovs_local_ip=`crudini --get $setup_file cluster ovs_local_ip`

###########################################

#数据库服务器IP
db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

#rabbitmq服务器IP 
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`
rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

#controller服务器IP 
controller_ip=`crudini --get $setup_file cluster cluster_vip`


db_passwd=`crudini --get $setup_file neutron db_passwd`
#neutron 服务用户密码
passwd=`crudini --get $setup_file neutron service_passwd`

nova_passwd=`crudini --get $setup_file nova service_passwd`

meta_sec=`crudini --get $setup_file cluster metadata_sec`


echo "********************************************************"
echo "********************************************************"
echo "Before run this script,You need config interface br-ex ip address and br-tun"
echo "********************************************************"
echo "********************************************************"



log "Install neutron software"
yum install  -y openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch python-neutronclient openstack-neutron-lbaas openstack-neutron-fwaas openstack-neutron-vpnaas haproxy openstack-neutron-metering-agent 

yum install -y libreswan ipsec-tools strongswan-libipsec


log "configuration neutron"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config default"
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes  True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes  True
crudini --set /etc/neutron/neutron.conf DEFAULT nova_url  http://${controller_ip}:8774/v2
crudini --set /etc/neutron/neutron.conf DEFAULT verbose  True
crudini --set /etc/neutron/neutron.conf DEFAULT router_distributed  True
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins  router,vpnaas,firewall,lbaas,qos,metering
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy  keystone
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips  True
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit

log "config database"
#[database]
crudini --set  /etc/neutron/neutron.conf database connection  mysql://neutron:${db_passwd}@${db_ip}/neutron

log "config rabbit"
#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host  ${rabbit_ip}
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}
else
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi


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

log "config qos"
crudini --set  /etc/neutron/neutron.conf qos notification_drivers message_queue 

log "config sysctl"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
sysctl -p

log "config ml2 plugin"
#crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup 
#[ml2]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  local,flat,vlan,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  vxlan,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  openvswitch,l2population

#[ml2_type_flat]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  external

#[ml2_type_vlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges external:10:1000

#[ml2_type_gre]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre tunnel_id_ranges 10:1000

#[ml2_type_vxlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges  10:1000
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vxlan_group  239.1.1.1
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan extension_drivers  port_security,qos

#[ovs]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip  $ovs_local_ip
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings  vxlan:br-tun,external:br-ex

#[agent]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types  gre,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent arp_responder  True

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group  True

#crudini --set /etc/neutron/l3_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge "" 
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT handle_internal_only_routers  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT send_arp_for_ha  3
crudini --set /etc/neutron/l3_agent.ini DEFAULT periodic_interval  40
crudini --set /etc/neutron/l3_agent.ini DEFAULT periodic_fuzzy_delay  5
crudini --set /etc/neutron/l3_agent.ini DEFAULT enable_metadata_proxy  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT router_delete_namespaces  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode  dvr_snat
#[AGENT]


#crudini --set /etc/neutron/dhcp_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver 
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver  neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata  True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT verbose  True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file  /etc/neutron/dnsmasq-neutron.conf
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT use_namespaces  True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_delete_namespaces  True
#[AGENT]

#/etc/neutron/dnsmasq-neutron.conf
echo "dhcp-option-force=26,1450" > /etc/neutron/dnsmasq-neutron.conf

log "config metadata_agent"
#crudini --set /etc/neutron/metadata_agent.ini DEFAULT 
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
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret $meta_sec
crudini --set /etc/neutron/metadata_agent.ini DEFAULT verbose  True

crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_tenant_name
crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_user
crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_password

#[AGENT]

log "config openvswitch agent"
#crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup 
#[ovs]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip  $my_ip
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings  external:br-ex

#[agent]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types  vxlan
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent arp_responder  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent enable_distributed_routing  True

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_security_group  True

#log "config nova"
#crudini --set /etc/nova/nova.conf neutron 
#[neutron]
#crudini --set /etc/nova/nova.conf neutron url  http://${controller_ip}:9696
#crudini --set /etc/nova/nova.conf neutron auth_url  http://${controller_ip}:35357
#crudini --set /etc/nova/nova.conf neutron auth_plugin  password
#crudini --set /etc/nova/nova.conf neutron project_domain_id  default 
#crudini --set /etc/nova/nova.conf neutron user_domain_id  default 
#crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
#crudini --set /etc/nova/nova.conf neutron project_name  service 
#crudini --set /etc/nova/nova.conf neutron username  neutron 
#crudini --set /etc/nova/nova.conf neutron password  $passwd

#crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  True
#crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret $meta_sec


log "config LBAAS"
#LBAAS
#crudini --set /etc/neutron/lbaas_agent.ini haproxy 
#[DEFAULT]
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT debug  True
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT device_driver  neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver
#[haproxy]
crudini --set /etc/neutron/lbaas_agent.ini haproxy user_group  haproxy

#crudini --set /etc/neutron/neutron_lbaas.conf service_providers
#[service_providers]
crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider  LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

log "config FWaaS"
#FWAAS
#crudini --set /etc/neutron/fwaas_driver.ini service_providers 
#[fwaas]
crudini --set /etc/neutron/fwaas_driver.ini fwaas driver  neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver
crudini --set /etc/neutron/fwaas_driver.ini fwaas enabled  True
#[service_providers]
crudini --set /etc/neutron/fwaas_driver.ini service_providers service_provider  FIREWALL:Iptables:neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver:default

log "config VPNaaS"
#VPNAAS
#crudini --set /etc/neutron/neutron_vpnaas.conf service_providers 
#[service_providers]
crudini --set /etc/neutron/neutron_vpnaas.conf service_providers service_provider  VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default

#crudini --set /etc/neutron/vpn_agent.ini ipsec 
#[vpnagent]
crudini --set /etc/neutron/vpn_agent.ini vpnagent vpn_device_driver  neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver
#[ipsec]
crudini --set /etc/neutron/vpn_agent.ini ipsec ipsec_status_check_interval  60


log "config metering"
#metering
#crudini --set /etc/neutron/metering_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/metering_agent.ini DEFAULT debug  True
crudini --set /etc/neutron/metering_agent.ini DEFAULT driver  neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver
crudini --set /etc/neutron/metering_agent.ini DEFAULT measure_interval  30
crudini --set /etc/neutron/metering_agent.ini DEFAULT report_interval  300   
crudini --set /etc/neutron/metering_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/metering_agent.ini DEFAULT use_namespaces  True


log "create plugin.ini link"
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

log "start neutron-openvswitch-agent dhcp-agent l3-agent metadata-agent lbaas fwaas vpnaas service"

systemctl enable openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service 
systemctl enable neutron-lbaas-agent.service 
#systemctl enable neutron-fwaas-agent.service  
systemctl enable neutron-vpn-agent.service 
systemctl enable neutron-metering-agent 


systemctl start openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service 
systemctl start neutron-lbaas-agent.service 
#systemctl start neutron-fwaas-agent.service  
systemctl start neutron-vpn-agent.service 
systemctl start neutron-metering-agent 



systemctl status openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service
systemctl status neutron-lbaas-agent.service 
#systemctl status neutron-fwaas-agent.service  
systemctl status neutron-vpn-agent.service 
systemctl status neutron-metering-agent 




