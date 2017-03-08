#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#
#  This script create swift storage
#
#  2016-07-16: create
#




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

source /root/admin-openrc

my_ip=`crudini --get $setup_file cluster my_ip`


controller_ip=`crudini --get $setup_file cluster cluster_vip`
service_passwd=`crudini --get $setup_file swift service_passwd`

devices=`crudini --get $setup_file swift devices`
sync_dirs=`crudini --get $setup_file swift sync_dirs`


log "install rsync software"
yum install -y xfsprogs rsync

log "create filesystem on $devices"
read -p "Are you sure continue,THIS WILL CAUSE ${devices} DATA MISS(y/n):" bcontinue
if [ "x${bcontinue}" != "xy" ];then
   echo "exit "
   exit 1
fi

OLD_IFS=”$IFS”
IFS=”,”
devices_ary=($devices)
num=${#devices_ary[@]}
IFS=”$OLD_IFS”

for((i=0;i<num;i++))
{
  device=${devices_ary[$i]}
  ret=`ls -l /dev/$device`
  if [ $? -ne 0 ];then
     log "$device CANNOT BE FOUND,ERROR"
     exit
  fi
}

for((i=0;i<num;i++))
{
  device=${devices_ary[$i]}
  mnt_dir=${sync_dirs}/${device}
  mkfs.xfs /dev/${device}
  mkdir -p $mnt_dir
  echo "/dev/${device} ${mnt_dir} xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >>  /etc/fstab
  mount $mnt_dir
}

#chmod a+w -R ${sync_dirs}
restorecon -R ${sync_dirs}
log "config sync"
cp -f $script_dir/rsyncd.conf  /etc/rsyncd.conf

sed_exp_ip="s/MANAGEMENT_INTERFACE_IP_ADDRESS/${my_ip}/g"
sed -i $sed_exp_ip /etc/rsyncd.conf

sed_exp_num="s/MAX_CONNECTION/${num}/g" 
sed -i $sed_exp_num /etc/rsyncd.conf

sed_exp_sync="s#SYNC_DIRS#${sync_dirs}#g" 
sed -i $sed_exp_sync /etc/rsyncd.conf

log "start rsync service"
systemctl enable rsyncd.service
systemctl start rsyncd.service


log "install swift storage software"
yum install -y openstack-swift-account openstack-swift-container openstack-swift-object

log "config account-server"
cp -f $script_dir/account-server.conf /etc/swift/account-server.conf
chown root:swift /etc/swift/account-server.conf
crudini --set /etc/swift/account-server.conf DEFAULT bind_ip $my_ip
crudini --set /etc/swift/account-server.conf DEFAULT devices $sync_dirs


log "config container-server"
cp -f $script_dir/container-server.conf /etc/swift/container-server.conf
chown root:swift /etc/swift/container-server.conf 
crudini --set /etc/swift/container-server.conf DEFAULT bind_ip $my_ip
crudini --set /etc/swift/container-server.conf DEFAULT devices $sync_dirs

log "config object-server"
cp -f $script_dir/object-server.conf  /etc/swift/object-server.conf 
chown root:swift /etc/swift/object-server.conf 
crudini --set /etc/swift/object-server.conf DEFAULT bind_ip $my_ip 
crudini --set /etc/swift/object-server.conf DEFAULT devices $sync_dirs 

chown -R swift:swift $sync_dirs
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod a+w -R /var/cache/swift
log "finished"



