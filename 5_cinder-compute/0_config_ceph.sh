#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config libvirt use rbd
#
#  2016-11-01: create
#


script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh
setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

#################################################

#本机IP，需要根据实际情况进行修改
my_ip=`crudini --get $setup_file cluster my_ip`

###############################################


log "************************************************************"
log "Before config nova libvirt,You should config ceph"

log "configuration nova libvirt"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log "config libvirt"
crudini --set /etc/nova/nova.conf libvirt images_type  rbd
crudini --set /etc/nova/nova.conf libvirt images_rbd_pool  vms
crudini --set /etc/nova/nova.conf libvirt images_rbd_ceph_conf  /etc/ceph/ceph.conf
crudini --set /etc/nova/nova.conf libvirt rbd_user  cinder
crudini --set /etc/nova/nova.conf libvirt rbd_secret_uuid  a6d039d7-59c1-4822-8230-81d5c7ea3bc9
crudini --set /etc/nova/nova.conf libvirt disk_cachemodes "network=writeback"
#crudini --set /etc/nova/nova.conf libvirt live_migration_flag "VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST,VIR_MIGRATE_TUNNELLED"


log "restart service.."
systemctl restart openstack-nova-compute.service

systemctl status openstack-nova-compute.service


