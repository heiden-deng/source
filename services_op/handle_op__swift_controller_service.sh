#!/bin/bash

action=$1


systemctl $action openstack-swift-proxy.service memcached.service 


