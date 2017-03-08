#!/bin/bash

script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh


source /root/admin-openrc

cinder-manage service list
