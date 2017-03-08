#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script create auth enviroment variable file 
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

controller_ip=`crudini --get $setup_file cluster cluster_vip`
admin_passwd=`crudini --get $setup_file keystone admin_passwd`
demo_passwd=`crudini --get $setup_file keystone demo_passwd`


unset OS_TOKEN OS_URL

cat > $HOME/admin-openrc <<EOF
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${admin_passwd}
export OS_AUTH_URL=http://${controller_ip}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

EOF

cat > $HOME/demo-openrc <<EOF
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=demo
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=${demo_passwd}
export OS_AUTH_URL=http://${controller_ip}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

EOF

source $HOME/admin-openrc
openstack token issue
