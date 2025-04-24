#!/bin/bash

# Script universal de instalación de Mullvad VPN
# Compatible con: Debian, Ubuntu, Arch, Fedora, RHEL y derivados
# Versión: 2.0

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detección de distribución
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        echo -e "${RED}No se pudo detectar la distribución${NC}"
        exit 1
    fi
}

# Instalación para Debian/Ubuntu
install_debian() {
    echo -e "${YELLOW}[+] Configurando para Debian/Ubuntu...${NC}"
    apt-get update
    apt-get install -y wget gnupg lsb-release
    
    wget -qO- https://mullvad.net/media/mullvad-code-signing.asc | gpg --dearmor > /usr/share/keyrings/mullvad.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mullvad.gpg] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/mullvad.list
    
    apt-get update
    apt-get install -y mullvad-vpn
    
    if [ -f /usr/bin/systemctl ]; then
        systemctl enable --now mullvad-daemon
    fi
}

# Instalación para Arch Linux
install_arch() {
    echo -e "${YELLOW}[+] Configurando para Arch Linux...${NC}"
    pacman -Sy --noconfirm wget
    
    # Usando AUR (requiere yay o paru)
    if command -v yay &> /dev/null; then
        yay -S --noconfirm mullvad-vpn
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm mullvad-vpn
    else
        echo -e "${RED}Necesitas yay o paru para instalar desde AUR${NC}"
        exit 1
    fi
    
    if [ -f /usr/bin/systemctl ]; then
        systemctl enable --now mullvad-daemon
    fi
}

# Instalación para Fedora/RHEL
install_fedora() {
    echo -e "${YELLOW}[+] Configurando para Fedora/RHEL...${NC}"
    dnf install -y wget
    
    wget -qO- https://mullvad.net/media/mullvad-code-signing.asc > /etc/pki/rpm-gpg/RPM-GPG-KEY-mullvad
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-mullvad
    
    cat > /etc/yum.repos.d/mullvad.repo <<EOL
[mullvad]
name=Mullvad VPN
baseurl=https://repository.mullvad.net/rpm/stable/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mullvad
EOL
    
    dnf install -y mullvad-vpn
    
    if [ -f /usr/bin/systemctl ]; then
        systemctl enable --now mullvad-daemon
    fi
}

# Verificar instalación
verify_install() {
    if command -v mullvad-vpn &> /dev/null; then
        echo -e "${GREEN}[+] Mullvad VPN instalado correctamente${NC}"
        echo -e "${GREEN}Versión: $(mullvad-vpn --version)${NC}"
    else
        echo -e "${RED}[!] La instalación falló${NC}"
        exit 1
    fi
}

# Función principal
main() {
    echo -e "${YELLOW}=== Instalador Universal de Mullvad VPN ===${NC}"
    
    # Verificar root
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Este script debe ejecutarse como root${NC}"
        exit 1
    fi
    
    detect_distro
    echo -e "${YELLOW}Distribución detectada: ${DISTRO} ${VERSION}${NC}"
    
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            install_debian
            ;;
        arch|manjaro)
            install_arch
            ;;
        fedora|centos|rhel)
            install_fedora
            ;;
        *)
            echo -e "${RED}Distribución no soportada${NC}"
            exit 1
            ;;
    esac
    
    verify_install
}

main