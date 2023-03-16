#!/bin/sh
echo "Cleaning Tor state ..."
sudo service tor@default stop
sudo rm /var/lib/tor/state
sudo service tor@default start
echo "New Tor Guard is on it's way"
sleep 3
sudo journalctl -n 20 -u tor@default --no-pager
echo ""
echo "Done! Wait 1 minute and check if tor is working again"
echo ""
