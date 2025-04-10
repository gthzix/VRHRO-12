#!/bin/bash

sudo apt update
sudo apt upgrade -y


sudo apt install -y curl apt-transport-https


curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

sudo dpkg --add-architecture i386


sudo apt update
sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
 sudo dpkg --add-architecture i386
 sudo apt-get update
 sudo apt-get install \
  libgl1-mesa-dri:amd64 \
  libgl1-mesa-dri:i386 \
  libgl1-mesa-glx:amd64 \
  libgl1-mesa-glx:i386 \
  steam-launcher


sudo apt install -y vlc libavcodec-extra libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg -f noninteractive


sudo apt install -y plank


sudo apt install -y wine


sudo apt install -y neofetch


sudo apt install -y git build-essential

sudo apt autoremove -y
sudo apt clean
