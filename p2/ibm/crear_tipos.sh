#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos (según tu docker-compose.yml)
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/crear_tipos.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

CREATE TYPE ClienteUdt AS (
    DNI        VARCHAR(255),
    Edad       INT,
    Nombre     VARCHAR(255), 
    Apellidos  VARCHAR(255), 
    Email      VARCHAR(255), 
    Direccion  VARCHAR(255), 
    Telefono   VARCHAR(255)
) INSTANTIABLE NOT FINAL REF USING INTEGER mode db2sql;

CREATE TYPE SucursalUdt AS (
    Codigo                INT,
    Direccion             VARCHAR(255),
    Telefono              INT,
    Cuenta_corriente_IBAN VARCHAR(255)
) INSTANTIABLE NOT FINAL REF USING INTEGER mode db2sql;

-- Tipo padre
CREATE TYPE CuentaUdt AS (
    IBAN VARCHAR(255), 
    Numero_Cuenta INT, 
    Saldo FLOAT,
    Fecha_Creacion DATE
) INSTANTIABLE NOT FINAL REF USING INTEGER mode db2sql;

-- Hijos con herencia
CREATE TYPE CuentaAhorroUdt UNDER CuentaUdt AS (
    Interes FLOAT
) INSTANTIABLE NOT FINAL mode db2sql;

CREATE TYPE CuentaCorrienteUdt UNDER CuentaUdt AS (
    Sucursal        REF(sucursalUdt)
) INSTANTIABLE NOT FINAL mode db2sql;

-- Tipo padre
CREATE TYPE OperacionBancariaUdt AS (
    Descripcion     VARCHAR(255),
    Codigo_Numerico INT,
    Hora            TIME,
    Fecha           DATE,
    Cantidad        FLOAT,
    Tipo            VARCHAR(255),
    Cuenta_Emisora  REF(CuentaUdt)
) INSTANTIABLE NOT FINAL REF USING INTEGER mode db2sql;

-- Subtipo Transferencia
CREATE TYPE TransferenciaUdt UNDER OperacionBancariaUdt AS (
    Cuenta_Receptor REF(CuentaUdt)
) INSTANTIABLE NOT FINAL mode db2sql;

-- Subtipo Retirada
CREATE TYPE RetiradaUdt UNDER OperacionBancariaUdt AS (
    Sucursal        REF(sucursalUdt)
) INSTANTIABLE NOT FINAL mode db2sql;

-- Subtipo Ingreso
CREATE TYPE IngresoUdt UNDER OperacionBancariaUdt AS (
    Sucursal        REF(sucursalUdt)
) INSTANTIABLE NOT FINAL mode db2sql;

CREATE TYPE TieneUdt AS (
    DNI     REF(ClienteUdt),
    IBAN    REF(CuentaUdt)
) INSTANTIABLE NOT FINAL REF USING INTEGER mode db2sql;

EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > crear_tipos.sql

# Copiar el archivo al contenedor DB2
docker cp crear_tipos.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f crear_tipos.sql

echo "Creación de tipos y tablas completada en DB2 dentro del contenedor $CONTAINER_NAME."
