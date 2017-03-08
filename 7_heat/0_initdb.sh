#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script init heat db
#
#  2016-10-25: create
#

script_name="$0"
script_dir=`dirname $script_name`
source ${script_dir}/../common/func.sh
setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi

#数据库服务器IP
db_host=`crudini --get $setup_file cluster db_ip`

db_user=`crudini --get $setup_file cluster db_user`

db_passwd=`crudini --get $setup_file cluster db_root_passwd`

user_passwd=`crudini --get $setup_file heat db_passwd`



mysql -u$db_user -p$db_passwd -h $db_host -e "CREATE DATABASE heat;"
mysql -u$db_user -p$db_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '""$user_passwd""';"
mysql -u$db_user -p$db_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '""$user_passwd""'"



