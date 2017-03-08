#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#
#  This script verify swift service
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

source /root/demo-openrc
swift stat

log "upload file to swift"
swift upload container1 $script_dir/swift.conf

swift list

swift download container1 swift.conf.test




