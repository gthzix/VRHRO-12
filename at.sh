#!/bin/bash
# Script: configurar-atajo-xfce.sh
# Descripción: Asigna Super+Z para abrir Firefox en XFCE

# Verificar que estamos en XFCE
if [ "$XDG_CURRENT_DESKTOP" != "XFCE" ]; then
    echo "Este script es solo para XFCE"
    exit 1
fi

# Crear el archivo de configuración del atajo
CONFIG_FILE="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

# Hacer respaldo del archivo actual
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d)"

# Verificar si ya existe el atajo y eliminarlo
xmlstarlet ed -d "//property[@name='<Super>z']" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Añadir el nuevo atajo
xmlstarlet ed -s "/channel/properties" -t elem -n "property" -v "" \
    -i "//property[last()]" -t attr -n "name" -v "<Super>z" \
    -i "//property[last()]" -t attr -n "type" -v "string" \
    -i "//property[last()]" -t attr -n "value" -v "firefox" \
    "$CONFIG_FILE" > "$CONFIG_FILE.tmp"

mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo "Atajo Super+Z configurado para Firefox"
echo "Reinicia XFCE o ejecuta: xfce4-panel -r"