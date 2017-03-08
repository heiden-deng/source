#!/bin/bash

if [ $# -lt 4 ];then
    echo "Usage: $0 db_user db_passwd db_host vm_uuid"
    exit 1
fi
db_user="$1"
db_passwd="$2"
db_host="$3"
vm_uuid="$4"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;update instances set deleted='1', vm_state='deleted', deleted_at='now()' where uuid='$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_faults where instance_faults.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_id_mappings where instance_id_mappings.uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_info_caches where instance_info_caches.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_system_metadata where instance_system_metadata.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from security_group_instance_association where security_group_instance_association.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from block_device_mapping where block_device_mapping.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from fixed_ips where fixed_ips.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_actions_events where instance_actions_events.action_id in (select id from instance_actions where instance_actions.instance_uuid = '$vm_uuid');"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_actions where instance_actions.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from virtual_interfaces where virtual_interfaces.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instance_extra where instance_extra.instance_uuid = '$vm_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "use nova;delete from instances where instances.uuid = '$vm_uuid';"
