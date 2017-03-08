#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install software && config  neutron,
#  It will set neutron in dvr mode
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

##########################################

#数据库服务器IP 
db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

#rabbitmq服务IP 
rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`
rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

#controller服务器IP 
controller_ip=`crudini --get $setup_file cluster cluster_vip`

db_passwd=`crudini --get $setup_file neutron db_passwd`


#本类型服务的密码，在创建服务用户时设置
passwd=`crudini --get $setup_file neutron service_passwd`

nova_passwd=`crudini --get $setup_file nova service_passwd`

meta_sec=`crudini --get $setup_file cluster metadata_sec`

log "Install neutron software"
yum install  -y openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch python-neutronclient openstack-neutron-lbaas openstack-neutron-fwaas openstack-neutron-vpnaas haproxy openstack-neutron-metering-agent



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
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router,vpnaas,firewall,lbaas,qos,metering
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

log "config sysctl"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
sysctl -p


log "config ml2 plugin"

#config ml2.ini

#[ml2]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  local,flat,vxlan,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  vxlan,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  openvswitch,l2population 
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security

#[ml2_type_flat]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  external

#[ml2_type_vlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges  external:10:1000

#[ml2_type_gre]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre tunnel_id_ranges 10:1000 


#[ml2_type_vxlan]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges  10:1000
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vxlan_group  239.1.1.1
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan extension_drivers  port_security,qos

#[agent]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types  gre,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent arp_responder  True

#[securitygroup]
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver   neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group  True


log "config nova"
#config /etc/nova/nova.conf
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver  nova.network.linux_net.LinuxOVSInterfaceDriver
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

crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  True

crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  $meta_sec

log "config lbaas"
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



log "create ml2 plugin link"
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini



log "sync db"
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

log "restart nova-api service"
systemctl restart openstack-nova-api.service
systemctl status openstack-nova-api.service

log "start neutron-server service"


systemctl enable neutron-server.service
systemctl start neutron-server.service
systemctl status neutron-server.service

systemctl disable neutron-metadata-agent neutron-dhcp-agent neutron-openvswitch-agent neutron-metering-agent neutron-l3-agent
systemctl stop neutron-metadata-agent neutron-dhcp-agent neutron-openvswitch-agent neutron-metering-agent neutron-l3-agent

