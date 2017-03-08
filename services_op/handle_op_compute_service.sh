#!/bin/bash
action=$1

if [ "$action" != "disable" -a "$action" != "stop" -a "$action" != "restart" ]; then
	systemctl $action openvswitch.service openvswitch-nonetwork.service
fi

systemctl $action libvirtd.service openstack-nova-compute.service

systemctl $action  neutron-openvswitch-agent.service  neutron-metadata-agent.service neutron-l3-agent.service 

systemctl $action openstack-ceilometer-compute.service

