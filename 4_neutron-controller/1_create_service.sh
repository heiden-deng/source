#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create neutron service && endpoint
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
passwd=`crudini --get $setup_file neutron service_passwd`


echo "$OS_URL"
source /root/admin-openrc
log "create neutron user"

openstack user create --domain default --password $passwd neutron

openstack role add --project service --user neutron admin

log "create neutron service &  endpoint"

openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://${controller_ip}:9696
openstack endpoint create --region RegionOne network internal http://${controller_ip}:9696
openstack endpoint create --region RegionOne network admin http://${controller_ip}:9696


