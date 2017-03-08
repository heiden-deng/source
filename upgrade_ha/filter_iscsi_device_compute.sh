#!/bin/bash

if [ $# -lt 1 ];then
   echo "$0 iscsi_all_cfg"
   exit 1
fi

iscsi_device_cfg="$1"

hostname=`hostname`
for vmid in `virsh list --all | grep "instance-" | awk '{print $2}'`;
do
    virsh dumpxml $vmid > ${hostname}_${vmid}_filter.xml
    isCinder=`cat ${hostname}_${vmid}_filter.xml | grep "<serial>"` 
    if [ "$isCinder" != "" ];then
        cinder_id=`cat ${hostname}_${vmid}_filter.xml | grep "<serial>" | awk -F'<' '{print $2}' | awk -F'>' '{print $2}'`
        dev_cfg=`cat $iscsi_device_cfg | grep $cinder_id`
        echo "test: $dev_cfg"
        if [ "$dev_cfg" != "" ];then
           echo $dev_cfg >> "${hostname}"_iscsi.txt
        else
           echo "miss cinder id $cinder_id in $iscsi_device_cfg"
        fi
    else
        echo "vm use image,no cinder volume"
    fi
done
