#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set compute node to neutron dvr mode
#
#  2016-06-18: create
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

#############################################################

#本机ip
my_ip=`crudini --get $setup_file cluster my_ip`

#本机使用的tunnel ip,通常设置最后一个和服务器ip相同
ovs_local_ip=`crudini --get $setup_file cluster ovs_local_ip`

###############################################################


#数据库服务器ip
db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

#rabbitmq服务器Ip 
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

#controller服务器ip
controller_ip=`crudini --get $setup_file cluster cluster_vip`

#neutron数据库neutorn用户密码
db_passwd=`crudini --get $setup_file neutron db_passwd`

#neutron服务用户密码
passwd=`crudini --get $setup_file neutron service_passwd`

nova_passwd=`crudini --get $setup_file nova service_passwd`

meta_sec=`crudini --get $setup_file cluster metadata_sec`





echo "********************************************************"
echo "********************************************************"
echo "Before run this script,You need config interface br-ex ip and br-tun"
echo "********************************************************"
echo "********************************************************"

log "Install neutron software"
yum install  -y openstack-neutron openstack-neutron-openvswitch openstack-neutron-ml2 ebtables ipset openstack-neutron-fwaas openstack-neutron-metering-agent 



log "configuration neutron"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

log "config DEFAULT"
#network node
#crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit 
#[DEFAULT]
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins  router,firewall,metering

log "config keystone"
#[keystone_authtoken]
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_plugin  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_id  default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_id  default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $passwd

#[oslo_concurrency]
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

log "config rabbit"
#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host  $rabbit_ip
    crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password  $rabbit_passwd
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


log "config nova"
#crudini --set /etc/nova/nova.conf DEFAULT 
#[neutron]
crudini --set /etc/nova/nova.conf neutron url  http://${controller_ip}:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://${controller_ip}:35357
crudini --set /etc/nova/nova.conf neutron auth_plugin  password
crudini --set /etc/nova/nova.conf neutron project_domain_id  default
crudini --set /etc/nova/nova.conf neutron user_domain_id  default
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  $passwd

#[DEFAULT]
crudini --set /etc/nova/nova.conf DEFAULT network_api_class  nova.network.neutronv2.api.API
crudini --set /etc/nova/nova.conf DEFAULT security_group_api  neutron
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver  nova.network.linux_net.LinuxOVSInterfaceDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver

#/etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
systemctl start firewalld
sysctl -p
systemctl stop firewalld

log "config ml2"
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
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan extension_drivers  port_security

#[ovs]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip $ovs_local_ip
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings  vxlan:br-tun,external:br-ex

#[agent]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types  gre,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent arp_responder  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent extensions qos

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group  True


log "config l3_agent"
#crudini --set /etc/neutron/l3_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge  
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode  dvr
crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces  True
crudini --set /etc/neutron/l3_agent.ini DEFAULT router_delete_namespaces  True

log "config metadata_agent"
#crudini --set /etc/neutron/metadata_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/metadata_agent.ini DEFAULT debug  True
crudini --set /etc/neutron/metadata_agent.ini DEFAULT verbose  True
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

crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_tenant_name
crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_user
crudini --del /etc/neutron/metadata_agent.ini DEFAULT admin_password

log "config openvswitch agent"
#crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup 
#[ovs]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip  $my_ip
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings  external:br-ex

#[agent]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types  vxlan
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent enable_distributed_routing  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent arp_responder  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing  True

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_security_group  True


log "config fwaas agent"
#crudini --set /etc/neutron/fwaas_driver.ini service_providers 
#[fwaas]
crudini --set /etc/neutron/fwaas_driver.ini fwaas driver  neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver
crudini --set /etc/neutron/fwaas_driver.ini fwaas enabled  True

#[service_providers]
crudini --set /etc/neutron/fwaas_driver.ini service_providers service_provider  FIREWALL:Iptables:neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver:default


log "config metering agent"
#crudini --set /etc/neutron/metering_agent.ini DEFAULT 
#[DEFAULT]
crudini --set /etc/neutron/metering_agent.ini DEFAULT debug  True
crudini --set /etc/neutron/metering_agent.ini DEFAULT driver  neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver
crudini --set /etc/neutron/metering_agent.ini DEFAULT measure_interval  30
crudini --set /etc/neutron/metering_agent.ini DEFAULT report_interval  300   
crudini --set /etc/neutron/metering_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/metering_agent.ini DEFAULT use_namespaces  True

log "create plugin.ini"
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

log "restart openstack-nova-compute.service"
systemctl restart openstack-nova-compute.service

log "start openvswitch neutron-openvswitch-agent neutron-metadata-agent neutron-l3-agent neutron-metering-agent"

systemctl enable openvswitch.service neutron-openvswitch-agent.service  neutron-metadata-agent.service neutron-l3-agent.service neutron-metering-agent
#neutron-fwaas-agent.service 

systemctl start openvswitch.service neutron-openvswitch-agent.service  neutron-metadata-agent.service neutron-l3-agent.service neutron-metering-agent
#neutron-fwaas-agent.service 

systemctl status openvswitch.service neutron-openvswitch-agent.service  neutron-metadata-agent.service neutron-l3-agent.service neutron-metering-agent
#neutron-fwaas-agent.service 



