#!/bin/bash

uptime=$(cat /proc/uptime | awk '{print $1}' | awk -F'.' '{print $1}')
if [ $uptime -lt 120 ];then
   echo "lb schedule will run after system boot exceed 120s"
   exit 0
fi

bInc="false"
bDec="false"


cpuUsage()
{
	CPULOG_1=$(awk '/\<cpu\>/{print $2" "$3" "$4" "$5" "$6" "$7" "$8}' /proc/stat)
	SYS_IDLE_1=$(echo $CPULOG_1 | awk '{print $4}')
	Used=$(echo $CPULOG_1 | awk '{print $1+$2+$3}')
	Total=$(echo $CPULOG_1 | awk '{print $1+$2+$3+$4}')

	tmp_rate=`expr $Used/$Total | bc -l`
	SYS_Rate=`expr $tmp_rate*100 | bc -l`

	#display
	Disp_SYS_Rate=`expr "scale=3; $SYS_Rate/1" |bc`
        echo $Disp_SYS_Rate
}

load1()
{
   one_load_value=$(uptime | awk '{print $8}' | cut -d ',' -f1)
   echo ${one_load_value}
}


#t1=$(cpuUsage)
t1=$(load1)
echo $t1
if [ $(echo "$t1 > 0.60" | bc) -eq 1 ];then
    bInc="true"
fi

if [ $(echo "$t1 < 0.10" | bc) -eq 1 ];then
    bDec="true"
fi


sleep 3

#t2=$(cpuUsage)
t2=$(load1)
echo $t2
if [ "$bInc" == "true" -a $(echo "$t2 > 0.60" | bc) -eq 1 ];then
    bInc="true"
else
    bInc="false"
fi

if [ "$bDec" == "true" -a $(echo "$t2 < 0.10" | bc) -eq 1 ];then
    bDec="true"
else
    bDec="false"
fi

echo "bInc=$bInc,bDec=$bDec"
source /root/admin-openrc

if [ "$bInc" == "true" ];then
    #ret=$(openstack user list | grep "LBTESTTAG")
    #openstack user create --domain default --password 123456 LBTESTTAG
    vmNum=`nova list | grep -v "lb-vm-app0" | grep lb-vm-app | grep "Shutdown" | wc -l`
    if [ $vmNum -eq 0 ];then
        echo "create vm"
        vmIndex=`nova list | grep -v "lb-vm-app0" | grep lb-vm-app | wc -l`
        nova boot --flavor 2 --image c6d73faa-d5d5-4f28-8429-26b032ff48f3 --nic net-id=b78ce100-f188-439f-859a-cec7f738a37a "lb-vm-app${vmIndex}"
    else   
    	for vmid in `nova list | grep -v "lb-vm-app0" | grep lb-vm-app | grep "Shutdown" | awk -F'|' '{print $2}' | cut -d' ' -f2`;
    	do
       	    echo "start vm $vmid"
            nova start $vmid
            break
        done
    fi
    #vm_nums=`nova list | grep lb-vm-app | grep "Shutdown" | wc -l`
    #bNeedCreate="false"
    #if [$vm_nums -ge 1 ];then
    #    bNeedCreate="true"
    #fi

fi

if [ "$bDec" == "true" ];then
    for vmid in `nova list | grep -v "lb-vm-app0" | grep lb-vm-app | grep "Running" | awk -F'|' '{print $2}' | cut -d' ' -f2`;
    do
       echo "stop vm $vmid"
       nova stop $vmid
       break;
    done
fi


