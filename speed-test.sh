#!/bin/sh
echo
echo " embassyOS Disk Speed Test"
echo
detect=$(lsblk -S -o TRAN,VENDOR,MODEL,SIZE | sed -n '2p' 2>&1)
if [ -z "$detect" ]
then
echo "Found: $(lsblk -d -o TRAN,MODEL,SIZE | sed -n '5p')"
else
echo "Found: $(lsblk -S -o TRAN,VENDOR,MODEL,SIZE | sed -n '2p')"
fi
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
echo
echo "testing ..."
twrite=$(sudo dd if=/dev/zero of=/embassy-data/main/stest oflag=direct bs=128k count=8k 2>&1)
twrite=$(echo ${twrite##*s,})
echo " WRITE speed test = $twrite (direct)"
tswrite=$(sudo dd if=/dev/zero of=/embassy-data/main/stest bs=128k count=8k 2>&1)
tswrite=$(echo ${tswrite##*s,})
echo " WRITE speed test = $tswrite (cached)"
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
tread=$(dd if=/embassy-data/main/stest of=/dev/null bs=128k count=8k 2>&1)
tread=$(echo ${tread##*s,})
echo "  READ speed test = $tread (direct)"
tcread=$(dd if=/embassy-data/main/stest of=/dev/null bs=128k count=1k 2>&1)
tcread=$(echo ${tcread##*s,})
echo "  READ speed test = $tcread (cached - crazy)"
sudo rm -f /embassy-data/main/stest
echo
echo "Done!"
