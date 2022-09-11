#!/bin/sh
echo
echo " embassyOS Disk Speed Test"
echo
echo "Found:"
sudo lshw -class disk -class volume | grep -Ev '*-disk|description|physical|bus|logical|version|serial|size|capabilities'
echo "testing ..."
twrite=$(sudo dd if=/dev/zero of=/embassy-data/main/stest oflag=direct bs=128k count=16k 2>&1)
twrite=$(echo ${twrite##*s,})
echo " WRITE speed test = $twrite"
tread=$(dd if=/embassy-data/main/stest of=/dev/null bs=128k count=16k 2>&1)
tread=$(echo ${tread##*s,})
echo " READ speed test = $tread"
sudo rm -f /embassy-data/main/stest
echo
echo "Done!"
