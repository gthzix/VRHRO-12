#!/bin/bash

# Actualizar paquetes
pkg update -y && pkg upgrade -y

# Instalar dependencias necesarias
pkg install -y git curl wget python3 golang

# Instalar PhoneInfoga
echo "Instalando PhoneInfoga..."
git clone https://github.com/sundowndev/phoneinfoga.git
cd phoneinfoga

# Configurar Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Construir PhoneInfoga
echo "Construyendo PhoneInfoga (esto puede tomar un tiempo)..."
go build -o phoneinfoga

# Mover el binario a /data/data/com.termux/files/usr/bin
mv phoneinfoga /data/data/com.termux/files/usr/bin/

# Dar permisos de ejecución
chmod +x /data/data/com.termux/files/usr/bin/phoneinfoga

# Volver al directorio principal
cd ..

# Instalación completada
echo "¡PhoneInfoga se ha instalado correctamente!"
echo "Puedes ejecutarlo con el comando: phoneinfoga"