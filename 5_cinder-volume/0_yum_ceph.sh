#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set nfs as the backend of cinder
#
#  2016-06-17: create
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

db_ip=`crudini --get $setup_file cluster db_ip`

db_passwd=`crudini --get $setup_file cinder db_passwd`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

passwd=`crudini --get $setup_file cinder service_passwd`

log "************************************************************"
log "Before config cinder backend,You should config ceph"
log "************************************************************"

log "Install cinder volume software"
yum install  -y nfs-utils openstack-cinder targetcli lvm2 targetcli python-oslo-policy


log "configuration cinder volume"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

log "config db"
#[database]
crudini --set /etc/cinder/cinder.conf  database connection  mysql://cinder:${db_passwd}@${db_ip}/cinder

log "config default"
#[DEFAULT]
crudini --set /etc/cinder/cinder.conf  DEFAULT rpc_backend  rabbit
crudini --set /etc/cinder/cinder.conf  DEFAULT auth_strategy  keystone
crudini --set /etc/cinder/cinder.conf  DEFAULT my_ip  $my_ip
crudini --set /etc/cinder/cinder.conf  DEFAULT enabled_backends  ceph
crudini --set /etc/cinder/cinder.conf  DEFAULT glance_host  ${controller_ip}
crudini --set /etc/cinder/cinder.conf  DEFAULT glance_api_version  2

crudini --set /etc/cinder/cinder.conf  DEFAULT backup_driver  cinder.backup.drivers.ceph
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_user  cinder
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_chunk_size  134217728
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_pool  backups
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_stripe_unit  0
crudini --set /etc/cinder/cinder.conf  DEFAULT backup_ceph_stripe_count  0
crudini --set /etc/cinder/cinder.conf  DEFAULT restore_discard_excess_bytes  true

log "config rabbit"
#[oslo_messaging_rabbit]
if [ "$cluster_on" == "0" ];then
    crudini --set /etc/cinder/cinder.conf  oslo_messaging_rabbit rabbit_host  ${rabbit_ip}
    crudini --set /etc/cinder/cinder.conf  oslo_messaging_rabbit rabbit_userid  openstack
    crudini --set /etc/cinder/cinder.conf  oslo_messaging_rabbit rabbit_password  ${rabbit_passwd}
else
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_hosts $rabbit_clusters
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_interval 1  
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_retry_backoff 2
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_max_retries 0
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_durable_queues true
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_ha_queues true 
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
    crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $rabbit_passwd
fi


log "keystone"
#[keystone_authtoken]
crudini --set /etc/cinder/cinder.conf  keystone_authtoken auth_uri  http://${controller_ip}:5000
crudini --set /etc/cinder/cinder.conf  keystone_authtoken auth_url  http://${controller_ip}:35357
crudini --set /etc/cinder/cinder.conf  keystone_authtoken auth_plugin  password
crudini --set /etc/cinder/cinder.conf  keystone_authtoken project_domain_id  default
crudini --set /etc/cinder/cinder.conf  keystone_authtoken user_domain_id  default
crudini --set /etc/cinder/cinder.conf  keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf  keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf  keystone_authtoken password  $passwd

log "config ceph"
#[ceph]
crudini --set /etc/cinder/cinder.conf ceph volume_driver  cinder.volume.drivers.rbd.RBDDriver
crudini --set /etc/cinder/cinder.conf ceph rbd_pool  volumes
crudini --set /etc/cinder/cinder.conf ceph rbd_ceph_conf  /etc/ceph/ceph.conf
crudini --set /etc/cinder/cinder.conf ceph rbd_flatten_volume_from_snapshot  false
crudini --set /etc/cinder/cinder.conf ceph rbd_max_clone_depth  5
crudini --set /etc/cinder/cinder.conf ceph rbd_store_chunk_size  4
crudini --set /etc/cinder/cinder.conf ceph rados_connect_timeout  -1
crudini --set /etc/cinder/cinder.conf ceph rbd_user  cinder
crudini --set /etc/cinder/cinder.conf ceph rbd_secret_uuid  a6d039d7-59c1-4822-8230-81d5c7ea3bc9 

log "config lock path"
#[oslo_concurrency]
crudini --set /etc/cinder/cinder.conf  oslo_concurrency lock_path  /var/lib/cinder/tmp


log "start service.."
systemctl enable openstack-cinder-volume.service
systemctl start openstack-cinder-volume.service


systemctl status openstack-cinder-volume.service


