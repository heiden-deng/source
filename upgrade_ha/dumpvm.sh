#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script backup vm info
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
echo "本脚本生成如下格式的虚拟机信息"
echo "       vm_id          \$    vm_name    \$          flavor_id         \$  IPs(port_id#IP#mac#subnet#net) \$ cinder_ids"

datetime=`date +%Y-%m-%d-%H-%M-%S`
filename=$datetime".txt"
IFS_OLD="$IFS"
IFS=$'\n'
for vm in `nova list | grep -v "| Name       | Status |" | grep -v "+------------+"`;
do
   #echo $vm
   vm_id=`echo $vm | awk -F ' ' '{print $2}'`
   vm_name=`echo "$vm" | awk -F ' ' '{print $4}'`

   #提取网络信息，处理虚拟机具有多个网卡的情形
   net_list=`echo $vm | awk -F '|' '{print $7}' | sed 's/^\ *//g'`
   if [ "$net_list" != "" ];then
      #echo "net_list=$net_list"
      ip_list=`echo $net_list | awk -F';' '{ip="";for(i=1;i<=NF;i++){split($i,array,"=");if(i==1){ip=array[2]}else{ip=ip"  "array[2]}};print ip}'`
      IFS_IP="$IFS"
      IFS=" "
      ips=""
      #提取虚拟机IP，mac，子网ID，网络ID信息
      for ip in $ip_list
      do
          port_info=`neutron port-list | grep "$ip"`
          port_id=`echo $port_info | awk -F '|' '{print $2}'`
          port_id=$(clearspace "$port_id")
          port_mac=`echo $port_info | awk -F '|' '{print $4}'`
          port_mac=$(clearspace $port_mac)
          port_subnet=`echo $port_info | awk -F '|' '{print $5}' | awk -F '"' '{print $4}'`
          port_net=`neutron net-list | grep $port_subnet | awk -F '|' '{print $2}'`
          port_net=$(clearspace $port_net)
          ips=$ips" "$port_id"#"$ip"#"$port_mac"#"$port_subnet"#"$port_net
          #echo "port_info=[$ips]"
      done
      #echo "ips=[$ips]"
      #提取flavor信息
      flavor_id=`nova show $vm_id | grep "flavor                               " | awk -F'(' '{print $2}' | awk -F')' '{print $1}'`
      
      #提取cinder信息
      cinder_ids=`nova show $vm_id | grep "os-extended-volumes:volumes_attached" | awk -F '|' '{print $3}' | awk '{gsub("{\"id\": \"","");gsub("\", \"delete_on_termination\": false}","");print }'`
      #echo "cinder_ids0=[$cinder_ids]"
      cinder_ids=$(clearbracket "$cinder_ids")
      #echo "cinder_ids1=[$cinder_ids]"
      cinder_ids=`echo $cinder_ids | sed 's/,/  /g'`
      cinder_boot=""
      cinder_data=""
      #echo "cinder_ids2=[$cinder_ids]"
      for cinder_id in $cinder_ids
      do 
         ret=`cinder show $cinder_id | grep "bootable               |                                                                                                                                   true"`
         if [ $? -eq 0 ];then
           cinder_boot=$cinder_id
         else
           cinder_data=$cinder_data" "$cinder_id
         fi
      done      
      cinder_ids="$cinder_boot  $cinder_data"      
      #echo cinder list=[$cinder_ids]
      IFS="$IFS_IP"
   fi
      
   #ip_list=`echo $net_list | awk -F ''`
   echo "${vm_id} \$ ${vm_name} \$ ${flavor_id} \$ ${ips} \$ ${cinder_ids}" >> $filename
   #echo >> $filename
   echo "${vm_id} \$ ${vm_name} \$ ${flavor_id} \$ ${ips} \$ ${cinder_ids}"
   #echo
done
IFS="$IFS_OLD"
