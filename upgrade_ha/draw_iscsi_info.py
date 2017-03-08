#!/usr/bin/env python
import sys
import json


if len(sys.argv) < 2:
    print sys.argv[0] + " saveconfig  outfile"
    sys.exit(1)

save_config = sys.argv[1]
out_file = sys.argv[2]


fo = open(out_file,'w')
fi = open(save_config,'r')

ic = json.load(fi)

num = len(ic["storage_objects"])
storages = ic["storage_objects"]
targets = ic["targets"]
for i in range(num):
    dev = storages[i]["dev"]
    iqn = storages[i]["name"]
    username = targets[i]["tpgs"][0]["node_acls"][0]["chap_userid"]
    passwd = targets[i]["tpgs"][0]["node_acls"][0]["chap_password"]
    fo.write(dev + " " + iqn + " " + username + "  " + passwd + "\n")

fo.close()
