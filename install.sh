sudo apt update && apt upgrade -y

sudo apt install -y firefox

sudo apt install curl -y

curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

sudo nano /etc/apt/preferences.d/nosnap.pref

sudo apt install snapd -y

sudo apt install apt-transport-https curl

sudo curl -fsSLo /usr/share/keyrings/
brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

sudo apt update

sudo apt install steam

steam

sudo apt install vlc

sudo apt install ubuntu-restricted-extras libavcodec-extra libdvd-pkg

sudo dpkg-reconfigure libdvd-pkg