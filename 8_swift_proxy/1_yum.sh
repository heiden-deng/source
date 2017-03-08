#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#
#  This script create swift proxy
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

log "install swift proxy software"

yum install -y openstack-swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached
cp -f $script_dir/proxy-server.conf /etc/swift/proxy-server.conf

log "config proxy-server"
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  auth_uri  http://${controller_ip}:5000
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  auth_url  http://${controller_ip}:35357
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  auth_plugin  password
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  project_domain_id  default
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  user_domain_id  default
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  project_name  service
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  username  swift
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  password  $service_passwd
crudini --set /etc/swift/proxy-server.conf  filter:authtoken  delay_auth_decision  true

log "finished"



