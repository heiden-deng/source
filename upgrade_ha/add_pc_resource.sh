#!/bin/bash

pcs cluster cib heiden-new
cp heiden-new heiden.bak

echo "add clvm resource"
pcs   resource create dlm ocf:pacemaker:controld --clone interleave=true ordered=true on-fail=fence
pcs   resource create clvmd ocf:heartbeat:clvm --clone interleave=true ordered=true on-fail=fence
pcs   constraint order start dlm-clone then clvmd-clone
pcs   constraint colocation add clvmd-clone with dlm-clone
pcs   constraint location dlm-clone rule resource-discovery=exclusive score=0 osprole eq controller
pcs   constraint location clvmd-clone rule resource-discovery=exclusive score=0 osprole eq controller

echo "add cinder-volume resource"
pcs   resource create cinder-volume systemd:openstack-cinder-volume interleave=true -force
pcs   constraint colocation add cinder-volume with ClusterIP
pcs   constraint order start ClusterIP then cinder-volume
pcs   constraint location cinder-volume rule resource-discovery=exclusive score=0 osprole eq controller

echo "add ext3 mount resource"
pcs   resource create ext3_res Filesystem device="/dev/mapper/glance--data-glance" directory="/var/lib/glance" fstype="ext3"
pcs   constraint order start clvmd-clone then ext3_res
pcs   constraint colocation add ext3_res with ClusterIP
pcs   constraint order start ClusterIP then ext3_res
pcs   constraint location ext3_res rule resource-discovery=exclusive score=0 osprole eq controller

echo "add volume migrate init resource"
pcs   resource create bocloud-volume-rec systemd:bocloud-volume-rec interleave=true -force
pcs   constraint colocation add bocloud-volume-rec with cinder-volume
pcs   constraint order start bocloud-volume-rec then cinder-volume
pcs   constraint order start ClusterIP then bocloud-volume-rec
pcs   constraint location bocloud-volume-rec rule resource-discovery=exclusive score=0 osprole eq controller
pcs   constraint order start ext3_res then bocloud-volume-rec

echo "resource add finished, YOU SHOULD push cib into cluster manually"


