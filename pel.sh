#!/bin/bash

# Script interactivo para buscar películas
# Dominios actualizados al 2024-07-20

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

clear
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}    BUSCADOR DE PELÍCULAS (CineCalidad/Cuevana)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""

# Pedir nombre de la película
read -p "🔍 Ingresa el nombre de la película: " pelicula

if [ -z "$pelicula" ]; then
    echo -e "${RED}Error: Debes ingresar un nombre de película${NC}"
    exit 1
fi

# Codificar para URL (reemplaza espacios con +)
query=$(echo "$pelicula" | sed 's/ /+/g')

# Buscar en CineCalidad
echo -e "\n${YELLOW}🔎 Buscando en CineCalidad.ec...${NC}"
cinecalidad_url="https://www.cinecalidad.ec/?s=$query"
results=$(curl -s "$cinecalidad_url" | grep -oP '<h2 class="entry-title"><a href="\K[^"]+' | head -5)

if [ -z "$results" ]; then
    echo -e "${RED}No se encontraron resultados en CineCalidad${NC}"
else
    echo -e "${GREEN}Resultados encontrados:${NC}"
    i=1
    declare -A opciones
    while IFS= read -r url; do
        title=$(echo "$url" | sed 's|.*/||; s|-/.*||; s|-| |g')
        echo -e "${BLUE}$i) $title${NC}"
        opciones[$i]=$url
        ((i++))
    done <<< "$results"
    
    read -p "Selecciona una opción (1-$((i-1))): " seleccion
    if [[ -n "${opciones[$seleccion]}" ]]; then
        echo -e "\n${GREEN}Enlace de CineCalidad:${NC} ${opciones[$seleccion]}"
    fi
fi

# Buscar en CuevanaHD
echo -e "\n${YELLOW}🔎 Buscando en CuevanaHD...${NC}"
cuevana_url="https://cuevanahd.me/?s=$query"
results=$(curl -s "$cuevana_url" | grep -oP '<h2 class="entry-title"><a href="\K[^"]+' | head -5)

if [ -z "$results" ]; then
    echo -e "${RED}No se encontraron resultados en CuevanaHD${NC}"
else
    echo -e "${GREEN}Resultados encontrados:${NC}"
    i=1
    declare -A opciones
    while IFS= read -r url; do
        title=$(echo "$url" | sed 's|.*/||; s|-/.*||; s|-| |g')
        echo -e "${BLUE}$i) $title${NC}"
        opciones[$i]=$url
        ((i++))
    done <<< "$results"
    
    read -p "Selecciona una opción (1-$((i-1))): " seleccion
    if [[ -n "${opciones[$seleccion]}" ]]; then
        echo -e "\n${GREEN}Enlace de CuevanaHD:${NC} ${opciones[$seleccion]}"
    fi
fi

echo -e "\n${YELLOW}✨ Búsqueda completada${NC}"