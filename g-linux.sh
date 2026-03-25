#!/bin/bash

echo "--- Iniciando configuración de Gaming para Fedora 43 ---"

# 1. Actualización completa del sistema
sudo dnf update -y

# 2. Habilitar repositorios RPM Fusion (Free y Nonfree)
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 3. Habilitar soporte de 32 bits (Crucial para Steam y juegos antiguos)
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome # Opcional, pero útil

# 4. Instalación de Drivers de Video
# Detecta si es NVIDIA, de lo contrario asume Mesa (AMD/Intel)
if lspci | grep -i nvidia > /dev/null; then
    echo "Detectada GPU NVIDIA. Instalando drivers propietarios..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
else
    echo "Instalando soporte completo para AMD/Intel (Mesa)..."
    sudo dnf install -y mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld
fi

# 5. Instalación de Plataformas y Herramientas Base
sudo dnf install -y steam gog-galaxy-tools gamemode mangohud \
    wine-core winetricks heretic-gui-common

# 6. Instalación de Flatpak y Flathub (Muy recomendado para apps de juegos)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.heroicgamelauncher.hgl -y # Heroic para Epic y GOG
flatpak install flathub net.davidotti.bottles -y    # Bottles para ejecutar .exe aislados

# 7. Optimización del Sistema
# Añadir al usuario al grupo de gamemode
sudo usermod -a -G gamemode $(whoami)

echo "--- Instalación finalizada. Por favor, reinicia tu PC. ---"
