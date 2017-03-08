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

db_host=`crudini --get $setup_file cluster db_ip`

db_user=`crudini --get $setup_file cluster db_user`

db_passwd=`crudini --get $setup_file cluster db_root_passwd`

user_passwd=`crudini --get $setup_file nova db_passwd`


mysql -u$db_user -p$db_passwd -h $db_host -e "CREATE DATABASE nova;"
mysql -u$db_user -p$db_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '""$user_passwd""'"
mysql -u$db_user -p$db_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '""$user_passwd""'"



