#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script init nova db
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

mongodb_host=`crudini --get $setup_file cluster mongodb_host`
passwd=`crudini --get $setup_file cluster mongodb_passwd`

log "create mongodb ceilometer database"
cmd="db = db.getSiblingDB(\"ceilometer\");db.createUser({user: \"ceilometer\",pwd: \"$passwd\",roles: [ \"readWrite\", \"dbAdmin\" ]})"
mongo --host $mongodb_host --eval "$cmd"



