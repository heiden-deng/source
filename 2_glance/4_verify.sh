#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script verify glance service
#
#  2016-06-17: create
#
#set -x


script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh


source /root/admin-openrc

img_file=$script_dir/cirros-0.3.4-x86_64-disk.img

glance image-create --name "cirros" --file $img_file --disk-format qcow2 --container-format bare --visibility public --progress

glance image-list
