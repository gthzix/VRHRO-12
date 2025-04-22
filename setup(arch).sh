#!/bin/bash

# Actualizar el sistema (silenciosamente)
sudo pacman -Syu --noconfirm >/dev/null 2>&1

# Instalar dependencias necesarias para el script de Liquorix
sudo pacman -S --noconfirm curl base-devel git >/dev/null 2>&1

# Instalar yay (AUR helper) si no está instalado
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay >/dev/null 2>&1
    cd /tmp/yay
    makepkg -si --noconfirm >/dev/null 2>&1
    cd ~
fi

# Instalar el kernel Liquorix usando el método oficial
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash >/dev/null 2>&1

# Habilitar arquitectura de 32 bits
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf >/dev/null 2>&1
sudo pacman -Sy --noconfirm >/dev/null 2>&1

# Instalar los paquetes principales (silenciosamente)
sudo pacman -S --noconfirm steam vlc libdvdcss plank wine neofetch >/dev/null 2>&1

# Limpieza silenciosa
sudo pacman -Rns --noconfirm $(pacman -Qdtq) 2>/dev/null
sudo pacman -Scc --noconfirm >/dev/null 2>&1