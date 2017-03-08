#!/bin/sh
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config BeyondStack Cluster with Ceph Storage
#
#  2016-11-29: create

script_name="$0"
script_dir=`dirname $script_name`
setup_file="/etc/bocloud/env_ha_cfg.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log()
{
   tag=`date`
   echo "[$tag] $1"
}

op_user=`crudini --get $setup_file global op_user`
op_passwd=`crudini --get $setup_file global op_passwd`
cluster_vip=`crudini --get $setup_file global cluster_vip`


# 环境变量
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=$op_user
export OS_PASSWORD=$op_passwd
export OS_AUTH_URL=http://${cluster_vip}:5000/v2.0
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


# 定义controller节点的impi stonith设备
controller_hosts=`crudini --get $setup_file global controller_hosts`
controller_ipmi_ips=`crudini --get $setup_file global controller_ipmi_ips`
controller_ipmi_users=`crudini --get $setup_file global controller_ipmi_users`
controller_ipmi_pwds=`crudini --get $setup_file global controller_ipmi_pwds`

ary_controller_hosts=($controller_hosts)
ary_controller_ipmi_ips=($controller_ipmi_ips)
ary_controller_ipmi_users=($controller_ipmi_users)
ary_controller_ipmi_pwds=($controller_ipmi_pwds)


