#!/bin/bash

# Script para buscar películas en múltiples sitios (CineCalidad, CuevanaHD, etc.)
# Dependencias: curl, grep, sed, awk, jq (opcional para JSON)

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración de sitios (dominios actualizados)
SITES=(
  "CineCalidad|https://www.cinecalidad.ec/?s="
  "CuevanaHD|https://cuevanahd.me/?s="
)

# Función principal
main() {
  clear
  echo -e "${GREEN}=== Buscador de Películas Multi-Sitio ===${NC}"
  echo -e "${YELLOW}Sitios soportados:${NC}"
  for site in "${SITES[@]}"; do
    echo -e "${BLUE}• ${site%%|*}${NC}"
  done
  echo ""
  read -p "🔍 Ingresa el nombre de la película: " query

  if [[ -z "$query" ]]; then
    echo -e "${RED}Error: Debes ingresar un nombre.${NC}"
    exit 1
  fi

  search_all_sites "$query"
}

# Buscar en todos los sitios
search_all_sites() {
  local query="$1"
  local encoded_query=$(echo "$query" | sed 's/ /+/g')

  echo -e "\n${YELLOW}🔎 Buscando \"$query\"...${NC}"

  for site in "${SITES[@]}"; do
    local name="${site%%|*}"
    local url="${site#*|}$encoded_query"
    
    echo -e "\n${GREEN}=== Resultados en $name ===${NC}"
    search_site "$name" "$url"
  done
}

# Buscar en un sitio específico
search_site() {
  local name="$1"
  local url="$2"

  local results=$(curl -s -L "$url" | grep -E -o '<a href="[^"]*" title="[^"]*"' | sed 's/<a href="//;s/" title="/|/;s/"//')

  if [[ -z "$results" ]]; then
    echo -e "${RED}No se encontraron resultados.${NC}"
    return
  fi

  local i=1
  declare -A movies
  while IFS= read -r line; do
    local movie_url="${line%%|*}"
    local title="${line#*|}"
    echo -e "${BLUE}$i) ${title}${NC}"
    movies["$i"]="$movie_url"
    ((i++))
  done <<< "$results"

  if [[ "${#movies[@]}" -gt 0 ]]; then
    read -p "Selecciona una película (1-$((i-1))) o Enter para omitir: " choice
    if [[ -n "${movies[$choice]}" ]]; then
      get_links "${movies[$choice]}" "$name"
    fi
  fi
}

# Obtener enlaces de descarga/streaming
get_links() {
  local url="$1"
  local site="$2"

  echo -e "\n${YELLOW}📡 Obteniendo enlaces de $site...${NC}"
  echo -e "${BLUE}URL: $url${NC}"

  local content=$(curl -s -L "$url")

  # Extraer enlaces comunes
  local gdrive_links=$(echo "$content" | grep -oE 'https://drive\.google\.com[^" ]+' | uniq)
  local magnet_links=$(echo "$content" | grep -oE 'magnet:\?[^" ]+' | uniq)
  local stream_links=$(echo "$content" | grep -oE 'https?://[^" ]+\.(mp4|mkv|avi)[^" ]*' | uniq)

  # Mostrar resultados
  if [[ -n "$gdrive_links" ]]; then
    echo -e "\n${GREEN}Google Drive Links:${NC}"
    echo "$gdrive_links" | awk '{print NR ") " $0}'
  fi

  if [[ -n "$magnet_links" ]]; then
    echo -e "\n${GREEN}Magnet Links (Torrents):${NC}"
    echo "$magnet_links" | awk '{print NR ") " $0}'
  fi

  if [[ -n "$stream_links" ]]; then
    echo -e "\n${GREEN}Streaming Links:${NC}"
    echo "$stream_links" | awk '{print NR ") " $0}'
  fi

  if [[ -z "$gdrive_links" && -z "$magnet_links" && -z "$stream_links" ]]; then
    echo -e "${RED}No se encontraron enlaces directos.${NC}"
    echo "Visita la página manualmente para más opciones:"
    echo -e "${BLUE}$url${NC}"
  fi
}

# Ejecutar script principal
main