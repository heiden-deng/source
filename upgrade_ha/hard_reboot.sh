#!/bin/bash

for vm_uuid in `nova list | grep "ERROR" | awk '{print $2}'`
do
   nova reset-state --active $vm_uuid
   sleep 2
   nova reboot --hard $vm_uuid
   sleep 5
   echo "hard reboot vm $vm_uuid"
done
