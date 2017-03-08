#!/bin/bash
#
#  Copyright © 2016,BoCloud. All Rights Reserved.
#  Author: heiden.deng(dengjianquan@beyondcent.com)
#    
#  This script print usage
#
#  2016-06-18: create
#

echo ""
echo ""
echo ""
echo "====================================================================="
echo ""
usage="  欢迎您使用本安装程序来安装OpenStack Liberty RDO,有任何使用问题，请联系heiden deng(dengjianquan@beyondcent.com)\n
       在执行本安装程序之前，需要确保已经对服务器进行配置，包括hosts，chrony，数据库，yum源，rabbitmq,mongodb等服务\n
       并配置好br-ex以及br-tun，详细过程可以参看相关文档，当前支持配置neutron工作在bridge或者dvr模式，需要执行对应的\n
       脚本，两者二选一."

echo -e $usage

echo ""
echo ""
echo "====================================================================="
echo ""
