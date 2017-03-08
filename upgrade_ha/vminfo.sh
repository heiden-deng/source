#!/bin/bash
echo "start...,wait"
source /root/admin-openrc
nova list > nova_lst.txt
neutron port-list > port_lst.txt
neutron net-list > net_lst.txt
IFS_OLD=$IFS
IFS=$'\n'
for vm in `nova list | grep -v "\-\-\-\-\-" | grep -v "Power State" | awk '{print $2" "$4" "$12}'`;
do
    IFS=$IFS_OLD
    id=`echo $vm | awk '{print $1}'`
    name=`echo $vm | awk '{print $2}'`
    ip=`echo $vm | awk '{print $3}' | awk -F'=' '{print $2}' | sed 's/;//'`
    #echo id=$id" "name=$name" "ip=$ip
    nova show $id > ${id}.txt
    flavor_name=`nova show $id | grep "| flavor" | awk '{print $4}'`
    flavor_id=`nova flavor-list | grep "$flavor_name" | awk '{print $2}'`
    inst_name=`nova show $id | grep "OS-EXT-SRV-ATTR:instance_name"`
    image_info=`nova show $id | grep "no image supplied"`
    if [ "$image_info" != "" ];then
       cinder_id=`nova show $id | grep "os-extended-volumes:volumes_attached" | awk -F'"'  '{print $4}'`
    else
       cinder_id="vm start from image"
    fi
    port_info=`neutron port-list | grep $ip`
    port_id=`echo $port_info | awk '{print $2}'`
    port_mac=`echo $port_info | awk '{print $5}'`
    port_subnet=`echo $port_info | awk '{print $8}' | awk -F'"' '{print $2}'`
    port_net=`neutron net-list | grep  $port_subnet | awk '{print $2" "$4}'`
    
    echo "VM Info: $id"
    echo "    name=$name"
    echo "    ip=$ip,  mac=$port_mac,  port_id=$port_id"
    echo "    flavor name=\"$flavor_name\",  flavor_id=$flavor_id"
    echo "    cinder id= $cinder_id"
    echo "    subnet= $port_subnet,  net=$port_net"
    
 
    IFS=$'\n'
done
IFS=$IFS_OLD
