#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create heat service && endpoint
#
#  2016-10-25: create
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

heat_passwd=`crudini --get $setup_file heat service_passwd`
heat_domain_admin_passwd=`crudini --get $setup_file heat heat_domain_admin_passwd`


echo "$OS_URL"
source /root/admin-openrc
log "create heat user"
openstack user create --domain default --password $heat_passwd heat
openstack role add --project service --user heat admin

log "create heat service &  endpoint"
openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration" cloudformation

openstack endpoint create --region RegionOne orchestration public http://${controller_ip}:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration internal http://${controller_ip}:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration admin http://${controller_ip}:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne cloudformation public http://${controller_ip}:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://${controller_ip}:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://${controller_ip}:8000/v1

openstack domain create --description "Stack projects and users" heat

openstack user create --domain heat --password  $heat_domain_admin_passwd  heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin

openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner

openstack role create heat_stack_user



