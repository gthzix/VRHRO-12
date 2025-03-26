#!/bin/bash

# Función para mostrar una barra de progreso en color verde
progress() {
    local total_steps=$1
    local current_step=$2
    local message=$3
    local percentage=$((100 * current_step / total_steps))
    printf "\r\033[32m[%-50s] %d%% %s\033[0m" $(printf "#%.0s" $(seq 1 $((percentage / 2)))) $percentage "$message"
}

# Función para mostrar un spinner animado
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r[%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r    \r"
}

# Total de pasos en el script
total_steps=10
current_step=0

# Actualizar el sistema
progress $total_steps $((++current_step)) "Actualizando el sistema..."
sudo apt update > /dev/null 2>&1 &
spinner
sudo apt upgrade -y > /dev/null 2>&1 &
spinner

# Instalar curl y otros paquetes necesarios
progress $total_steps $((++current_step)) "Instalando curl y dependencias..."
sudo apt install -y curl apt-transport-https > /dev/null 2>&1 &
spinner

# Instalar el kernel Liquorix
progress $total_steps $((++current_step)) "Instalando el kernel Liquorix..."
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash > /dev/null 2>&1 &
spinner

# Habilitar arquitectura de 32 bits para Steam
progress $total_steps $((++current_step)) "Habilitando soporte para 32 bits..."
sudo dpkg --add-architecture i386 > /dev/null 2>&1 &
spinner

# Instalar Steam
progress $total_steps $((++current_step)) "Instalando Steam..."
sudo apt update > /dev/null 2>&1 &
spinner
sudo apt install -y steam > /dev/null 2>&1 &
spinner

# Instalar VLC y codecs adicionales
progress $total_steps $((++current_step)) "Instalando VLC y codecs..."
sudo apt install -y vlc libavcodec-extra libdvd-pkg > /dev/null 2>&1 &
spinner
sudo dpkg-reconfigure libdvd-pkg > /dev/null 2>&1 &
spinner

# Instalar Plank (dock ligero)
progress $total_steps $((++current_step)) "Instalando Plank..."
sudo apt install -y plank > /dev/null 2>&1 &
spinner

# Instalar Wine
progress $total_steps $((++current_step)) "Instalando Wine..."
sudo apt install -y wine > /dev/null 2>&1 &
spinner

# Instalar Neofetch
progress $total_steps $((++current_step)) "Instalando Neofetch..."
sudo apt install -y neofetch > /dev/null 2>&1 &
spinner

# Instalar otros paquetes útiles (opcional)
progress $total_steps $((++current_step)) "Instalando paquetes adicionales..."
sudo apt install -y git build-essential > /dev/null 2>&1 &
spinner

# Limpiar paquetes innecesarios
progress $total_steps $((++current_step)) "Limpiando paquetes innecesarios..."
sudo apt autoremove -y > /dev/null 2>&1 &
spinner
sudo apt clean > /dev/null 2>&1 &
spinner

# Finalización
progress $total_steps $total_steps "Instalación completada!"
echo -e "\n\033[32m¡su pc ha sido comprometido!.\033[0m"

# Mostrar animación final
echo -e "\n\033[33mPreparando animación final...\033[0m"
for i in {1..10}; do
    for s in / - \\ \|; do
        printf "\r\033[35m%s\033[0m Haciendo cosas misteriosas... %d/10" "$s" "$i"
        sleep 0.1
    done
done

echo -e "\n\n\033[31m░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo -e "░░█▀▀░█▀█░█▀▄░█▀▀░█▀▀░▀█▀░█▀▀░█▀▄░░░"
echo -e "░░█░░░█░█░█▀▄░█▀▀░▀▀█░░█░░█▀▀░█▀▄░░░"
echo -e "░░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░▀░░░"
echo -e "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░\033[0m"
echo -e "\033[36m(Esta última parte es solo broma, todo se instaló correctamente)\033[0m"