controller_num=${#ary_controller_hosts[*]}
for((i=0;i<$controller_num;i++))
do
   log "config controller ${ary_controller_hosts[$i]}"
   pcs stonith create ipmilan-${ary_controller_hosts[$i]} fence_ipmilan pcmk_host_list=${ary_controller_hosts[$i]} ipaddr=${ary_controller_ipmi_ips[$i]} login=${ary_controller_ipmi_users[$i]} passwd=${ary_controller_ipmi_pwds[$i]}  lanplus=1 cipher=1 op monitor interval=60s
   pcs stonith level add 1 ${ary_controller_hosts[$i]} ipmilan-${ary_controller_hosts[$i]}
done

# 定义controller节点最基本的IP、memcached、httpd服务
pcs resource create ClusterIP ocf:heartbeat:IPaddr2 ip=${cluster_vip} cidr_netmask=24 nic=br-ex op monitor interval=30s
pcs resource create memcached systemd:memcached --clone interleave=true --disabled --force
pcs resource create httpd apache --clone interleave=true --disabled --force
pcs constraint order start memcached-clone then httpd-clone
pcs constraint colocation add httpd-clone with memcached-clone

# 定义controller节点的glance服务
pcs resource create glance-registry systemd:openstack-glance-registry --clone interleave=true --disabled --force
pcs resource create glance-api systemd:openstack-glance-api --clone interleave=true --disabled --force
pcs constraint order start httpd-clone then glance-registry-clone
pcs constraint order start glance-registry-clone then glance-api-clone
pcs constraint colocation add glance-registry-clone with httpd-clone
pcs constraint colocation add glance-api-clone with glance-registry-clone

# 定义controller节点的nova服务
pcs resource create nova-consoleauth systemd:openstack-nova-consoleauth --clone interleave=true --disabled --force
pcs resource create nova-novncproxy systemd:openstack-nova-novncproxy --clone interleave=true --disabled --force
pcs resource create nova-cert systemd:openstack-nova-cert --clone interleave=true --disabled --force
pcs resource create nova-api systemd:openstack-nova-api --clone interleave=true --disabled --force
pcs resource create nova-scheduler systemd:openstack-nova-scheduler --clone interleave=true --disabled --force
pcs resource create nova-conductor systemd:openstack-nova-conductor --clone interleave=true --disabled --force
pcs constraint order start httpd-clone then nova-consoleauth-clone
pcs constraint order start nova-consoleauth-clone then nova-novncproxy-clone
pcs constraint order start nova-novncproxy-clone then nova-cert-clone
pcs constraint order start nova-cert-clone then nova-api-clone
pcs constraint order start nova-api-clone then nova-scheduler-clone
pcs constraint order start nova-scheduler-clone then nova-conductor-clone
pcs constraint colocation add nova-consoleauth-clone with httpd-clone
pcs constraint colocation add nova-novncproxy-clone with nova-consoleauth-clone
pcs constraint colocation add nova-cert-clone with nova-novncproxy-clone
pcs constraint colocation add nova-api-clone with nova-cert-clone
pcs constraint colocation add nova-scheduler-clone with nova-api-clone
pcs constraint colocation add nova-conductor-clone with nova-scheduler-clone

# 定义controller/network节点的neutron服务
pcs resource create neutron-server systemd:neutron-server op start timeout=90 --clone interleave=true --disabled --force
pcs resource create neutron-scale ocf:neutron:NeutronScale --clone globally-unique=true clone-max=3 interleave=true --disabled --force
pcs resource create neutron-ovs-cleanup ocf:neutron:OVSCleanup --clone interleave=true --disabled --force
pcs resource create neutron-netns-cleanup ocf:neutron:NetnsCleanup --clone interleave=true --disabled --force
pcs resource create neutron-openvswitch-agent systemd:neutron-openvswitch-agent --clone interleave=true --disabled --force
pcs resource create neutron-dhcp-agent systemd:neutron-dhcp-agent --clone interleave=true --disabled --force
pcs resource create neutron-l3-agent systemd:neutron-l3-agent --clone interleave=true --disabled --force
pcs resource create neutron-metadata-agent systemd:neutron-metadata-agent  --clone interleave=true --disabled --force
pcs resource create neutron-lbaas-agent systemd:neutron-lbaas-agent --clone interleave=true --disabled --force
pcs resource create neutron-vpn-agent systemd:neutron-vpn-agent --clone interleave=true --disabled --force
pcs constraint order start httpd-clone then neutron-server-clone
pcs constraint order start neutron-server-clone then neutron-scale-clone
pcs constraint order start neutron-scale-clone then neutron-ovs-cleanup-clone
pcs constraint order start neutron-ovs-cleanup-clone then neutron-netns-cleanup-clone
pcs constraint order start neutron-netns-cleanup-clone then neutron-openvswitch-agent-clone
pcs constraint order start neutron-openvswitch-agent-clone then neutron-dhcp-agent-clone
pcs constraint order start neutron-dhcp-agent-clone then neutron-lbaas-agent-clone
pcs constraint order start neutron-lbaas-agent-clone then neutron-vpn-agent-clone
pcs constraint order start neutron-vpn-agent-clone then neutron-l3-agent-clone
pcs constraint order start neutron-l3-agent-clone then neutron-metadata-agent-clone
pcs constraint colocation add neutron-server-clone with httpd-clone
pcs constraint colocation add neutron-scale-clone with neutron-server-clone
pcs constraint colocation add neutron-ovs-cleanup-clone with neutron-scale-clone
pcs constraint colocation add neutron-netns-cleanup-clone with neutron-ovs-cleanup-clone
pcs constraint colocation add neutron-openvswitch-agent-clone with neutron-netns-cleanup-clone
pcs constraint colocation add neutron-dhcp-agent-clone with neutron-openvswitch-agent-clone
pcs constraint colocation add neutron-lbaas-agent-clone with neutron-dhcp-agent-clone
pcs constraint colocation add neutron-vpn-agent-clone with neutron-lbaas-agent-clone
pcs constraint colocation add neutron-l3-agent-clone with neutron-vpn-agent-clone
pcs constraint colocation add neutron-metadata-agent-clone with neutron-l3-agent-clone

# 定义controller节点的cinder服务
pcs resource create cinder-api systemd:openstack-cinder-api --clone interleave=true --disabled --force
pcs resource create cinder-scheduler systemd:openstack-cinder-scheduler --clone interleave=true --disabled --force
pcs resource create cinder-backup systemd:openstack-cinder-backup --clone interleave=true --disabled --force
pcs constraint order start httpd-clone then cinder-backup-clone
pcs constraint order start cinder-backup-clone then cinder-scheduler-clone
pcs constraint order start cinder-scheduler-clone then cinder-api-clone
pcs constraint colocation add cinder-backup-clone with httpd-clone
pcs constraint colocation add cinder-scheduler-clone with cinder-backup-clone
pcs constraint colocation add cinder-api-clone with cinder-scheduler-clone

# 定义controller节点的ceilometer服务
pcs resource create ceilometer-central systemd:openstack-ceilometer-central --clone interleave=true --disabled --force
pcs resource create ceilometer-notification systemd:openstack-ceilometer-notification --clone interleave=true --disabled --force
pcs resource create ceilometer-collector systemd:openstack-ceilometer-collector --clone interleave=true --disabled --force
pcs resource create ceilometer-alarm-evaluator systemd:openstack-ceilometer-alarm-evaluator --clone interleave=true --disabled --force
pcs resource create ceilometer-alarm-notifier systemd:openstack-ceilometer-alarm-notifier --clone interleave=true --disabled --force
pcs resource create ceilometer-api systemd:openstack-ceilometer-api --clone interleave=true --disabled --force
pcs constraint order start httpd-clone then ceilometer-central-clone
pcs constraint order start ceilometer-central-clone then ceilometer-notification-clone
pcs constraint order start ceilometer-notification-clone then ceilometer-collector-clone
pcs constraint order start ceilometer-collector-clone then ceilometer-alarm-evaluator-clone
pcs constraint order start ceilometer-alarm-evaluator-clone then ceilometer-alarm-notifier-clone
pcs constraint order start ceilometer-alarm-notifier-clone then ceilometer-api-clone
pcs constraint colocation add ceilometer-central-clone with httpd-clone
pcs constraint colocation add ceilometer-notification-clone with ceilometer-central-clone
pcs constraint colocation add ceilometer-collector-clone with ceilometer-notification-clone
pcs constraint colocation add ceilometer-alarm-evaluator-clone with ceilometer-collector-clone
pcs constraint colocation add ceilometer-alarm-notifier-clone with ceilometer-alarm-evaluator-clone
pcs constraint colocation add ceilometer-api-clone with ceilometer-alarm-notifier-clone

# 定义controller节点的nova疏散服务
pcs resource create nova-evacuate ocf:openstack:NovaEvacuate auth_url=$OS_AUTH_URL username=$OS_USERNAME password=$OS_PASSWORD tenant_name=$OS_TENANT_NAME
pcs constraint order start ClusterIP then nova-evacuate
pcs constraint colocation add nova-evacuate with ClusterIP
pcs constraint order start glance-api-clone then nova-evacuate require-all=false
pcs constraint order start neutron-metadata-agent-clone then nova-evacuate require-all=false
pcs constraint order start nova-conductor-clone then nova-evacuate require-all=false

# 定义controller节点角色，以及上述服务依赖的角色
controllers="$controller_hosts"
for controller in ${controllers}; do sudo pcs property set --node ${controller} osprole=controller ; done
pcs constraint location ClusterIP rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location memcached-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location httpd-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location glance-registry-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location glance-api-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-consoleauth-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-novncproxy-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-cert-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-api-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-scheduler-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-conductor-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-server-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-scale-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-ovs-cleanup-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-netns-cleanup-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-openvswitch-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-dhcp-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-l3-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-metadata-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-lbaas-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location neutron-vpn-agent-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location cinder-api-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location cinder-scheduler-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location cinder-backup-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-central-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-notification-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-collector-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-alarm-evaluator-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-alarm-notifier-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location ceilometer-api-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint location nova-evacuate rule resource-discovery=exclusive score=0 osprole eq controller

# 定义上述systemd类型服务的监控时间
pcs resource update memcached-clone op start timeout=200s op stop timeout=200s
pcs resource update glance-registry-clone op start timeout=200s op stop timeout=200s
pcs resource update glance-api-clone op start timeout=200s op stop timeout=200s
pcs resource update nova-consoleauth-clone op start timeout=200s op stop timeout=200s
pcs resource update nova-novncproxy op start timeout=200s op stop timeout=200s
pcs resource update nova-cert-clone op start timeout=200s op stop timeout=200s
pcs resource update nova-api-clone op start timeout=200s op stop timeout=200s
pcs resource update nova-scheduler-clone op start timeout=200s op stop timeout=200s
pcs resource update nova-conductor-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-server-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-openvswitch-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-dhcp-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-l3-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-metadata-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-lbaas-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update neutron-vpn-agent-clone op start timeout=200s op stop timeout=200s
pcs resource update cinder-api-clone op start timeout=200s op stop timeout=200s
pcs resource update cinder-scheduler-clone op start timeout=200s op stop timeout=200s
pcs resource update cinder-backup-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-central-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-notification-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-collector-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-alarm-evaluator-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-alarm-notifier-clone op start timeout=200s op stop timeout=200s
pcs resource update ceilometer-api-clone op start timeout=200s op stop timeout=200s

compute_hosts=`crudini --get $setup_file global compute_hosts`
compute_ipmi_ips=`crudini --get $setup_file global compute_ipmi_ips`
compute_ipmi_users=`crudini --get $setup_file global compute_ipmi_users`
compute_ipmi_pwds=`crudini --get $setup_file global compute_ipmi_pwds`

ary_compute_hosts=($compute_hosts)
ary_compute_ipmi_ips=($compute_ipmi_ips)
ary_compute_ipmi_users=($compute_ipmi_users)
ary_compute_ipmi_pwds=($compute_ipmi_pwds)

compute_length=${#ary_compute_hosts[*]}

pcs stonith create fence-nova fence_compute auth-url=$OS_AUTH_URL login=$OS_USERNAME passwd=$OS_PASSWORD tenant-name=$OS_TENANT_NAME domain=localdomain record-only=1 action=off no-shared-storage=False --force 


# 添加计算节点及节点的ipmi stonith设备
for((i=0;i<$compute_length;i++))
do
   pcs resource create ${ary_compute_hosts[$i]} ocf:pacemaker:remote reconnect_interval=60 op monitor interval=20
   pcs property set --node ${ary_compute_hosts[$i]} osprole=compute
   pcs stonith create ipmilan-${ary_compute_hosts[$i]} fence_ipmilan pcmk_host_list=${ary_compute_hosts[$i]} ipaddr=${ary_compute_ipmi_ips[$i]} login=${ary_compute_ipmi_users[$i]} passwd=${ary_compute_ipmi_pwds[$i]} lanplus=1 cipher=1 op monitor interval=60s
   pcs stonith level add 1 ${ary_compute_hosts[$i]} ipmilan-${ary_compute_hosts[$i]},fence-nova
done


# 定义计算节点的nova疏散检查服务
pcs resource create nova-compute-checkevacuate ocf:openstack:nova-compute-wait auth_url=$OS_AUTH_URL username=$OS_USERNAME password=$OS_PASSWORD tenant_name=$OS_TENANT_NAME domain=localdomain op start timeout=300 --clone interleave=true --force
pcs constraint location nova-compute-checkevacuate-clone rule resource-discovery=exclusive score=0 osprole eq compute

# 定义计算节点上的system服务
pcs resource create neutron-openvswitch-agent-compute systemd:neutron-openvswitch-agent --clone interleave=true --disabled --force
pcs constraint location neutron-openvswitch-agent-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

pcs resource create libvirtd-compute systemd:libvirtd --clone interleave=true --disabled --force
pcs constraint location libvirtd-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

pcs resource create nova-compute systemd:openstack-nova-compute --clone interleave=true --disabled --force
pcs constraint location nova-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

pcs resource create neutron-metadata-agent-compute systemd:neutron-metadata-agent  --clone interleave=true --disabled --force
pcs constraint location neutron-metadata-agent-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

pcs resource create neutron-l3-agent-compute systemd:neutron-l3-agent --clone interleave=true --disabled --force
pcs constraint location neutron-l3-agent-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

pcs resource create ceilometer-compute systemd:openstack-ceilometer-compute --clone interleave=true --disabled --force 
pcs constraint location ceilometer-compute-clone rule resource-discovery=exclusive score=0 osprole eq compute

# 定义计算节点的服务依赖
pcs constraint order start neutron-server-clone then neutron-openvswitch-agent-compute-clone require-all=false
pcs constraint order start neutron-openvswitch-agent-compute-clone then libvirtd-compute-clone
pcs constraint order start neutron-openvswitch-agent-compute-clone then neutron-l3-agent-compute-clone
pcs constraint order start neutron-l3-agent-compute-clone then neutron-metadata-agent-compute-clone
pcs constraint order start nova-conductor-clone then nova-compute-checkevacuate-clone require-all=false
pcs constraint order start nova-compute-checkevacuate-clone then nova-compute-clone require-all=true
pcs constraint order start libvirtd-compute-clone then nova-compute-clone
pcs constraint order start nova-compute-clone then nova-evacuate require-all=false
pcs constraint colocation add libvirtd-compute-clone with neutron-openvswitch-agent-compute-clone
pcs constraint colocation add neutron-l3-agent-compute-clone with neutron-openvswitch-agent-compute-clone
pcs constraint colocation add neutron-metadata-agent-compute-clone with neutron-l3-agent-compute-clone
pcs constraint colocation add nova-compute-clone with nova-compute-checkevacuate-clone
pcs constraint colocation add nova-compute-clone with libvirtd-compute-clone


pcs resource create cinder-volume systemd:openstack-cinder-volume interleave=true --disabled --force
pcs constraint colocation add cinder-volume with ClusterIP
pcs constraint order start ClusterIP then cinder-volume
pcs constraint location cinder-volume rule resource-discovery=exclusive score=0 osprole eq controller



# 定义集群的其它信息
pcs resource defaults resource-stickiness=INFINITY
pcs property set cluster-recheck-interval=1min
pcs property set stonith-enabled=true

# 写入配置
#pcs cluster cib-push waret


pcs resource enable memcached-clone
pcs resource enable httpd-clone

pcs resource enable glance-registry-clone
pcs resource enable glance-api-clone

pcs resource enable nova-consoleauth-clone
pcs resource enable nova-novncproxy-clone
pcs resource enable nova-cert-clone
pcs resource enable nova-api-clone
pcs resource enable nova-scheduler-clone
pcs resource enable nova-conductor-clone

pcs resource enable neutron-server-clone
pcs resource enable neutron-scale-clone
pcs resource enable neutron-ovs-cleanup-clone
pcs resource enable neutron-netns-cleanup-clone
pcs resource enable neutron-openvswitch-agent-clone
pcs resource enable neutron-dhcp-agent-clone
pcs resource enable neutron-l3-agent-clone
pcs resource enable neutron-metadata-agent-clone
pcs resource enable neutron-lbaas-agent-clone
pcs resource enable neutron-vpn-agent-clone

pcs resource enable cinder-api-clone
pcs resource enable cinder-scheduler-clone
pcs resource enable cinder-backup-clone

pcs resource enable ceilometer-central-clone
pcs resource enable ceilometer-notification-clone
pcs resource enable ceilometer-collector-clone
pcs resource enable ceilometer-alarm-evaluator-clone
pcs resource enable ceilometer-alarm-notifier-clone
pcs resource enable ceilometer-api-clone


pcs resource enable neutron-openvswitch-agent-compute-clone
pcs resource enable libvirtd-compute-clone
pcs resource enable nova-compute-clone
pcs resource enable neutron-metadata-agent-compute-clone
pcs resource enable neutron-l3-agent-compute-clone
pcs resource enable ceilometer-compute-clone

pcs resource enable cinder-volume

pcs status
