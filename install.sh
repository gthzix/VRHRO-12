#!/bin/bash

sudo apt update
sudo apt upgrade -y


sudo apt install -y curl apt-transport-https


curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

sudo dpkg --add-architecture i386


sudo apt update
sudo apt install -y steam


sudo apt install -y vlc libavcodec-extra libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg -f noninteractive


sudo apt install -y plank


sudo apt install -y wine


sudo apt install -y neofetch


sudo apt install -y git build-essential

sudo apt autoremove -y
sudo apt clean
