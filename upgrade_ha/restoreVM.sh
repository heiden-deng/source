#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  该脚本主要用于当虚拟机磁盘异常导致启动失败时的重建，主要针对采用云硬盘的虚拟机进行恢复
#
#  2016-12-26: create
#

if [ ! -f "/root/admin-openrc" ];then
   echo "MUST Run in Controller node"
   exit 1
fi
source /root/admin-openrc
#清除空格
clearspace()
{
  local arg1="$1"
  echo $arg1 | sed 's/^\ *//g' | sed 's/\ *$//g'
}

#清除方括号
clearbracket()
{
  local arg2="$1"
  echo $arg2 | sed 's/\[//g' | sed 's/\]//g'
}
if [ $# -lt 1 ];then
   echo "Usage: $0 filename"
   exit 1
fi
filename="$1"
echo ""
echo "本脚本根据虚拟机dump 信息恢复虚拟机,并且保证恢复后IP，mac，cinder保持不变"
echo "     =============================================================     "

while read line;
do
    vm_id=`echo $line | awk -F '$' '{print $1}'`
    vm_id=$(clearspace "$vm_id")
    vm_name=`echo $line | awk -F '$' '{print $2}'`
    vm_name=$(clearspace "$vm_name")
    vm_flavor_id=`echo $line | awk -F '$' '{print $3}'`
    vm_flavor_id=$(clearspace "$vm_flavor_id")
    vm_ips=`echo $line | awk -F '$' '{print $4}'`
    vm_ips=$(clearspace "$vm_ips")
    vm_cinder_ids=`echo $line | awk -F '$' '{print $5}'`
    vm_cinder_ids=$(clearspace "$vm_cinder_ids")
     
    ret=`nova list | grep $vm_id`
    if [ $? -eq 0 ];then
       echo "*******vm name[$vm_name] exist,you should delete it first,SKIP CREATE*********"
       continue
    fi
    if [ "$vm_cinder_ids" == "" ];then
       echo "*******************cinder volume is null, skip ***********************"
       continue
    fi
    nova_nic=" "
    echo "vm_ips=[$vm_ips]"
    for ips in $vm_ips
    do
       echo "ips=$ips"
       port_id=`echo $ips | awk -F'#' '{print $1}'` 
       port_ip=`echo $ips | awk -F'#' '{print $2}'` 
       port_mac=`echo $ips | awk -F'#' '{print $3}'` 
       port_subnet=`echo $ips | awk -F'#' '{print $4}'` 
       port_net=`echo $ips | awk -F'#' '{print $5}'`
       
       ret=`neutron port-list | grep $port_id`
       if [ $? -eq 0 ];then
          nova_nic=${nova_nic}" --nic port-id=${port_id}"
       else
          ret=`neutron port-create --fixed-ip subnet_id=${port_subnet},ip_address=${port_ip}  --mac-address ${port_mac} ${port_net}`
          port_id=`neutron port-list | grep "$port_mac" | awk -F '|' '{print $2}'`
          port_id=$(clearspace "$port_id")
          nova_nic=${nova_nic}" --nic port-id=${port_id}"
       fi
    done    

    boot_cinder_id=`echo $vm_cinder_ids | awk -F' ' '{print $1}'`
    
    echo "starting  create vm name=[$vm_name];flavor=[$vm_flavor_id];ips=[$nova_nic];cinder=[$vm_cinder_ids]"
    nova boot $nova_nic --flavor ${vm_flavor_id} --boot-volume $boot_cinder_id $vm_name
    sleep 10
    
    nova_id=`nova list | grep $port_ip | awk -F'|' '{print $2}'`
    nova_id=$(clearspace "$nova_id")
    echo "new vm id=[$nova_id]"

    echo "wait vm being running"
    vm_status=`nova show $nova_id | grep "status                               | BUILD"`
    while [ "$vm_status" != "" ];
    do
      echo "wait 5s for  vm create finished"
      sleep 5
      vm_status=`nova show $nova_id | grep "status                               | BUILD"`
    done
    echo "vm create finished,attach cinder volume"
    for cinder_id in $vm_cinder_ids;
    do
       if [ "$cinder_id" == "$boot_cinder_id" ];then
          continue
       fi
       echo "attach cinder volume[$cinder_id]"
       nova volume-attach $nova_id $cinder_id
    done


done < $filename
