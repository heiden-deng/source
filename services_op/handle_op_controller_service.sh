#!/bin/bash

action=$1

if [ "$action" != "disable" -a "$action" != "stop" -a "$action" != "restart" ]; then
	systemctl $action openvswitch.service openvswitch-nonetwork.service
fi

systemctl $action memcached.service httpd.service 

systemctl $action openstack-glance-api.service openstack-glance-registry.service 

systemctl $action openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-vpn-agent.service neutron-lbaas-agent.service

systemctl $action neutron-server.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service

systemctl $action openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service
#openstack-cinder-volume.service

systemctl $action openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service
 
systemctl $action openstack-heat-api-cfn.service  openstack-heat-api.service openstack-heat-engine.service
