#!/bin/bash

help(){
  echo
  echo "USAGE:"
  echo "Put interface into MONITOR mode!"
  echo "1. Interface. "
  echo "2. Logfile."
  echo "3. Enable channel hoping."
  echo "4. Sorting timeout in seconds. If none sorting in real time."
  echo 
  echo "USAGE: bash probes.sh wlan3 /tmp/dumpcap2.log 0 3 | grep 08:ed:b9:31:b2:e7"
  exit 1
}

hoping(){
 iwconfig $1 channel 1
 sleep 0.4
 iwconfig $1 channel 6
 sleep 0.4
 iwconfig $1 channel 11
}

finish(){

 if [[ $HOPING ]];then
   kill $HOPING_PID
 echo
 echo "Channel hoping was kill33d."
 fi

 echo "Exiting...";
}

gettime(){
date +'%d-%m-%Y_%H:%M'
}

trap finish EXIT

if [[ $# -le 2 ]];then
  help
fi

if [[ ! -z $3 ]];then
  HOPING=1
fi

if [[ ! -z $4 ]];then
  TIMEOUT=$4
else
  TIMEOUT=1
fi

INT=$1
LOGFILE=$2

# dumpcap - require pcaputils
dumpcap -i $INT -w $LOGFILE 2>/dev/null &

if [[ $HOPING ]];then 
 bash channelhop.sh $INT >/dev/null & 
 HOPING_PID=$!
 echo 
 echo "Hoping on channels: 1,6,11. Channelhop PID is:$!"
fi

# sleep 2

# This command saves all probes into logfile.txt 
while true
do
echo
curtime=$(gettime)
echo "Time is: $curtime" 
echo "Found probing clients:"
tshark -r $LOGFILE -Y '(wlan.fc.type_subtype eq 04) && ! (wlan_mgt.ssid == "")' -T fields -e wlan.sa -e wlan_mgt.ssid -e frame.time 2>/dev/null | sort -k 1,1 -u | tee -a probes.log
sleep $TIMEOUT
done

