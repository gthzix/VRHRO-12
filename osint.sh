#!/data/data/com.termux/files/usr/bin/bash

echo "[+] Instalando herramientas OSINT en Termux..."

# Actualizar sistema
pkg update && pkg upgrade -y

# Instalar dependencias
pkg install -y python git rust nodejs wget

# Instalar herramientas via pip
echo "[+] Instalando socialscan, twint y waybackpy..."
pip install socialscan twint waybackpy

# Instalar Osintgram desde GitHub
echo "[+] Instalando Osintgram..."
git clone https://github.com/Datalux/Osintgram.git
cd Osintgram
pip install -r requirements.txt
cd ..

# Instalar Sherlock
echo "[+] Instalando Sherlock..."
git clone https://github.com/sherlock-project/sherlock.git
cd sherlock
pip install -r requirements.txt
cd ..

echo "[+] Instalación completada!"
echo "[+] Herramientas disponibles:"
echo "    - socialscan: Verificación de emails/usernames"
echo "    - twint: OSINT para Twitter"
echo "    - waybackpy: Archivos web históricos"
echo "    - Osintgram: En la carpeta Osintgram/"
echo "    - Sherlock: En la carpeta sherlock/"