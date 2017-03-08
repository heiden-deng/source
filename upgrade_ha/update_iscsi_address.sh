#!/bin/bash

if [ $# -lt 2 ];then
   echo "$0 old_ip new_ip"
   exit 1
fi
old_ip="$1"
new_ip="$2"

hostname=`hostname`
for vmid in `virsh list --all | grep "instance-" | awk '{print $2}'`;
do
    echo "modify ${vmid} ...${old_ip} -> ${new_ip}"    
    virsh dumpxml $vmid > ${hostname}_${vmid}_ex.xml
    cp -f ${hostname}_${vmid}_ex.xml  ${hostname}_${vmid}_ex.bak.xml
    echo "undefine vm."
    virsh undefine $vmid
    echo "modify config"
    sed_exp="s/${old_ip}/${new_ip}/g"
    sed -i $sed_exp ${hostname}_${vmid}_ex.xml
    echo "define vm" 
    virsh define ${hostname}_${vmid}_ex.xml 
done
