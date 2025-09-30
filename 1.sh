#!/bin/bash

# Script de actualización SIN REINICIO para Fedora Linux / Nobara
# Para usar: curl -sSL https://raw.githubusercontent.com/gthzix/VRHRO-12/main/1.sh | bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "  Actualizador Fedora/Nobara - Sin Reinicio"
    echo "=========================================="
    echo -e "${NC}"
}

# Mostrar header
print_header

# Verificar si el sistema es Fedora/Nobara
if ! grep -q "fedora\|nobara" /etc/os-release; then
    print_error "Este script está diseñado solo para Fedora Linux o Nobara"
    exit 1
fi

# Verificar conexión a internet
print_status "Verificando conexión a internet..."
if ! ping -c 1 google.com &> /dev/null && ! ping -c 1 8.8.8.8 &> /dev/null; then
    print_error "No hay conexión a internet. Verifica tu conexión."
    exit 1
fi

# Mostrar información del sistema
print_status "Información del sistema:"
echo "Distribución: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(uname -m)"

# Verificar espacio en disco
print_status "Verificando espacio en disco..."
df -h / | tail -1

# Preguntar confirmación
echo
read -p "¿Deseas continuar con la actualización del sistema? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_status "Actualización cancelada por el usuario"
    exit 0
fi

# Iniciar proceso de actualización
print_status "Iniciando proceso de actualización..."

# Actualizar la caché de DNF
print_status "1. Actualizando caché de paquetes..."
sudo dnf makecache --refresh

# Actualizar el sistema
print_status "2. Actualizando sistema..."
sudo dnf update -y

# Limpiar paquetes innecesarios
print_status "3. Limpiando paquetes innecesarios..."
sudo dnf autoremove -y

# Limpiar caché de paquetes
print_status "4. Limpiando caché de paquetes..."
sudo dnf clean all

# Actualizar flatpak (si está instalado)
if command -v flatpak &> /dev/null; then
    print_status "5. Actualizando aplicaciones Flatpak..."
    flatpak update -y
else
    print_status "5. Flatpak no está instalado, omitiendo..."
fi

# Actualizar snap (si está instalado)
if command -v snap &> /dev/null; then
    print_status "6. Actualizando aplicaciones Snap..."
    sudo snap refresh
else
    print_status "6. Snap no está instalado, omitiendo..."
fi

# Mensaje final SIN OPCIÓN DE REINICIO
echo
print_status "¡Actualización completada exitosamente!"
echo
print_status "Resumen de acciones realizadas:"
echo "✅ Caché de paquetes actualizado"
echo "✅ Sistema base actualizado"
echo "✅ Paquetes innecesarios eliminados"
echo "✅ Caché limpiado"
echo "✅ Flatpak actualizado (si estaba disponible)"
echo "✅ Snap actualizado (si estaba disponible)"
echo
print_status "El sistema NO se reiniciará automáticamente."
print_status "Si necesitas reiniciar, puedes hacerlo manualmente con: sudo reboot"

print_status "¡Proceso de actualización finalizado!"
