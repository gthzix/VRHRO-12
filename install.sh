#!/bin/bash

# Actualizar sistema
sudo apt update
sudo apt upgrade -y

# Instalar dependencias básicas
sudo apt install -y curl apt-transport-https

# Instalar kernel Liquorix
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash

# Configurar soporte para 32 bits
sudo dpkg --add-architecture i386

# Instalar Steam
sudo apt update
sudo apt install -y steam

# Instalar VLC y codecs
sudo apt install -y vlc libavcodec-extra libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg -f noninteractive

# Instalar Plank
sudo apt install -y plank

# Instalar Wine
sudo apt install -y wine

# Instalar Neofetch
sudo apt install -y neofetch

# Instalar herramientas de desarrollo
sudo apt install -y git build-essential

# Limpiar paquetes innecesarios
sudo apt autoremove -y
sudo apt clean
