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
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

# Instalar curl y otros paquetes necesarios
progress $total_steps $((++current_step)) "Instalando curl y dependencias..."
sudo apt install -y curl apt-transport-https > /dev/null 2>&1

# Instalar el kernel Liquorix
progress $total_steps $((++current_step)) "Instalando el kernel Liquorix..."
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash > /dev/null 2>&1

# Habilitar arquitectura de 32 bits para Steam
progress $total_steps $((++current_step)) "Habilitando soporte para 32 bits..."
sudo dpkg --add-architecture i386 > /dev/null 2>&1

# Instalar Steam
progress $total_steps $((++current_step)) "Instalando Steam..."
sudo apt update > /dev/null 2>&1
sudo apt install -y steam > /dev/null 2>&1

# Instalar VLC y codecs adicionales
progress $total_steps $((++current_step)) "Instalando VLC y codecs..."
sudo apt install -y vlc libavcodec-extra libdvd-pkg > /dev/null 2>&1
sudo dpkg-reconfigure libdvd-pkg > /dev/null 2>&1

# Instalar Plank (dock ligero)
progress $total_steps $((++current_step)) "Instalando Plank..."
sudo apt install -y plank > /dev/null 2>&1

# Instalar Wine
progress $total_steps $((++current_step)) "Instalando Wine..."
sudo apt install -y wine > /dev/null 2>&1

# Instalar Neofetch
progress $total_steps $((++current_step)) "Instalando Neofetch..."
sudo apt install -y neofetch > /dev/null 2>&1

# Instalar otros paquetes útiles (opcional)
progress $total_steps $((++current_step)) "Instalando paquetes adicionales..."
sudo apt install -y git build-essential > /dev/null 2>&1

# Limpiar paquetes innecesarios
progress $total_steps $((++current_step)) "Limpiando paquetes innecesarios..."
sudo apt autoremove -y > /dev/null 2>&1
sudo apt clean > /dev/null 2>&1

# Finalización
progress $total_steps $total_steps "Instalación completada!"
echo -e "\n¡no se que poner pero finalizo la instalación."
