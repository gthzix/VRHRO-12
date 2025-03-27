#!/bin/bash

# Configuración
API_URL="https://api.animeflv.net/v3"
PLAYER="mpv"  # Puedes cambiarlo por vlc, celluloid, etc.
TEMP_FILE="/tmp/animeflv_results.txt"

# Dependencias necesarias
REQUIRED_CMDS=("curl" "jq" "$PLAYER")

# Verificar dependencias
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' no está instalado."
        exit 1
    fi
done

# Función para buscar anime
search_anime() {
    local query="$1"
    echo "Buscando anime: $query..."
    
    local response=$(curl -s "${API_URL}/animes?q=${query}")
    local count=$(echo "$response" | jq '.data | length')
    
    if [ "$count" -eq 0 ]; then
        echo "No se encontraron resultados."
        return 1
    fi
    
    # Mostrar resultados
    echo "$response" | jq -r '.data[] | "\(.id) - \(.title) (\(.type))"' > "$TEMP_FILE"
    
    echo -e "\nResultados:"
    nl -w 2 -s ") " "$TEMP_FILE"
}

# Función para obtener episodios
get_episodes() {
    local anime_id="$1"
    echo "Obteniendo episodios..."
    
    local response=$(curl -s "${API_URL}/anime/${anime_id}/episodes")
    echo "$response" | jq -r '.data[] | "\(.number) - \(.title)"' > "$TEMP_FILE"
    
    echo -e "\nEpisodios disponibles:"
    nl -w 2 -s ") " "$TEMP_FILE"
}

# Función para reproducir episodio
play_episode() {
    local anime_id="$1"
    local episode_number="$2"
    
    echo "Obteniendo enlace del episodio ${episode_number}..."
    
    local response=$(curl -s "${API_URL}/anime/${anime_id}/episode/${episode_number}/sources")
    local video_url=$(echo "$response" | jq -r '.data[0].url' | head -n 1)
    
    if [ -z "$video_url" ]; then
        echo "No se pudo obtener el enlace del video."
        return 1
    fi
    
    echo "Reproduciendo con ${PLAYER}..."
    "$PLAYER" "$video_url"
}

# Menú principal
main_menu() {
    while true; do
        echo -e "\n=== Reproductor de AnimeFLV ==="
        echo "1) Buscar anime"
        echo "2) Salir"
        read -p "Seleccione una opción: " option
        
        case "$option" in
            1)
                read -p "Ingrese el nombre del anime: " query
                search_anime "$query"
                
                if [ $? -eq 0 ]; then
                    read -p "Seleccione un anime (número): " anime_sel
                    anime_id=$(sed -n "${anime_sel}p" "$TEMP_FILE" | awk '{print $1}')
                    
                    get_episodes "$anime_id"
                    
                    read -p "Seleccione un episodio (número): " ep_sel
                    episode_number=$(sed -n "${ep_sel}p" "$TEMP_FILE" | awk '{print $1}')
                    
                    play_episode "$anime_id" "$episode_number"
                fi
                ;;
            2)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción inválida."
                ;;
        esac
    done
}

# Iniciar
main_menu