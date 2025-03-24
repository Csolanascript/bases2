#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos (según tu docker-compose.yml)
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/crear_tablas.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

CREATE TABLE Cliente OF ClienteUdt
    (REF IS id_cliente USER GENERATED,
     DNI WITH OPTIONS NOT NULL
    );

CREATE TABLE Sucursal OF SucursalUdt
    (REF IS id_sucursal USER GENERATED,
     Codigo WITH OPTIONS NOT NULL
    );

CREATE TABLE Cuenta OF CuentaUdt
    (REF IS id_cuenta USER GENERATED,
     IBAN WITH OPTIONS NOT NULL
    );

CREATE TABLE CuentaAhorro OF CuentaAhorroUdt
    UNDER Cuenta
    INHERIT SELECT PRIVILEGES;

CREATE TABLE CuentaCorriente OF CuentaCorrienteUdt
    UNDER Cuenta
    INHERIT SELECT PRIVILEGES (
        Sucursal WITH OPTIONS SCOPE Sucursal
    );


CREATE TABLE Operacion_Bancaria OF OperacionBancariaUdt
    (REF IS id_operacion USER GENERATED,
     Codigo_Numerico WITH OPTIONS NOT NULL,
     Cuenta_Emisora WITH OPTIONS SCOPE Cuenta
    );

CREATE TABLE Transferencia OF TransferenciaUdt
    UNDER Operacion_Bancaria
    INHERIT SELECT PRIVILEGES(
        Cuenta_Receptor WITH OPTIONS SCOPE Cuenta
    );

CREATE TABLE Retirada OF RetiradaUdt
    UNDER Operacion_Bancaria
    INHERIT SELECT PRIVILEGES(
        Sucursal WITH OPTIONS SCOPE Sucursal
    );

CREATE TABLE Ingreso OF IngresoUdt
    UNDER Operacion_Bancaria
    INHERIT SELECT PRIVILEGES(
        Sucursal WITH OPTIONS SCOPE Sucursal
    );

CREATE TABLE Tiene OF TieneUdt
    (REF IS id_tiene USER GENERATED,
     DNI WITH OPTIONS SCOPE Cliente,
     IBAN WITH OPTIONS SCOPE Cuenta
    );

EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > crear_tablas.sql

# Copiar el archivo al contenedor DB2
docker cp crear_tablas.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f crear_tablas.sql

echo "Creación de tipos y tablas completada en DB2 dentro del contenedor $CONTAINER_NAME."
