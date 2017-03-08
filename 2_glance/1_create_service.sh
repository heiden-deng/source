#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create glance service && endpoint
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


#controller服务器IP 
#controller_ip="192.168.10.128"
controller_ip=`crudini --get $setup_file cluster cluster_vip`

glance_passwd=`crudini --get $setup_file glance service_passwd`


echo "$OS_URL"
source /root/admin-openrc
log "create glance service"
openstack user create --domain default --password $glance_passwd glance
openstack role add --project service --user glance admin

log "create glance service &  endpoint"
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://${controller_ip}:9292
openstack endpoint create --region RegionOne image internal http://${controller_ip}:9292
openstack endpoint create --region RegionOne image admin http://${controller_ip}:9292


