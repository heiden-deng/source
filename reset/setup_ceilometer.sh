#!/bin/bash

db_host="hv156"
db_user="root"
db_passwd="123456"
db_name="ceilometer"
sv_user="ceilometer"
sv_passwd="123456"

log()
{
   tag=`date`
   echo "[$tag] $1"
}

read -p "Are you sure to Reinit ceilometer,it will drop ceilometer DB(y/n):" bcontiune
if [ "x$bcontinue" == "xy" ];then
   echo "exit scirpt"
   exit 1
fi


echo "Before delete service:"
openstack service list

for i in `openstack service list | grep ceilometer | awk '{print $2}'`;
do
    echo "delete service id=$i"
    openstack service delete $i
done

echo "after delete service:"
openstack service list


echo "create ceilometer service and user,endpoint"
source admin-openrc.sh
openstack user create --domain default --password 123456 ceilometer
openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "Telemetry" metering
openstack endpoint create --region RegionOne metering public http://10.6.118.143:8777
openstack endpoint create --region RegionOne metering internal http://10.6.118.143:8777
openstack endpoint create --region RegionOne metering admin http://10.6.118.143:8777



log "install ceilometer component"
yum install openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification openstack-ceilometer-central openstack-ceilometer-alarm python-ceilometerclient



log "start ceilometer service"
systemctl restart openstack-ceilometer-api.service openstack-ceilometer-notification.service openstack-ceilometer-central.service openstack-ceilometer-collector.service openstack-ceilometer-alarm-evaluator.service openstack-ceilometer-alarm-notifier.service openstack-glance-api.service openstack-glance-registry.service openstack-nova-compute.service openstack-ceilometer-compute.service openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service

log "setup ceilometer service finish"




