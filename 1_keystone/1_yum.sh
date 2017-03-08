#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install and config keystone
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
#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}


controller_ip=`crudini --get $setup_file cluster cluster_vip`
db_ip=`crudini --get $setup_file cluster db_ip`
user_passwd=`crudini --get $setup_file keystone db_passwd`

log "Install keystone software"
yum install  -y openstack-keystone httpd mod_wsgi memcached python-memcached 

log "start memcache"
systemctl enable memcached.service
systemctl start memcached.service


log "create token"
token=`crudini --get $setup_file cluster admin_token`


log "configuration keystone"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi
crudini --set  /etc/keystone/keystone.conf DEFAULT admin_token $token
crudini --set  /etc/keystone/keystone.conf database connection mysql://keystone:${user_passwd}@${db_ip}/keystone
crudini --set  /etc/keystone/keystone.conf memcache servers localhost:11211
crudini --set  /etc/keystone/keystone.conf token provider uuid
crudini --set  /etc/keystone/keystone.conf token driver memcache
crudini --set  /etc/keystone/keystone.conf revoke driver sql
crudini --set  /etc/keystone/keystone.conf DEFAULT verbose True

log "sync keystone db"
su -s /bin/sh -c "keystone-manage db_sync" keystone



log "configure http"

sed_expr="s/#ServerName www.example.com:80/ServerName $controller_ip/g"
sed -i "$sed_expr" /etc/httpd/conf/httpd.conf

cat >  /etc/httpd/conf.d/wsgi-keystone.conf <<EOF
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>
EOF

log "start http service"
systemctl enable httpd.service
systemctl start httpd.service

systemctl status httpd.service
