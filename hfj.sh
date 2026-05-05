#!/bin/bash
# Requiere: curl, grep, jq (opcional)
# Uso: bash one_piece_links.sh <número_de_episodio>

EPISODIO="$1"
URL="https://animeav1.com/media/one-piece/$EPISODIO"

echo "=== Analizando Episodio $EPISODIO ==="

# 1. Buscar en los scripts de la página
echo "[*] Enlaces en scripts:"
curl -s "$URL" | grep -oP '(https?://[^"'"'"' ]*\.(mp4|m3u8|mkv|avi)[^"'"'"' ]*)' | sort -u

# 2. Buscar patrones de servidores comunes
echo -e "\n[*] Buscando servidores conocidos:"
curl -s "$URL" | grep -oP '(https?://[^"'"'"' ]*(mega|mediafire|drive|yourupload|okru|netu|streamwish|filemoon)[^"'"'"' ]*)' | sort -u

# 3. Volcar todos los scripts para búsqueda manual
echo -e "\n[*] Scripts externos cargados (para análisis manual):"
curl -s "$URL" | grep -oP 'src="([^"]*\.js[^"]*)"' | sed 's/src="//;s/"$//' | sort -u