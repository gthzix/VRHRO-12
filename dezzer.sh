#!/bin/bash

# Verifica si se proporcionó una URL de Deezer
if [ -z "$1" ]; then
    echo "Uso: $0 <URL de Deezer>"
    exit 1
fi

# URL de Deezer
DEEZER_URL="$1"

# Descargar la canción usando yt-dlp
echo "Descargando la canción desde Deezer..."
yt-dlp -x --audio-format mp3 -o "temp_song.%(ext)s" "$DEEZER_URL"

# Verifica si la descarga fue exitosa
if [ $? -eq 0 ]; then
    echo "Reproduciendo la canción..."
    mpv "temp_song.mp3"
else
    echo "Error al descargar la canción."
    exit 1
fi

# Limpiar el archivo temporal
rm -f "temp_song.mp3"