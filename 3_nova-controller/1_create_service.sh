#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create nova service && endpoint
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
passwd=`crudini --get $setup_file nova service_passwd`


echo "$OS_URL"
source /root/admin-openrc
log "create nova user"

openstack user create --domain default --password $passwd nova

openstack role add --project service --user nova admin

log "create nova service &  endpoint"

openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://${controller_ip}:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://${controller_ip}:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://${controller_ip}:8774/v2/%\(tenant_id\)s




