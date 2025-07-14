#!/bin/bash

# Actualizar Termux y paquetes básicos
pkg update -y && pkg upgrade -y
pkg install proot-distro wget -y

# Instalar Ubuntu con proot-distro
proot-distro install ubuntu
echo -e "\n\e[1;32m[+] Ubuntu instalado.\e[0m"

# Configurar XFCE y VNC dentro de Ubuntu
proot-distro login ubuntu -- bash -c '
    apt update -y && apt upgrade -y
    apt install xfce4 tigervnc-standalone-server dbus-x11 -y

    # Configurar VNC
    mkdir -p ~/.vnc
    echo "#!/bin/bash
    unset SESSION_MANAGER
    unset DBUS_SESSION_BUS_ADDRESS
    exec dbus-launch --exit-with-session startxfce4" > ~/.vnc/xstartup
    chmod +x ~/.vnc/xstartup

    echo -e "\n\e[1;32m[+] XFCE y VNC configurados. Ejecuta \e[1;33mvncserver\e[0m para iniciar el servidor."
'

# Mensaje final
echo -e "\n\e[1;32m✅ Listo! Para iniciar XFCE:\e[0m"
echo "1. Inicia Ubuntu: \e[1;33mproot-distro login ubuntu\e[0m"
echo "2. Ejecuta VNC: \e[1;33mvncserver -geometry 1280x720 -localhost no\e[0m"
echo "3. Conéctate con un cliente VNC (ej. bVNC) a \e[1;33mlocalhost:1\e[0m"
echo -e "\n\e[1;31m⚠️ Si falla, asegúrate de que Termux tenga permisos de almacenamiento.\e[0m"