#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/borrar_tablas.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

echo "Generando el script SQL para eliminar tablas y tipos..."

# Crear el script SQL para borrar las tablas y tipos
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

-- Ahora eliminamos en orden correcto
DROP TABLE IF EXISTS Tiene;
DROP TABLE IF EXISTS Ingreso;
DROP TABLE IF EXISTS Retirada;
DROP TABLE IF EXISTS Transferencia;
DROP TABLE IF EXISTS CuentaAhorro;
DROP TABLE IF EXISTS CuentaCorriente;

DROP TABLE IF EXISTS Sucursal;
DROP TABLE IF EXISTS Operacion_Bancaria;
DROP TABLE IF EXISTS Cuenta;
DROP TABLE IF EXISTS Cliente;

COMMIT;
EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > borrar_tablas.sql

# Copiar el archivo al contenedor DB2
docker cp borrar_tablas.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f borrar_tablas.sql

echo "✅ Eliminación de tipos y tablas completada en DB2 dentro del contenedor $CONTAINER_NAME."
