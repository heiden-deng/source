#!/bin/bash

exec_name="$0"
usage()
{
   echo "${exec_name} ip iscsi_cfg"
   exit 1
}
if [ $# -lt 2 ];then
  usage $0
fi
ip="$1"
iscsi_cfg="$2"

iscsiadm -m discovery -t sendtargets -p $ip
echo "set setting"
while read line
do
   iqn=`echo $line | awk -F' ' '{print $2}'`
   username=`echo $line | awk -F' ' '{print $3}'`
   passwd=`echo $line | awk -F' ' '{print $4}'`
   echo "$iqn  $username  $passwd"
   iscsiadm -m node -T $iqn -o update --name node.session.auth.authmethod --value=CHAP 
   iscsiadm -m node -T $iqn --op update --name node.session.auth.username --value=$username
   iscsiadm -m node -T $iqn --op update --name node.session.auth.password --value=$passwd
   echo "login iscsi ..."
   iscsiadm -m node -T $iqn -p $ip -l
   if [ $? -ne 0 ];then
     echo "Warning: login $iqn failed"
   fi
done < $iscsi_cfg

echo "finished" 

