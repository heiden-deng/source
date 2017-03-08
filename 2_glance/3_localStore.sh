#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config glance use local storage
#
#  2016-06-17: create
#


script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh

log "configuration glance use local storage"
crudini --set  /etc/glance/glance-api.conf glance_store default_store file
crudini --set  /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/


log "sync db"
log "sync glance db"
su -s /bin/sh -c "glance-manage db_sync" glance



log "start glance service"
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl restart openstack-glance-api.service openstack-glance-registry.service

systemctl status openstack-glance-api.service openstack-glance-registry.service
