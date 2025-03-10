#!/bin/bash
#
#      simple script to create a server ip address list
#
#      Mark Luethke
#      24. Berurary 2025
#
#
######

#      VARIABLES
#      implement fallback values
## 

net1=1
net2=1
net3=1
net4=1

name="notebook"
net="123.45.67."
for ip in $( seq 1 255 ); do {
    sleep 1; # be kind to the server, unauthorized user
    text="$( nslookup $net$ip 2>&1 | grep "$name" )";
    if [ -z "$text" ]; then continue; fi;
    echo "$text";
}; done
