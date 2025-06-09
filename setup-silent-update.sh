#!/bin/bash

## Script de actualización automática silenciosa para Debian
## No muestra terminales ni pide contraseñas

# 1. Crear el servicio systemd
cat > /etc/systemd/system/silent-update.service <<EOF
[Unit]
Description=Actualización automática silenciosa de Debian
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/silent-update.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

# 2. Crear el script de actualización
cat > /usr/local/bin/silent-update.sh <<'EOF'
#!/bin/bash

# Configurar entorno sin preguntas
export DEBIAN_FRONTEND=noninteractive

# Actualizar lista de paquetes
apt-get -qq update > /dev/null 2>&1

# Actualizar paquetes existentes (seguro)
apt-get -qq -y --only-upgrade install > /dev/null 2>&1

# Actualizar paquetes (incluyendo nuevas dependencias)
apt-get -qq -y upgrade > /dev/null 2>&1

# Limpiar paquetes innecesarios
apt-get -qq -y autoremove > /dev/null 2>&1
apt-get -qq -y autoclean > /dev/null 2>&1

# Opcional: Actualizar el sistema si hay nueva versión (descomentar si se desea)
# apt-get -qq -y dist-upgrade > /dev/null 2>&1
EOF

# 3. Dar permisos y habilitar el servicio
chmod +x /usr/local/bin/silent-update.sh
systemctl daemon-reload
systemctl enable silent-update.service
systemctl start silent-update.service

# 4. Crear un cron para ejecutarlo diariamente
echo "0 3 * * * root /usr/local/bin/silent-update.sh" > /etc/cron.d/silent-update
