#!/bin/bash

systemctl stop memcached.service httpd.service

systemctl stop openstack-glance-api.service openstack-glance-registry.service 

systemctl stop openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-vpn-agent.service neutron-lbaasv2-agent.service

systemctl stop neutron-server.service openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service openvswitch-nonetwork.service

systemctl stop openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service openstack-cinder-volume.service

systemctl stop openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service
