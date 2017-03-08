#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script install dashboard(horizon)
#
#  2016-06-17: create
#

#set -x

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

log "Install horizon software"
yum install  -y openstack-dashboard


log "config horizon"
mv /etc/openstack-dashboard/local_settings /etc/openstack-dashboard/local_settings.bak.`date +%s`

sed_expr="s/BOCLOUD_HORIZON/${controller_ip}/g"


#echo $sed_expr

sed -i "${sed_expr}" ${script_dir}/local_settings

cp -f ${script_dir}/local_settings /etc/openstack-dashboard/local_settings

sed_expr="s/${controller_ip}/BOCLOUD_HORIZON/g"

sed -i "${sed_expr}" ${script_dir}/local_settings

chown root:apache /etc/openstack-dashboard/local_settings

log "restart http service"
systemctl enable  memcached.service

systemctl restart httpd.service memcached.service

systemctl status httpd.service

