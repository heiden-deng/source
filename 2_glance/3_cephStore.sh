#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config ceph being backend of glance
#
#  2016-06-17: create
#



script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh

log "*************************************"
log "Before config glance ceph, you should config ceph,and ceph df work good!"
log "*************************************"

log "configuration glance use ceph storage"


crudini --set  /etc/glance/glance-api.conf DEFAULT show_image_direct_url True 

crudini --set  /etc/glance/glance-api.conf glance_store stores rbd 
crudini --set  /etc/glance/glance-api.conf glance_store default_store  rbd
crudini --set  /etc/glance/glance-api.conf glance_store rbd_store_pool  images
crudini --set  /etc/glance/glance-api.conf glance_store rbd_store_user  glance
crudini --set  /etc/glance/glance-api.conf glance_store rbd_store_ceph_conf  /etc/ceph/ceph.conf
crudini --set  /etc/glance/glance-api.conf glance_store rbd_store_chunk_size 8


log "sync db"
log "sync glance db"
su -s /bin/sh -c "glance-manage db_sync" glance



log "start glance service"
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl restart openstack-glance-api.service openstack-glance-registry.service

systemctl status openstack-glance-api.service openstack-glance-registry.service
