#!/bin/sh

sudo apt update
sudo apt install --no-install-recommends -y xserver-xorg xserver-xorg-legacy x11-xserver-utils xinit firefox-esr matchbox-window-manager
cat << S9K > /home/start9/kiosk.sh
#!/bin/sh
matchbox-window-manager -use_titlebar no &
firefox --kiosk http://$(hostname).local
S9K
chmod +x kiosk.sh
sudo sed -i 's/=console/=anybody/g' /etc/X11/Xwrapper.config
xinit /home/start9/kiosk.sh
