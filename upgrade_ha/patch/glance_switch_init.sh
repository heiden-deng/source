#!/bin/bash
for lv in `/usr/sbin/lvscan | grep "glance" | grep "inactive" |awk -F"'" '{print $2}'`;do
   lvchange -a y ${lv}
done
