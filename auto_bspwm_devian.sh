#!/bin/bash

# Script de instalación automática de BSPWM para Linux Mint
# Este script debe ejecutarse como usuario normal (no root)

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si un paquete está instalado
is_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Función para instalar paquetes con verificación
install_packages() {
    for pkg in "$@"; do
        if is_installed "$pkg"; then
            echo -e "${YELLOW}[INFO]${NC} El paquete $pkg ya está instalado."
        else
            echo -e "${GREEN}[INSTALANDO]${NC} $pkg..."
            sudo apt install -y "$pkg"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}[OK]${NC} $pkg instalado correctamente."
            else
                echo -e "${RED}[ERROR]${NC} Fallo al instalar $pkg."
                exit 1
            fi
        fi
    done
}

# Actualizar sistema
echo -e "${GREEN}[ACTUALIZANDO]${NC} Actualizando lista de paquetes..."
sudo apt update
sudo apt upgrade -y

# Instalar dependencias principales
echo -e "${GREEN}[INSTALANDO]${NC} Instalando dependencias principales..."
install_packages bspwm sxhkd polybar rofi dunst feh picom fonts-font-awesome xdg-utils xorg lightdm alacritty

# Crear directorios de configuración
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Creando directorios de configuración..."
mkdir -p ~/.config/{bspwm,sxhkd,polybar,rofi,dunst}

# Configuración de bspwm
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Configurando bspwm..."
cat > ~/.config/bspwm/bspwmrc << 'EOL'
#!/bin/bash

# Monitor config
monitor=${MONITOR:-HDMI-0}
bspc monitor $monitor -d 1 2 3 4 5 6 7 8 9 10

# Window settings
bspc config border_width         2
bspc config window_gap          10
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true

# Mouse settings
bspc config click_to_focus       any
bspc config pointer_modifier     mod4
bspc config pointer_action1      move
bspc config pointer_action2      resize_side
bspc config pointer_action3      resize_corner

# Rules
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a Chromium desktop='^2'
bspc rule -a mplayer2 state=floating
bspc rule -a Kupfer.py focus=on
bspc rule -a Screenkey manage=off

# Start programs
sxhkd &
polybar example &
feh --bg-scale ~/Wallpapers/default.jpg &
picom --config ~/.config/picom/picom.conf &
dunst &
EOL

chmod +x ~/.config/bspwm/bspwmrc

# Configuración de sxhkd
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Configurando sxhkd..."
cat > ~/.config/sxhkd/sxhkdrc << 'EOL'
# Terminal emulator
super + Return
    alacritty

# Program launcher
super + d
    rofi -show drun

# Window management
super + {_,shift + }{h,j,k,l}
    bspc node -{f,s} {west,south,north,east}

super + {_,shift + }c
    bspc node -{c,k}

super + {t,shift + t,s,f}
    bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

super + {_,shift + }{1-9,0}
    bspc {desktop -f,node -d} '^{1-9,10}'

# State/flags
super + ctrl + {m,x,y,z}
    bspc node -g {marked,locked,sticky,private}

# Restart/reload BSPWM
super + alt + {r,s}
    bspc {quit,wm -r}

# Exit BSPWM
super + alt + q
    pkill -USR1 -x bspwm
EOL

# Configuración de polybar
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Configurando polybar..."
cat > ~/.config/polybar/config << 'EOL'
[global/wm]
margin-top = 5
margin-bottom = 5

[bar/example]
monitor = ${env:MONITOR:HDMI-0}
width = 100%
height = 27
offset-x = 0%
offset-y = 0%
background = #222222
foreground = #ffffff
line-size = 3
padding-right = 2
module-margin = 1
font-0 = fixed:pixelsize=10;1
font-1 = unifont:fontformat=truetype:size=8:antialias=false;0
font-2 = siji:pixelsize=10;1
modules-left = bspwm
modules-center = date
modules-right = cpu memory

[module/bspwm]
type = internal/bspwm
label-focused = %index%
label-focused-background = #4a4a4a
label-focused-underline= #ffb52a
label-focused-padding = 2
label-occupied = %index%
label-occupied-padding = 2
label-urgent = %index%!
label-urgent-background = #bd2c40
label-urgent-padding = 2
label-empty = %index%
label-empty-foreground = #55
label-empty-padding = 2

[module/cpu]
type = internal/cpu
interval = 2
label = CPU %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
label = RAM %percentage_used%%

[module/date]
type = internal/date
interval = 1
date = %Y-%m-%d%
time = %H:%M:%S
label = %date% %time%
EOL

# Configuración básica de picom
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Configurando picom..."
cat > ~/.config/picom/picom.conf << 'EOL'
# Sombras
shadow = true;
shadow-radius = 12;
shadow-opacity = 0.75;
shadow-offset-x = -12;
shadow-offset-y = -12;
shadow-exclude = [
    "name = 'Notification'",
    "class_g = 'Conky'",
    "class_g ?= 'Notify-osd'",
    "class_g = 'Cairo-clock'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Opacidad
inactive-opacity = 0.9;
frame-opacity = 0.7;
inactive-opacity-override = false;
active-opacity = 1.0;

# Otros efectos
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
EOL

# Configurar fondo de pantalla por defecto
echo -e "${YELLOW}[CONFIGURACIÓN]${NC} Configurando fondo de pantalla..."
mkdir -p ~/Wallpapers
wget https://raw.githubusercontent.com/linuxmint/wallpapers/master/lena_mint/lena_mint.png -O ~/Wallpapers/default.jpg

# Habilitar lightdm
echo -e "${GREEN}[CONFIGURACIÓN]${NC} Configurando lightdm..."
sudo systemctl enable lightdm

# Mensaje final
echo -e "${GREEN}[COMPLETADO]${NC} Instalación y configuración completadas!"
echo -e "Reinicia tu sistema y selecciona BSPWM en el gestor de inicio de sesión."
echo -e "Atajos de teclado importantes:"
echo -e "  - Super + Enter: Abrir terminal"
echo -e "  - Super + d: Lanzador de aplicaciones"
echo -e "  - Super + {1-0}: Cambiar entre escritorios"
echo -e "  - Super + shift + {1-0}: Mover ventana a escritorio"
echo -e "  - Super + alt + r: Recargar BSPWM"

exit 0
