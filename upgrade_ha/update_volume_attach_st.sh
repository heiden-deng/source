#!/bin/bash

if [ $# -lt 4 ];then
    echo "Usage: $0 db_user db_passwd db_host volume_uuid"
    exit 1
fi
db_user="$1"
db_passwd="$2"
db_host="$3"
volume_uuid="$4"
mysql -u$db_user -p$db_passwd -h $db_host -e "update cinder.volumes set attach_status='detached',status='available' where id ='$volume_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "update cinder.volume_attachment set attach_status='detached' where volume_id ='$volume_uuid';"
mysql -u$db_user -p$db_passwd -h $db_host -e "delete from nova.block_device_mapping where not deleted and volume_id='$volume_uuid';"
