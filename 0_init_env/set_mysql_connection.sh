#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script set mysql max connections
#
#  2016-07-15: create
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

db_ip=`crudini --get $setup_file cluster db_ip`
db_passwd=`crudini --get $setup_file nova db_passwd`

log "install mariadb software"

yum install -y mariadb mariadb-server MySQL-python
#cp ${script_dir}/mariadb_openstack.cnf /etc/my.cnf.d/mariadb_openstack.cnf
#crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld bind-address $db_ip

log "start mysql service"
systemctl enable mariadb.service
systemctl start mariadb.service

log "config root passwd"
mysqladmin -u root password $db_passwd
mysql -uroot -p$db_passwd  -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '""$db_passwd""' WITH GRANT OPTION"
mysql -uroot -p$db_passwd  -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'""$db_ip""' IDENTIFIED BY '""$db_passwd""' WITH GRANT OPTION"
mysql -uroot -p$db_passwd  -e "flush privileges"


log "increase max connections"
crudini --set /etc/my.cnf mysqld open_files_limit 12000
crudini --set /etc/my.cnf mysqld max_connections 10000

echo "*  soft nofile 4096" >> /etc/security/limits.conf
echo "*  hard nofile 10240" >> /etc/security/limits.conf

mkdir -p /etc/systemd/system/mariadb.service.d
touch /etc/systemd/system/mariadb.service.d/limits.conf
crudini --set /etc/systemd/system/mariadb.service.d/limits.conf Service LimitNOFILE infinity

systemctl daemon-reload
systemctl restart mariadb

log "finished"
