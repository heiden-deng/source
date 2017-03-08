#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script config cinder use ceilometer 
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

#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}


log "configuration cinder api support ceilometer"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

#[DEFAULT]
crudini --set  /etc/cinder/cinder.conf DEFAULT notification_driver  messagingv2

systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service 

systemctl status openstack-cinder-api.service openstack-cinder-scheduler.service
