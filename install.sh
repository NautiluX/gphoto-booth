#!/bin/bash

sudo ln -s `pwd`/gphoto_booth.sh /usr/local/bin/
sudo ln -s `pwd`/v4l2.conf /etc/modprobe.d/

sudo apt install gphoto2 obs-studio v4l2loopback-dkms ffmpeg
if ! grep v4l2loopback /etc/modules; then
 sudo echo v4l2loopback >> /etc/modules
fi
sudo modprobe v4l2loopback devices=1 exclusive_caps=1 video_nr=7 card_label="DSLR"

wget https://github.com/obsproject/obs-websocket/releases/download/4.9.1/obs-websocket_4.9.1-1_amd64.deb
sudo dpkg -i obs-websocket_4.9.1-1_amd64.deb

wget https://github.com/muesli/obs-cli/releases/download/v0.4.0/obs-cli_0.4.0_linux_amd64.deb
sudo dpkg -i obs-cli_0.4.0_linux_amd64.deb

mkdir -p ~/.config/obs-studio/basic/scenes
ln -s `pwd`/obs-scene.json ~/.config/obs-studio/basic/scenes/Booth.json


