#!/bin/bash

exec_name="$0"
usage()
{
   echo "${exec_name} ip iqn username password"
   exit 1
}
if [ $# -lt 1 ];then
  usage $0
fi
ip="$1"
iqn="$2"
username="$3"
passwd="$4"

echo "set setting"
iscsiadm -m discovery -t sendtargets -p $ip
iscsiadm -m node -T $iqn -o update --name node.session.auth.authmethod --value=CHAP 
iscsiadm -m node -T $iqn --op update --name node.session.auth.username --value=$username
iscsiadm -m node -T $iqn --op update --name node.session.auth.password --value=$passwd
echo "prepare login "
iscsiadm -m node -T $iqn -p $ip -l

echo "finished" 

