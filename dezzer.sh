#!/bin/bash

# Mostrar una ventana de diálogo para ingresar la URL de Deezer
DEEZER_URL=$(zenity --entry --title "Reproducir música desde Deezer" --text "Ingresa la URL de la canción de Deezer:")

# Verifica si el usuario ingresó una URL o canceló la operación
if [ -z "$DEEZER_URL" ]; then
    echo "No se proporcionó una URL. Saliendo..."
    exit 1
fi

# Descargar la canción usando yt-dlp
echo "Descargando la canción desde Deezer..."
yt-dlp -x --audio-format mp3 -o "temp_song.%(ext)s" "$DEEZER_URL"

# Verifica si la descarga fue exitosa
if [ $? -eq 0 ]; then
    echo "Reproduciendo la canción..."
    mpv "temp_song.mp3"
else
    echo "Error al descargar la canción."
    zenity --error --text "Error al descargar la canción. Verifica la URL e intenta nuevamente."
    exit 1
fi

# Limpiar el archivo temporal
rm -f "temp_song.mp3"