#!/bin/bash
systemctl stop openstack-glance-api openstack-glance-registry.service
systemctl start openstack-glance-api openstack-glance-registry.service
/usr/sbin/lvscan 2>&1 > /dev/null
for lv in `lvs | grep cinder-volumes | grep wi------- | awk '{print $1}'`;do
   lvchange -a y /dev/cinder-volumes/${lv}
done
/usr/bin/cinder-rtstool restore  /var/lib/glance/saveconfig.json
