#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create ceilometer service && endpoint
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
passwd=`crudini --get $setup_file ceilometer service_passwd`


echo "$OS_URL"
source /root/admin-openrc
log "create ceilometer user"

openstack user create --domain default --password $passwd ceilometer

openstack role add --project service --user ceilometer admin

log "create ceilometer service &  endpoint"
openstack service create --name ceilometer --description "Telemetry" metering
openstack endpoint create --region RegionOne metering public http://${controller_ip}:8777
openstack endpoint create --region RegionOne metering internal http://${controller_ip}:8777
openstack endpoint create --region RegionOne metering admin http://${controller_ip}:8777




