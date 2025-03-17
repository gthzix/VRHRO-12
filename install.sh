#!/bin/bash

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar curl y otros paquetes necesarios
sudo apt install -y curl apt-transport-https

# Instalar el kernel Liquorix
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

# Habilitar arquitectura de 32 bits para Steam
sudo dpkg --add-architecture i386

# Instalar Steam
sudo apt update
sudo apt install -y steam

# Instalar VLC y codecs adicionales
sudo apt install -y vlc libavcodec-extra libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg

# Instalar Plank (dock ligero)
sudo apt install -y plank

# Instalar Wine
sudo apt install -y wine

# Instalar Neofetch
sudo apt install -y neofetch

# Instalar otros paquetes útiles (opcional)
sudo apt install -y git build-essential

# Limpiar paquetes innecesarios
sudo apt autoremove -y
sudo apt clean

