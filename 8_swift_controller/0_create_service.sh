#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#
#  This script create swift service
#
#  2016-07-16: create
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

source /root/admin-openrc

controller_ip=`crudini --get $setup_file cluster cluster_vip`
service_passwd=`crudini --get $setup_file swift service_passwd`


openstack user create --domain default --password $service_passwd swift
openstack role add --project service --user swift admin

log "create swift service & endpoint"
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public http://${controller_ip}:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store internal http://${controller_ip}:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store admin http://${controller_ip}:8080/v1

log "finished"





