# Actualizar paquetes
pkg update -y && pkg upgrade -y

# Instalar dependencias
pkg install -y wget tar

# Descargar la última versión de PhoneInfoga para ARM (Termux)
wget https://github.com/sundowndev/phoneinfoga/releases/latest/download/phoneinfoga_Linux_armv7.tar.gz

# Extraer el archivo
tar -xvzf phoneinfoga_Linux_armv7.tar.gz

# Mover el binario a /usr/bin/
mv phoneinfoga /data/data/com.termux/files/usr/bin/

# Dar permisos de ejecución
chmod +x /data/data/com.termux/files/usr/bin/phoneinfoga

# Verificar instalación
phoneinfoga --version

pkg install docker -y
docker run --rm -it sundowndev/phoneinfoga:latest

pkg install nodejs -y
