#!/bin/bash

# ============================================================
# Instalador Universal de Jellyfin para Linux
# Cubre: Debian/Ubuntu, Fedora/RHEL, Arch, Gentoo, openSUSE,
#        Alpine, Void, Solus y cualquier otra distro (vía Docker)
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║         Instalador Universal de Jellyfin             ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Comprobar root
if [[ $EUID -ne 0 ]]; then
    echo -e "\( {RED}Este script debe ejecutarse como root (sudo). \){NC}"
    exit 1
fi

# Detectar distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="${ID,,}"
    DISTRO_LIKE="${ID_LIKE,,}"
else
    echo -e "\( {RED}No se pudo detectar la distribución. \){NC}"
    exit 1
fi

echo -e "Distribución detectada: \( {YELLOW} \){PRETTY_NAME}${NC}"
echo -e "ID: \( {BLUE} \){DISTRO}${NC} | ID_LIKE: \( {BLUE} \){DISTRO_LIKE:-ninguno}${NC}"
echo

# ------------------------------------------------------------
# Funciones auxiliares
# ------------------------------------------------------------

open_ports() {
    echo -e "\( {YELLOW}→ Abriendo puertos 8096/tcp y 7359/udp... \){NC}"
    if command -v ufw &>/dev/null; then
        ufw allow 8096/tcp comment 'Jellyfin HTTP' 2>/dev/null || true
        ufw allow 7359/udp comment 'Jellyfin Discovery' 2>/dev/null || true
        echo "  Puertos abiertos con UFW"
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-port=8096/tcp 2>/dev/null || true
        firewall-cmd --permanent --add-port=7359/udp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        echo "  Puertos abiertos con firewalld"
    elif command -v iptables &>/dev/null; then
        iptables -I INPUT -p tcp --dport 8096 -j ACCEPT 2>/dev/null || true
        iptables -I INPUT -p udp --dport 7359 -j ACCEPT 2>/dev/null || true
        echo "  Reglas añadidas con iptables (pueden no ser persistentes)"
    else
        echo -e "  \( {YELLOW}No se detectó firewall. Abre los puertos manualmente si es necesario. \){NC}"
    fi
}

start_service() {
    if command -v systemctl &>/dev/null && systemctl list-unit-files 2>/dev/null | grep -q jellyfin; then
        systemctl enable --now jellyfin
        echo "  Servicio iniciado con systemd"
    elif [ -f /etc/init.d/jellyfin ]; then
        rc-update add jellyfin default 2>/dev/null || true
        rc-service jellyfin start 2>/dev/null || /etc/init.d/jellyfin start
        echo "  Servicio iniciado con OpenRC"
    else
        echo -e "  \( {YELLOW}No se pudo iniciar el servicio automáticamente. \){NC}"
    fi
}

install_docker() {
    echo -e "\( {YELLOW}→ Instalando Docker... \){NC}"
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com | sh
        systemctl enable --now docker 2>/dev/null || true
        if command -v rc-update &>/dev/null; then
            rc-update add docker default 2>/dev/null || true
            rc-service docker start 2>/dev/null || true
        fi
    fi
}

install_with_docker() {
    echo -e "\( {GREEN}→ Instalando Jellyfin con Docker (método universal recomendado)... \){NC}"
    
    install_docker

    mkdir -p /opt/jellyfin/{config,cache,media}
    chown -R 1000:1000 /opt/jellyfin 2>/dev/null || true

    cat > /opt/jellyfin/docker-compose.yml << 'EOF'
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    user: 1000:1000
    network_mode: host
    volumes:
      - /opt/jellyfin/config:/config
      - /opt/jellyfin/cache:/cache
      - /opt/jellyfin/media:/media
    restart: unless-stopped
EOF

    cd /opt/jellyfin
    docker compose up -d

    echo -e "\( {GREEN}Jellyfin instalado con Docker en /opt/jellyfin \){NC}"
    echo -e "Para montar tu biblioteca de medios edita: /opt/jellyfin/docker-compose.yml"
}

# ------------------------------------------------------------
# Detección e instalación
# ------------------------------------------------------------

