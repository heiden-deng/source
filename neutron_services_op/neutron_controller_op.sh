#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script manage controller node neutron services
#
#  2016-06-24: create
#

usage()
{
  echo "Usage:"
  echo " $1 status|stop|start"
  exit 1
}

if [ $# -lt 1 ];then
  usage "$0"
fi


op="$1"

systemctl $op neutron-server.service 
