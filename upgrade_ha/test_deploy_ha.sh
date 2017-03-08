#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script update db configuration 
#
#  2016-09-22: create
#



script_name="$0"
script_dir=`dirname $script_name`
setup_file="${script_dir}/env_ha_cfg.conf"
which crudini
if [ $? -ne 0 ];then
   yum install -y crudini
fi


log()
{
   tag=`date`
   echo "[$tag] $1"
}
controller_ipmi_ips=`crudini --get $setup_file global controller_ipmi_ips`
ips_ary=($controller_ipmi_ips)

length=${#ips_ary[*]}
echo "second ip="${ips_ary[1]}
for((i=0;i<$length;i++))
do
   echo ${ips_ary[$i]}
done


echo "finished"



