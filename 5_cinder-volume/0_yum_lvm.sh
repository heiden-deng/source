#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set local lvm  as the backend of cinder
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

######################################################

#本地机器ip,需要根据实际情况进行修改 
my_ip=`crudini --get $setup_file cluster my_ip`

#磁盘路径，该盘将作为cinder的后端存储
pv_disk=`crudini --get $setup_file cinder pv_disk`

######################################################


db_ip=`crudini --get $setup_file cluster db_ip`

controller_ip=`crudini --get $setup_file cluster cluster_vip`

cluster_on=`crudini --get $setup_file cluster cluster_on`

rabbit_clusters=`crudini --get $setup_file cluster rabbit_clusters`

rabbit_ip=`crudini --get $setup_file cluster rabbit_ip`

rabbit_passwd=`crudini --get $setup_file cluster rabbit_passwd`

db_passwd=`crudini --get $setup_file cinder db_passwd`
passwd=`crudini --get $setup_file cinder service_passwd`
vg_name=`crudini --get $setup_file cinder vg_name`



log "Install cinder volume software"
yum install  -y openstack-cinder targetcli python-oslo-policy lvm2 

log "start lvm2"
systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

log "create volume group"
read -p "Are you sure continue,THIS WILL CAUSE ${pv_disk} DATA MISS(y/n):" bcontinue
if [ "x${bcontinue}" != "xy" ];then
   echo "exit "
   exit 1
fi
pvcreate $pv_disk
vgcreate $vg_name $pv_disk


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
crudini --set /etc/cinder/cinder.conf  DEFAULT enabled_backends  lvm
crudini --set /etc/cinder/cinder.conf  DEFAULT glance_host  ${controller_ip}
crudini --set /etc/cinder/cinder.conf  DEFAULT verbose True

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

log "config lvm"
#[lvm]
crudini --set /etc/cinder/cinder.conf  lvm volume_driver  cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf  lvm volume_group  cinder-volumes
crudini --set /etc/cinder/cinder.conf  lvm iscsi_protocol  iscsi
crudini --set /etc/cinder/cinder.conf  lvm iscsi_helper  lioadm

log "config lock path"
#[oslo_concurrency]
crudini --set /etc/cinder/cinder.conf  oslo_concurrency lock_path  /var/lib/cinder/tmp


log "start service.."
systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service


systemctl status openstack-cinder-volume.service target.service


