#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script update cinder configuration 
#
#  2016-11-29: create
#

script_name="$0"
script_dir=`dirname $script_name`
setup_file="/etc/bocloud/env_ha_cfg.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

#集群VIP 
vip=`crudini --get $setup_file global cluster_vip`

cinder_host="cinder.bocloud"

echo "update cinder"
cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak.cinder
crudini --set  /etc/cinder/cinder.conf DEFAULT my_ip $vip 
crudini --set  /etc/cinder/cinder.conf DEFAULT host $cinder_host

echo "finished"



