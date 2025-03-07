#!/bin/bash
#
# Script: grant_admin.sh
# Objetivo:
#   1. Buscar la contraseña de SYS y SYSTEM en los logs del contenedor p1-oracle-1.
#   2. Conectarse como SYS usando esa contraseña.
#   3. Otorgar todos los privilegios al usuario admin.

CONTAINER_NAME="p1-oracle-1"
CONNECT_STRING="localhost:1521/XEPDB1"

echo "Obteniendo la contraseña de SYS/SYSTEM desde los logs del contenedor '$CONTAINER_NAME'..."
# Extrae la línea que contiene la contraseña y luego sólo deja la parte de la contraseña
SYS_PASSWORD=$(docker logs "$CONTAINER_NAME" 2>/dev/null \
  | sed -n 's/^ORACLE PASSWORD FOR SYS AND SYSTEM: \(.*\)/\1/p')

if [ -z "$SYS_PASSWORD" ]; then
  echo "ERROR: No se pudo extraer la contraseña de SYS/SYSTEM. Verifica los logs manualmente."
  exit 1
fi

echo "Contraseña de SYS/SYSTEM encontrada: $SYS_PASSWORD"

# Otorgar todos los privilegios al usuario admin
echo "Otorgando privilegios a 'admin' usando SYS/$SYS_PASSWORD..."
docker exec -it "$CONTAINER_NAME" bash -c "sqlplus -S sys/$SYS_PASSWORD@$CONNECT_STRING as sysdba <<EOF
GRANT ALL PRIVILEGES TO admin;
EXIT;
EOF"

echo "Finalizado. Ahora el usuario 'admin' cuenta con todos los privilegios."
