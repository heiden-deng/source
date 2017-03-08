#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create openstack service db user
#
#  2016-09-06: create
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

db_root_passwd=`crudini --get $setup_file cluster db_root_passwd`


keystone_db_passwd=`crudini --get $setup_file keystone db_passwd`
glance_db_passwd=`crudini --get $setup_file glance db_passwd`
nova_db_passwd=`crudini --get $setup_file nova db_passwd`
neutron_db_passwd=`crudini --get $setup_file neutron db_passwd`
cinder_db_passwd=`crudini --get $setup_file cinder db_passwd`


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}


log "init keystone db user"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "CREATE DATABASE keystone"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '""$keystone_db_passwd""'"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'  IDENTIFIED BY '""$keystone_db_passwd""'"

log "init glance db user"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "CREATE DATABASE glance;"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '""$glance_db_passwd""';"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '""$glance_db_passwd""'"

log "init nova db user"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "CREATE DATABASE nova;"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '""$nova_db_passwd""'"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '""$nova_db_passwd""'"

log "init neutron db user"
mysql -u$db_user -p${db_root_passwd} -h $db_host -e "CREATE DATABASE neutron"
mysql -u$db_user -p${db_root_passwd} -h $db_host -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '""$neutron_db_passwd""'"
mysql -u$db_user -p${db_root_passwd} -h $db_host -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '""$neutron_db_passwd""'"


log "init cinder db user"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "CREATE DATABASE cinder"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '""$cinder_db_passwd""'"
mysql -u$db_user -p$db_root_passwd -h $db_host -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '""$cinder_db_passwd""'"

mysql -u$db_user -p$db_root_passwd -h $db_host -e "flush privileges;"

log "setup openstack service user finish"






