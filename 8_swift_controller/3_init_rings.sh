#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#
#  This script init swift rings
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

#source /root/admin-openrc

my_ip=`crudini --get $setup_file cluster my_ip`


controller_ip=`crudini --get $setup_file cluster cluster_vip`
service_passwd=`crudini --get $setup_file swift service_passwd`

devices=`crudini --get $setup_file swift devices`
#mnt_dirs=`crudini --get $setup_file swift mnt_dirs`
sync_dirs=`crudini --get $setup_file swift sync_dirs`
stor_ips=`crudini --get $setup_file swift stor_ips`
proxy_servers=`crudini --get $setup_file swift proxy_servers`

partitions=`crudini --get $setup_file swift partitions`
replicas=`crudini --get $setup_file swift replicas`
mov_interval=`crudini --get $setup_file swift mov_interval`

hash_path_suffix=`crudini --get $setup_file swift hash_path_suffix`
hash_path_prefix=`crudini --get $setup_file swift hash_path_prefix`


log "create account ring"

OLD_IFS=”$IFS”
IFS=”,”

devices_ary=($devices)
store_ips_ary=($stor_ips)
proxy_servers_ary=($proxy_servers)

device_num=${#devices_ary[@]}
store_num=${#store_ips_ary[@]}
proxy_num=${#proxy_servers_ary[@]}

IFS=”$OLD_IFS”

pwd_dir=`pwd`
log "step into /etc/swift directory"
cd /etc/swift 

log "create account ring"
swift-ring-builder account.builder create $partitions $replicas $mov_interval
zone_index=1
for((i=0;i<store_num;i++))
{
   for((j=0;j<device_num;j++))
   {
      swift-ring-builder account.builder add --region 1 --zone $zone_index --ip ${store_ips_ary[$i]} --port 6002 --device ${devices_ary[$j]} --weight 100     
      zone_index=$(($zone_index+1))
   }

}

log "verify ring content"
swift-ring-builder account.builder

log "rebalance ring"
swift-ring-builder account.builder rebalance

log "create container ring"
swift-ring-builder container.builder create $partitions $replicas $mov_interval
zone_index=1
for((i=0;i<store_num;i++))
{
   for((j=0;j<device_num;j++))
   {
      swift-ring-builder container.builder add --region 1 --zone $zone_index --ip ${store_ips_ary[$i]} --port 6001 --device ${devices_ary[$j]} --weight 100     
      zone_index=$(($zone_index+1))
   }

}

log "verify ring content"
swift-ring-builder container.builder


log "rebalance ring"
swift-ring-builder container.builder rebalance

log "create object ring"
swift-ring-builder object.builder create $partitions $replicas $mov_interval
zone_index=1
for((i=0;i<store_num;i++))
{
   for((j=0;j<device_num;j++))
   {
      swift-ring-builder object.builder add --region 1 --zone $zone_index --ip ${store_ips_ary[$i]} --port 6000 --device ${devices_ary[$j]} --weight 100     
      zone_index=$(($zone_index+1))
   }

}

log "verify ring content"
swift-ring-builder object.builder

log "rebalance ring"
swift-ring-builder object.builder rebalance

log "distribute ring configuration files to storage node & proxy service node"

cp -f $script_dir/swift.conf /etc/swift/
chown root:swift /etc/swift/swift.conf
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix $hash_path_suffix
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix $hash_path_prefix


for((i=0;i<store_num;i++))
{
   log "send swift.conf account.ring.gz container.ring.gz object.ring.gz to ${store_ips_ary[$i]}"
   scp swift.conf account.ring.gz container.ring.gz object.ring.gz root@${store_ips_ary[$i]}:/etc/swift
   
   log "change /etc/swift owner to root:swift"
   ssh root@${store_ips_ary[$i]} "chown -R root:swift /etc/swift"
   
   log "enable & start service"
   ssh root@${store_ips_ary[$i]} "systemctl enable openstack-swift-account.service openstack-swift-account-auditor.service openstack-swift-account-reaper.service openstack-swift-account-replicator.service"
   ssh root@${store_ips_ary[$i]} "systemctl start openstack-swift-account.service openstack-swift-account-auditor.service openstack-swift-account-reaper.service openstack-swift-account-replicator.service"
   
   ssh root@${store_ips_ary[$i]} "systemctl enable openstack-swift-container.service openstack-swift-container-auditor.service openstack-swift-container-replicator.service openstack-swift-container-updater.service"
   ssh root@${store_ips_ary[$i]} "systemctl start openstack-swift-container.service openstack-swift-container-auditor.service openstack-swift-container-replicator.service openstack-swift-container-updater.service"
   
   ssh root@${store_ips_ary[$i]} "systemctl enable openstack-swift-object.service openstack-swift-object-auditor.service openstack-swift-object-replicator.service openstack-swift-object-updater.service"
   ssh root@${store_ips_ary[$i]} "systemctl start openstack-swift-object.service openstack-swift-object-auditor.service openstack-swift-object-replicator.service openstack-swift-object-updater.service"
}

for((i=0;i<proxy_num;i++))
{
   log "send swift.conf account.ring.gz container.ring.gz object.ring.gz to ${proxy_servers_ary[$i]}"
   scp swift.conf account.ring.gz container.ring.gz object.ring.gz root@${proxy_servers_ary[$i]}:/etc/swift
   
   log "change /etc/swift owner to root:swift"
   ssh root@${proxy_servers_ary[$i]} "chown -R root:swift /etc/swift"
   
   ssh root@${proxy_servers_ary[$i]} "systemctl enable openstack-swift-proxy.service memcached.service"
   ssh root@${proxy_servers_ary[$i]} "systemctl start openstack-swift-proxy.service memcached.service"

}



cd $pwd_dir
echo "export OS_AUTH_VERSION=3" | tee -a /root/admin-openrc /root/demo-openrc.sh

log "finished"



