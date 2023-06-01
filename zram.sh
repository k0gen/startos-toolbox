#!/bin/sh

# Check whether the script is being run with elevated privileges if not use sudo
if [ "$(id -u)" != 0 ]; then
  echo "Running with sudo..."
  sudo sh "$0" "$@"
  exit 0
fi

case "$1" in
    start)
        # Load the zram kernel module
        modprobe zram

        # Configure the zram device
        echo lz4 > /sys/block/zram0/comp_algorithm
        echo 1024M > /sys/block/zram0/disksize

        # Prepare the zram device and enable it
        mkswap /dev/zram0
        swapon -p 5 /dev/zram0
        ;;
    stop)
        # Disable the zram device and remove it
        swapoff /dev/zram0
        echo 1 > /sys/block/zram0/reset
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

exit 0
