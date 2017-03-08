#!/bin/bash

# Purpose of the script
# Everytime a service wants to be do 'something' it has to retrieve an autentication token
# Nova/Glance/Cinder services are manage by Pacemaker and monitor functions (from the RA) ask for a token every 10 sec
# There is no cleanup procedure nor periodical task running to delete expire token

mysql_user=keystone
mysql_password=123456
mysql_host=192.168.1.215
mysql=$(which mysql)

logger -t keystone-cleaner "Starting Keystone 'token' table cleanup"

logger -t keystone-cleaner "Starting token cleanup"
mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; DELETE FROM token WHERE NOT DATE_SUB(CURDATE(),INTERVAL 2 DAY) <= expires;'
valid_token=$($mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; SELECT * FROM token;' | wc -l)
logger -t keystone-cleaner "Finishing token cleanup, there is still $valid_token valid tokens..."

exit 0
