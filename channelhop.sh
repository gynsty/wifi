#!/bin/bash

if [[ $# -lt 1 ]];then
 echo "Interface in monitor mode must be used as 1.param!"
 exit 1
fi

finish(){
 echo
 echo "K11lled!"
}

trap finish EXIT

echo -n "Hoping on channels 1,6,1. Interface:$1"
while true
do
iwconfig $1 channel 1
sleep 0.4
iwconfig $1 channel 6
sleep 0.4
iwconfig $1 channel 11
done

