#!/bin/bash

if [ $# -eq 0 ];then

systemctl start memcached.service httpd.service 

systemctl start openstack-glance-api.service openstack-glance-registry.service 

systemctl start openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-vpn-agent.service neutron-lbaasv2-agent.service

systemctl start neutron-server.service openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service openvswitch-nonetwork.service

systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service
#systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service openstack-cinder-volume.service

#systemctl start mongod.service  

systemctl start openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service
  
else

systemctl restart memcached.service httpd.service 

systemctl restart openstack-glance-api.service openstack-glance-registry.service 

systemctl restart openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-vpn-agent.service neutron-lbaasv2-agent.service

systemctl restart neutron-server.service openvswitch.service neutron-openvswitch-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service  neutron-l3-agent.service openvswitch-nonetwork.service

#systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service openstack-cinder-volume.service
systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service  openstack-cinder-backup.service

#systemctl restart mongod.service  

systemctl restart openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service

fi
