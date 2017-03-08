#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script update db configuration 
#
#  2016-09-22: create
#



#script_name="$0"
#script_dir=`dirname $script_name`
#source ${script_dir}/../common/func.sh
#setup_file="${script_dir}/../setup.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


#log()
#{
#   tag=`date`
#   echo "[$tag] $1"
#}

#db服务器IP 
db_ip="10.10.100.1"

keystone_passwd="123456"
glance_passwd="123456"
nova_passwd="123456"
neutron_passwd="123456"
cinder_passwd="123456"
ceilometer_passwd="123456"

echo "update keystone"
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak.db  
crudini --set  /etc/keystone/keystone.conf database connection mysql://keystone:${keystone_passwd}@${db_ip}/keystone

echo "update glance"
cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak.db  
crudini --set  /etc/glance/glance-api.conf database connection mysql://glance:${glance_passwd}@${db_ip}/glance 

cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak.db  
crudini --set  /etc/glance/glance-registry.conf database connection mysql://glance:${glance_passwd}@${db_ip}/glance 


echo "update nova"
cp /etc/nova/nova.conf /etc/nova/nova.conf.bak.db  
crudini --set  /etc/nova/nova.conf database connection  mysql://nova:${nova_passwd}@${db_ip}/nova 

echo "update neutron"
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak.db  
crudini --set  /etc/neutron/neutron.conf database connection mysql://neutron:${neutron_passwd}@${db_ip}/neutron

echo "update cinder"
cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.bak.db  
crudini --set  /etc/cinder/cinder.conf database connection mysql://cinder:${cinder_passwd}@${db_ip}/cinder 

echo "finished"



