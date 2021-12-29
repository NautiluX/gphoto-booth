#!/bin/bash

sudo ln -s gphoto_booth.sh /usr/local/bin/
ln -s webcamloop.desktop ~/.config/autostart/
sudo ln -s v4l2.confg /etc/modprobe.d/

sudo apt install gphoto2 obs-studio v4l2loopback-dkms
modprobe v4l2loopback devices=2 exclusive_caps=1 video_nr=6,7 card_label="OBS Virtual Camera","EOS 500D"

wget https://github.com/obsproject/obs-websocket/releases/download/4.9.1/obs-websocket_4.9.1-1_amd64.deb
sudo dpkg -i obs-websocket_4.9.1-1_amd64.deb

wget https://github.com/muesli/obs-cli/releases/download/v0.4.0/obs-cli_0.4.0_linux_amd64.deb
sudo dpkg -i obs-cli_0.4.0_linux_amd64.deb

ln -s obs-scene.json ~/.config/obs-studio/basic/scenes/Booth.json


