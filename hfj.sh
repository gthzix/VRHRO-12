#!/bin/bash
# Versión mejorada para animeav1.com
# Uso: bash one_piece.sh <episodio>
# En Termux instalar antes: pkg install curl grep pcre -y

EPISODIO="$1"
URL="https://animeav1.com/media/one-piece/$EPISODIO"
TMP_HTML="/tmp/op_ep_$EPISODIO.html"
TMP_SCRIPTS="/tmp/op_scripts_$EPISODIO"

echo "=== Descargando página del Episodio $EPISODIO ==="
curl -s "$URL" -o "$TMP_HTML"

echo -e "\n=== 1. Buscando iframes de reproductores ==="
grep -oP 'src="[^"]*"' "$TMP_HTML" | grep -iE 'player|video|embed|stream' | sed 's/src="//;s/"$//'

echo -e "\n=== 2. Extrayendo y analizando JavaScript externo ==="
mkdir -p "$TMP_SCRIPTS"
# Descargar cada archivo .js encontrado
grep -oP 'src="([^"]*\.js[^"]*)"' "$TMP_HTML" | sed 's/src="//;s/"$//' | sort -u | while read js_url; do
    # Convertir URLs relativas a absolutas si es necesario
    if [[ "$js_url" != http* ]]; then
        js_url="https://animeav1.com$js_url"
    fi
    echo "Analizando: $js_url"
    curl -s "$js_url" | grep -oP '(https?://[^"'"'"' ]*\.(mp4|m3u8|mkv|avi|webm)[^"'"'"' ]*)' | sort -u
    curl -s "$js_url" | grep -oP '(https?://[^"'"'"' ]*(mega|mediafire|drive|yourupload|okru|netu|streamwish|filemoon)[^"'"'"' ]*)' | sort -u
done

echo -e "\n=== 3. Buscando datos embebidos (JSON/var) ==="
grep -oP '"(https?://[^"]*\.(mp4|m3u8)[^"]*)"' "$TMP_HTML" | tr -d '"'
grep -oP 'var\s+\w+\s*=\s*["'"'"'](https?://[^"'"'"' ]*)' "$TMP_HTML"

# Limpieza
rm "$TMP_HTML"
echo -e "\n=== Análisis completado ==="