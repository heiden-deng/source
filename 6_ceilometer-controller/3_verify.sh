#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script verify nova service
#
#  2016-06-17: create
#



script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh


source /root/admin-openrc
log "test ceilometer"

ceilometer meter-list

IMAGE_ID=$(glance image-list | grep 'cirros' | awk '{ print $2 }')
glance image-download $IMAGE_ID > /tmp/cirros.img

ceilometer meter-list

ceilometer statistics -m image.download -p 60

rm /tmp/cirros.img
