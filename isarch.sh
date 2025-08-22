#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes de estado
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar si un comando tuvo éxito
check_success() {
    if [ $? -eq 0 ]; then
        print_status "$1"
    else
        print_error "$2"
        exit 1
    fi
}

# Verificar que estamos en Arch Linux
if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
    print_error "Este script está diseñado solo para Arch Linux"
    exit 1
fi

# Verificar conexión a internet
print_status "Verificando conexión a internet..."
if ! ping -c 1 archlinux.org &>/dev/null; then
    print_error "No hay conexión a internet. Verifica tu conexión."
    exit 1
fi

# Actualizar el sistema
print_status "Actualizando el sistema..."
sudo pacman -Syu --noconfirm
check_success "Sistema actualizado" "Error al actualizar el sistema"

# Instalar dependencias básicas
print_status "Instalando dependencias básicas..."
sudo pacman -S --noconfirm curl base-devel git wget cmake python python-pip nodejs npm rustup
check_success "Dependencias básicas instaladas" "Error al instalar dependencias"

# Instalar yay (AUR helper) si no está instalado
if ! command -v yay &>/dev/null; then
    print_status "Instalando yay desde AUR..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    check_success "yay instalado correctamente" "Error al instalar yay"
    cd ~
fi

# Instalar el kernel Liquorix
print_status "Instalando kernel Liquorix..."
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
check_success "Kernel Liquorix instalado" "Error al instalar Liquorix"

# Habilitar arquitectura de 32 bits
print_status "Habilitando arquitectura multilib (32 bits)..."
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
sudo pacman -Sy --noconfirm
check_success "Arquitectura multilib habilitada" "Error al habilitar multilib"

# Instalar controladores y codecs multimedia
print_status "Instalando controladores y codecs multimedia..."
sudo pacman -S --noconfirm mesa vulkan-radeon vulkan-intel nvidia nvidia-utils nvidia-settings \
    lib32-mesa lib32-vulkan-radeon lib32-vulkan-intel lib32-nvidia-utils \
    ffmpeg gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    libdvdcss libva-mesa-driver libva-intel-driver intel-media-driver
check_success "Controladores y codecs instalados" "Error al instalar controladores"

# Instalar paquetes principales
print_status "Instalando paquetes principales..."
sudo pacman -S --noconfirm steam vlc plank wine-staging winetricks lutris \
    neofetch htop gparted gnome-disk-utility firefox chromium \
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-dejavu ttf-liberation \
    gimp inkscape kdenlive obs-studio discord
check_success "Paquetes principales instalados" "Error al instalar paquetes principales"

# Instalar herramientas de desarrollo
print_status "Instalando herramientas de desarrollo..."
sudo pacman -S --noconfirm visual-studio-code-bin codeblocks geany \
    jdk-openjdk openjdk-doc openjdk-src maven gradle \
    php apache mariadb postgresql
check_success "Herramientas de desarrollo instaladas" "Error al instalar herramientas de desarrollo"

# Configurar Rust
print_status "Configurando Rust..."
rustup default stable
check_success "Rust configurado" "Error al configurar Rust"

# Instalar paquetes de AUR
print_status "Instalando paquetes desde AUR..."
yay -S --noconfirm google-chrome protonvpn-cli spotify teamviewer \
    anydesk-bin visual-studio-code-insiders-bin
check_success "Paquetes AUR instalados" "Error al instalar paquetes AUR"

# Configurar Wine
print_status "Configurando Wine..."
WINEARCH=win64 WINEPREFIX=~/.wine winecfg -v win10 &>/dev/null &
check_success "Wine configurado" "Error al configurar Wine"

# Limpieza
print_status "Limpiando paquetes no necesarios..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) 2>/dev/null || true
sudo pacman -Scc --noconfirm
check_success "Sistema limpiado" "Error durante la limpieza"

# Configuración final
print_status "Configuración final..."
sudo systemctl enable --now fstrim.timer  # Para SSD
check_success "Timer de trim habilitado" "Error al habilitar trim"

print_status "¡Instalación completada!"
echo ""
print_warning "Recomendaciones:"
echo "- Reinicia el sistema para cargar el nuevo kernel Liquorix"
echo "- Ejecuta 'winetricks' para configurar componentes adicionales de Wine"
echo "- Configura ProtonVPN con 'protonvpn-cli login' y 'protonvpn-cli connect'"
