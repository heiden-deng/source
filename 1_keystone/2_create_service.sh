#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create keystone service && endpoint
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
admin_passwd=`crudini --get $setup_file keystone admin_passwd`
demo_passwd=`crudini --get $setup_file keystone demo_passwd`

token=`crudini --get $setup_file cluster admin_token`
export OS_TOKEN=$token
export OS_URL=http://${controller_ip}:35357/v3
export OS_IDENTITY_API_VERSION=3

echo "$OS_URL"
echo "$OS_TOKEN"

log "create keystone service"
openstack service create --name keystone --description "OpenStack Identity" identity

log "create keystone endpoint"
openstack endpoint create --region RegionOne identity public http://${controller_ip}:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://${controller_ip}:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://${controller_ip}:35357/v2.0


log "create admin project(tenant)"
openstack project create --domain default --description "Admin Project" admin

log "create admin user"
openstack user create --domain default --password ${admin_passwd} admin

log "create admin role and add user admin to admin role"
openstack role create admin
openstack role add --project admin --user admin admin

log "create service project"
openstack project create --domain default --description "Service Project" service

log "create demo project ,demo user,demo role"
openstack project create --domain default --description "Demo Project" demo

openstack user create --domain default --password "$demo_passwd" demo
openstack role create user
openstack role add --project demo --user demo user

log "finished"
