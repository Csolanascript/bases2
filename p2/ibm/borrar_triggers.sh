#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/drop_triggers.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

DROP TRIGGER check_balance_before_transfer;
DROP TRIGGER update_balance_after_ingreso;
DROP TRIGGER update_balance_after_retiro;
DROP TRIGGER delete_cliente_tiene;
DROP TRIGGER check_transferencia_same_account;
DROP TRIGGER check_tipo_operacion_ingreso;
DROP TRIGGER check_tipo_operacion_transferencia;
DROP TRIGGER check_tipo_operacion_retiro;

EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > drop_triggers.sql

# Copiar el archivo al contenedor DB2
docker cp drop_triggers.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f drop_triggers.sql

echo "Eliminación de triggers completada en DB2 dentro del contenedor $CONTAINER_NAME."
