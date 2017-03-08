#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create cinder service && endpoint
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


controller_ip=`crudini --get $setup_file cluster cluster_vip`
passwd=`crudini --get $setup_file cinder service_passwd`


source /root/admin-openrc

log "create cinder user"

openstack user create --domain default --password ${passwd} cinder
openstack role add --project service --user cinder admin

log "create cinder service &  endpoint"
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

openstack endpoint create --region RegionOne volume public http://${controller_ip}:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://${controller_ip}:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://${controller_ip}:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne volumev2 public http://${controller_ip}:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://${controller_ip}:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://${controller_ip}:8776/v2/%\(tenant_id\)s




