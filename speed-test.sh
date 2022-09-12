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
echo
echo "testing ..."
twrite=$(sudo dd if=/dev/zero of=/embassy-data/main/stest conv=fdatasync oflag=direct bs=128k count=8k 2>&1)
twrite=$(echo ${twrite##*s,})
echo " WRITE speed test (direct) = $twrite"
tswrite=$(sudo dd if=/dev/zero of=/embassy-data/main/stest conv=fdatasync bs=128k count=8k 2>&1)
tswrite=$(echo ${tswrite##*s,})
echo " WRITE speed test (cached) = $tswrite"
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
tread=$(dd if=/embassy-data/main/stest of=/dev/null conv=fdatasync bs=128k count=8k 2>&1)
tread=$(echo ${tread##*s,})
echo "  READ speed test (direct) = $tread"
tcread=$(dd if=/embassy-data/main/stest of=/dev/null conv=fdatasync bs=128k count=8k 2>&1)
tcread=$(echo ${tcread##*s,})
echo "  READ speed test (cached) = $tcread (crazy)"
sudo rm -f /embassy-data/main/stest
echo
echo "Done!"
