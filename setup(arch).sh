#!/bin/bash

# Función para mostrar una barra de progreso
progress() {
    local total_steps=$1
    local current_step=$2
    local message=$3
    local percentage=$((100 * current_step / total_steps))
    printf "\r[%-50s] %d%% %s" $(printf "#%.0s" $(seq 1 $((percentage / 2)))) $percentage "$message"
}

# Total de pasos en el script
total_steps=10
current_step=0

# Actualizar el sistema
progress $total_steps $((++current_step)) "Actualizando el sistema..."
sudo pacman -Syu --noconfirm > /dev/null 2>&1

# Instalar curl y otros paquetes básicos
progress $total_steps $((++current_step)) "Instalando paquetes básicos..."
sudo pacman -S --noconfirm curl base-devel git > /dev/null 2>&1

# Instalar yay (AUR helper) si no está instalado
if ! command -v yay &> /dev/null; then
    progress $total_steps $((++current_step)) "Instalando yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay > /dev/null 2>&1
    cd /tmp/yay
    makepkg -si --noconfirm > /dev/null 2>&1
    cd ~
else
    progress $total_steps $((++current_step)) "yay ya está instalado, omitiendo..."
fi

# Instalar el kernel Liquorix desde el AUR
progress $total_steps $((++current_step)) "Instalando el kernel Liquorix..."
yay -S --noconfirm linux-liquorix linux-liquorix-headers > /dev/null 2>&1

# Habilitar arquitectura de 32 bits para Steam
progress $total_steps $((++current_step)) "Habilitando soporte para 32 bits..."
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
sudo pacman -Sy --noconfirm > /dev/null 2>&1

# Instalar Steam
progress $total_steps $((++current_step)) "Instalando Steam..."
sudo pacman -S --noconfirm steam > /dev/null 2>&1

# Instalar VLC y codecs adicionales
progress $total_steps $((++current_step)) "Instalando VLC y codecs..."
sudo pacman -S --noconfirm vlc libdvdcss > /dev/null 2>&1

# Instalar Plank (dock ligero)
progress $total_steps $((++current_step)) "Instalando Plank..."
sudo pacman -S --noconfirm plank > /dev/null 2>&1

# Instalar Wine
progress $total_steps $((++current_step)) "Instalando Wine..."
sudo pacman -S --noconfirm wine > /dev/null 2>&1

# Instalar Neofetch
progress $total_steps $((++current_step)) "Instalando Neofetch..."
sudo pacman -S --noconfirm neofetch > /dev/null 2>&1

# Limpiar paquetes innecesarios
progress $total_steps $((++current_step)) "Limpiando paquetes innecesarios..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) > /dev/null 2>&1
sudo pacman -Scc --noconfirm > /dev/null 2>&1

# Finalización
progress $total_steps $total_steps "Instalación completada!"
echo -e "\n¡Todo listo! Reinicia el sistema para cargar el kernel Liquorix."