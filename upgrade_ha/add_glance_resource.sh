#!/bin/bash
pcs resource create bocloud-glance-rec systemd:bocloud-glance-rec interleave=true --force
pcs constraint colocation add bocloud-glance-rec with ClusterIP
pcs constraint order start ClusterIP then bocloud-glance-rec
pcs constraint order start clvmd-clone then bocloud-glance-rec
pcs constraint location bocloud-glance-rec rule resource-discovery=exclusive score=0 osprole eq controller
pcs constraint order start bocloud-glance-rec then ext3_res


