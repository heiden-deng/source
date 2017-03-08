#!/bin/bash

echo "Are you sure logout all iscsi and delete session?(y/n):"
read bsure
if [ "$bsure" != "y" ];then
   exit 1
fi
IFS_OLD=$IFS
IFS=$'\n'
for tgt in `iscsiadm -m node session`;
do
    #echo $tgt
    ip=`echo $tgt | awk -F':' '{print $1}'`
    iqn=`echo $tgt | awk -F' ' '{print $2}'`
    iscsiadm -m node -T $iqn -p $ip -u
    iscsiadm -m discovery -o delete  -p $ip
    echo "deleted iscsi session "$ip" "$iqn
done
IFS=$IFS_OLD
echo "finished"