if [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
    FAMILY="debian"
elif [[ "$DISTRO_LIKE" == *"rhel"* ]] || [[ "$DISTRO_LIKE" == *"fedora"* ]] || [[ "$DISTRO_LIKE" == *"centos"* ]]; then
    FAMILY="rhel"
elif [[ "$DISTRO_LIKE" == *"arch"* ]]; then
    FAMILY="arch"
elif [[ "$DISTRO_LIKE" == *"suse"* ]]; then
    FAMILY="suse"
elif [[ "$DISTRO_LIKE" == *"gentoo"* ]]; then
    FAMILY="gentoo"
else
    FAMILY="$DISTRO"
fi

case $FAMILY in
    debian|ubuntu|linuxmint|pop|elementary|zorin|neon|raspbian|kali|mx|devuan|pureos|parrot)
        echo -e "\( {GREEN}→ Familia Debian/Ubuntu detectada \){NC}"
        apt-get update -qq
        apt-get install -y curl ca-certificates gnupg
        
        curl -s https://repo.jellyfin.org/install-debuntu.sh -O
        curl -s https://repo.jellyfin.org/install-debuntu.sh.sha256sum -O
        
        if sha256sum -c install-debuntu.sh.sha256sum; then
            bash install-debuntu.sh
        else
            echo -e "\( {RED}Falló la verificación del script oficial. Usando Docker... \){NC}"
            install_with_docker
        fi
        rm -f install-debuntu.sh install-debuntu.sh.sha256sum
        ;;

    fedora|rhel|centos|rocky|almalinux|ol|amazon|oracle)
        echo -e "\( {GREEN}→ Familia Red Hat / Fedora detectada \){NC}"
        
        if command -v dnf &>/dev/null; then
            dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                           https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || true
            dnf install -y jellyfin && start_service || {
                echo -e "\( {YELLOW}No se pudo instalar desde RPM Fusion. Usando Docker... \){NC}"
                install_with_docker
            }
        else
            install_with_docker
        fi
        ;;

    arch|manjaro|endeavouros|garuda|artix|archcraft)
        echo -e "\( {GREEN}→ Familia Arch detectada \){NC}"
        pacman -Syu --noconfirm
        pacman -S --noconfirm jellyfin
        start_service
        ;;

    gentoo|funtoo|calculate|sabayon)
        echo -e "\( {GREEN}→ Familia Gentoo detectada \){NC}"
        echo -e "\( {YELLOW}Esto puede tardar (Gentoo compila dependencias) \){NC}"
        emerge --sync
        emerge --ask=n www-apps/jellyfin-bin
        start_service
        ;;

    opensuse*|suse|sles)
        echo -e "\( {GREEN}→ openSUSE / SUSE detectado \){NC}"
        echo -e "\( {YELLOW}openSUSE no tiene paquete oficial estable. Usando Docker... \){NC}"
        install_with_docker
        ;;

    alpine)
        echo -e "\( {GREEN}→ Alpine Linux detectado \){NC}"
        echo -e "\( {YELLOW}Usando Docker (recomendado en Alpine)... \){NC}"
        install_with_docker
        ;;

    void)
        echo -e "\( {GREEN}→ Void Linux detectado \){NC}"
        if xbps-query -Rs jellyfin &>/dev/null; then
            xbps-install -Sy jellyfin
            start_service
        else
            echo -e "\( {YELLOW}Paquete no encontrado. Usando Docker... \){NC}"
            install_with_docker
        fi
        ;;

    solus)
        echo -e "\( {GREEN}→ Solus detectado \){NC}"
        eopkg install jellyfin 2>/dev/null || {
            echo -e "\( {YELLOW}Paquete no encontrado. Usando Docker... \){NC}"
            install_with_docker
        }
        ;;

    *)
        echo -e "${YELLOW}Distribución no reconocida específicamente (\( DISTRO). \){NC}"
        echo -e "\( {YELLOW}Usando el método más universal: Docker \){NC}"
        install_with_docker
        ;;
esac

# Abrir puertos
open_ports

# Mensaje final
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo
echo -e "\( {GREEN}╔══════════════════════════════════════════════════════╗ \){NC}"
echo -e "\( {GREEN}║              ¡Instalación completada!                ║ \){NC}"
echo -e "\( {GREEN}╚══════════════════════════════════════════════════════╝ \){NC}"
echo
echo -e " Accede a Jellyfin desde tu navegador:"
echo -e "   → \( {BLUE}http://localhost:8096 \){NC}"
if [ -n "$IP" ]; then
    echo -e "   → \( {BLUE}http:// \){IP}:8096${NC}"
fi
echo
echo -e " La primera vez te pedirá configurar el servidor."
echo -e "\( {GREEN}══════════════════════════════════════════════════════ \){NC}"