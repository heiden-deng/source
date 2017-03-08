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

####################################################

#本机IP,需要根据实际情况进行修改
my_ip=`crudini --get $setup_file cluster my_ip`

###################################################3

#nfs信息
nfs_info=`crudini --get $setup_file cinder nfs_info`

#本地nfs挂载点 
nfs_mount_point=`crudini --get $setup_file cinder nfs_mount_point`

db_ip=`crudini --get $setup_file cluster db_ip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

db_passwd=`crudini --get $setup_file cinder db_passwd`

passwd=`crudini --get $setup_file cinder service_passwd`


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
crudini --set /etc/cinder/cinder.conf  DEFAULT enabled_backends  nfs
crudini --set /etc/cinder/cinder.conf  DEFAULT glance_host  ${controller_ip}

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

log "config nfs"
echo "$nfs_info" > /etc/cinder/nfs_shares
if [ ! -d "${nfs_mount_point}" ];then
    mkdir ${nfs_mount_point}
    chmod a+w ${nfs_mount_point}
fi
#[nfs]
crudini --set /etc/cinder/cinder.conf nfs volume_driver cinder.volume.drivers.nfs.NfsDriver
crudini --set /etc/cinder/cinder.conf nfs nfs_shares_config   /etc/cinder/nfs_shares
crudini --set /etc/cinder/cinder.conf nfs nfs_mount_point_base  /var/nfs/
crudini --set /etc/cinder/cinder.conf nfs volume_backend_name  NFS1


log "config lock path"
#[oslo_concurrency]
crudini --set /etc/cinder/cinder.conf  oslo_concurrency lock_path  /var/lib/cinder/tmp


log "start service.."
systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service


systemctl status openstack-cinder-volume.service target.service


