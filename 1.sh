#!/bin/bash

# Script de instalación para glava, htop, cava, git y curl en Fedora/Nobara
# Autor: Asistente
# Fecha: $(date)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si el usuario es root
if [[ $EUID -eq 0 ]]; then
    print_warning "Este script no debe ejecutarse como root. Usando sudo cuando sea necesario."
fi

# Actualizar el sistema
print_status "Actualizando el sistema..."
sudo dnf update -y

# Instalar EPEL repository si no está presente
print_status "Verificando repositorio EPEL..."
if ! dnf repolist | grep -q "epel"; then
    print_status "Instalando repositorio EPEL..."
    sudo dnf install -y epel-release
else
    print_status "EPEL ya está instalado"
fi

# Instalar RPM Fusion repositories si no están presentes
print_status "Verificando repositorios RPM Fusion..."
if ! dnf repolist | grep -q "rpmfusion"; then
    print_status "Instalando repositorios RPM Fusion..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    print_status "RPM Fusion ya está instalado"
fi

# Actualizar la caché de paquetes
print_status "Actualizando caché de paquetes..."
sudo dnf makecache

# Instalar los paquetes principales
print_status "Instalando paquetes principales..."
