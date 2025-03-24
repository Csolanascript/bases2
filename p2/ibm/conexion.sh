#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta del script temporal dentro del contenedor
SQL_SCRIPT_PATH="/tmp/connect_only.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL básico solo para conectarse
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';
SELECT CURRENT DATE FROM SYSIBM.SYSDUMMY1;
TERMINATE;
EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > connect_only.sql

# Copiar el archivo al contenedor DB2
docker cp connect_only.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 -tvf $SQL_SCRIPT_PATH;
    \"
"

# Limpiar archivos temporales
rm -f connect_only.sql

echo "✅ Conexión a DB2 dentro del contenedor $CONTAINER_NAME completada."
