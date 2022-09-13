#!/bin/sh
# Define directory on target drive here
target="/embassy-data/main"
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
twrite=$(sudo dd if=/dev/zero of=$target/stest conv=fdatasync oflag=direct bs=128k count=8k 2>&1)
twrite=$(echo ${twrite##*s,})
echo " WRITE speed test (direct) = $twrite"
tswrite=$(sudo dd if=/dev/zero of=$target/stest conv=fdatasync bs=128k count=8k 2>&1)
tswrite=$(echo ${tswrite##*s,})
echo " WRITE speed test (cached) = $tswrite"
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
tread=$(dd if=$target/stest of=/dev/null conv=fdatasync bs=128k count=8k 2>&1)
tread=$(echo ${tread##*s,})
echo "  READ speed test (direct) = $tread"
tcread=$(dd if=$target/stest of=/dev/null conv=fdatasync bs=128k count=8k 2>&1)
tcread=$(echo ${tcread##*s,})
echo "  READ speed test (cached) = $tcread (crazy)"
sudo rm -f $target/stest
echo
echo "Done!"
