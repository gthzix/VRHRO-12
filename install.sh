#!/bin/bash

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

# Función para mostrar mensaje con efecto de escritura
typewriter() {
    local text="$1"
    for ((i=0; i<${#text}; i++)); do
        printf "\033[36m%s\033[0m" "${text:$i:1}"
        sleep 0.05
    done
    printf "\n"
}

clear
echo -e "\033[33m"
cat << "EOF"
  ___ _ _        _   _              
 / __| (_)___ __| |_(_)___ _ _  ___ 
| (__| | / -_) _|  _| / _ \ ' \(_-<
 \___|_|_\___\__|\__|_\___/_||_/__/
EOF
echo -e "\033[0m"

typewriter "Iniciando instalación de paquetes esenciales..."
echo ""

# Actualizar el sistema
printf "\033[32m[1/10] Actualizando el sistema...\033[0m"
sudo apt update > /dev/null 2>&1 &
spinner
sudo apt upgrade -y > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Sistema actualizado\033[0m"

# Instalar dependencias
printf "\033[32m[2/10] Instalando dependencias...\033[0m"
sudo apt install -y curl apt-transport-https > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Dependencias instaladas\033[0m"

# Instalar kernel Liquorix
printf "\033[32m[3/10] Instalando kernel Liquorix...\033[0m"
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Kernel Liquorix instalado\033[0m"

# Configurar arquitectura 32-bit
printf "\033[32m[4/10] Configurando soporte 32-bit...\033[0m"
sudo dpkg --add-architecture i386 > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Soporte 32-bit configurado\033[0m"

# Instalar Steam
printf "\033[32m[5/10] Instalando Steam...\033[0m"
sudo apt update > /dev/null 2>&1 &
spinner
sudo apt install -y steam > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Steam instalado\033[0m"

# Instalar VLC y codecs
printf "\033[32m[6/10] Instalando VLC y codecs...\033[0m"
sudo apt install -y vlc libavcodec-extra libdvd-pkg > /dev/null 2>&1 &
spinner
sudo dpkg-reconfigure libdvd-pkg > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ VLC y codecs instalados\033[0m"

# Instalar Plank
printf "\033[32m[7/10] Instalando Plank...\033[0m"
sudo apt install -y plank > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Plank instalado\033[0m"

# Instalar Wine
printf "\033[32m[8/10] Instalando Wine...\033[0m"
sudo apt install -y wine > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Wine instalado\033[0m"

# Instalar Neofetch
printf "\033[32m[9/10] Instalando Neofetch...\033[0m"
sudo apt install -y neofetch > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Neofetch instalado\033[0m"

# Instalar paquetes adicionales
printf "\033[32m[10/10] Instalando paquetes adicionales...\033[0m"
sudo apt install -y git build-essential > /dev/null 2>&1 &
spinner
sudo apt autoremove -y > /dev/null 2>&1 &
spinner
sudo apt clean > /dev/null 2>&1 &
spinner
echo -e "\033[32m✓ Paquetes adicionales instalados\033[0m"

# Animación final
echo -e "\n\033[33m"
for i in {1..3}; do
    for s in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
        printf "\rPreparando resultado final... %s " "$s"
        sleep 0.1
    done
done
echo -e "\033[0m"

# Mostrar arte ASCII de "hacked" (broma)
echo -e "\n\033[31m"
cat << "EOF"
░█▀▀░█▀█░█▀▄░█▀▀░█▀▀░▀█▀░█▀▀░█▀▄
░█░░░█░█░█▀▄░█▀▀░▀▀█░░█░░█▀▀░█▀▄
░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░▀
EOF
echo -e "\033[0m"

# Mostrar información del sistema
echo -e "\n\033[35mResumen de la instalación:\033[0m"
neofetch --off --color_blocks off | grep -v "██" | sed '/^$/d'

# Mensaje final con efecto de máquina de escribir
typewriter "¡Instalación completada con éxito!"
typewriter "Nota: El mensaje de 'hacked' era solo una broma :)"
