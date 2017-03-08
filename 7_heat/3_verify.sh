#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script verify heat service
#
#  2016-06-17: create
#
#set -x


script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh


source /root/admin-openrc

heat service-list
