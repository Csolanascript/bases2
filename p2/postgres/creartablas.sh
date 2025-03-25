#!/bin/bash
# Script: docker_postgres_create_tables.sh
# Objetivo: Borrar todas las tablas existentes, crear el esquema bancario en PostgreSQL usando herencia,
#           e insertar datos de ejemplo de forma idempotente.
# Se asume que el contenedor tiene psql disponible.

CONTAINER_NAME="p2_postgres_1"  # Contenedor de PostgreSQL
DATABASE="p2"                  # Nombre de la base de datos
ADMIN_USER="postgres"          # Usuario administrador de PostgreSQL

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para borrar y crear tablas en PostgreSQL..."

# Crear la base de datos si no existe
echo "Creando base de datos '$DATABASE' (si no existe)..."
RESULT=$(docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE'")
if [ "$RESULT" != "1" ]; then
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $DATABASE"
    echo "Base de datos '$DATABASE' creada."
else
    echo "Base de datos '$DATABASE' ya existe."
fi

# Borrar todas las tablas existentes (ordenado para evitar dependencias)
echo "Borrando todas las tablas existentes..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TABLE IF EXISTS transferencia CASCADE;
DROP TABLE IF EXISTS ingreso CASCADE;
DROP TABLE IF EXISTS retirada CASCADE;
DROP TABLE IF EXISTS operacion_bancaria CASCADE;
DROP TABLE IF EXISTS cuenta_corriente CASCADE;
DROP TABLE IF EXISTS cuenta_ahorro CASCADE;
DROP TABLE IF EXISTS cuenta_cliente CASCADE;
DROP TABLE IF EXISTS cuenta CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS sucursal CASCADE;
"
echo "Todas las tablas borradas."

# Crear las tablas con herencia
echo "Creando tablas bancarias..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Tabla sucursal
CREATE TABLE IF NOT EXISTS sucursal (
  codigo_sucursal INT PRIMARY KEY,
  direccion       VARCHAR(100),
  telefono        VARCHAR(20)
);

-- Tabla cliente
CREATE TABLE IF NOT EXISTS cliente (
  email       VARCHAR(50) PRIMARY KEY,
  nombre      VARCHAR(50),
  apellidos   VARCHAR(50),
  edad        INT,
  telefono    VARCHAR(15),
  direccion   VARCHAR(100)
);

-- Tabla base para cuenta
CREATE TABLE IF NOT EXISTS cuenta (
  iban           VARCHAR(34) PRIMARY KEY,
  numero_cuenta  VARCHAR(50),
  saldo          NUMERIC(15,2),
  fecha_creacion DATE
);

-- Tablas derivadas de cuenta usando herencia
CREATE TABLE IF NOT EXISTS cuenta_ahorro (
  interes       NUMERIC(5,2)
) INHERITS (cuenta);

CREATE TABLE IF NOT EXISTS cuenta_corriente (
  codigo_sucursal INT,
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
) INHERITS (cuenta);

-- Tabla intermedia para relacionar cliente y cuenta
CREATE TABLE IF NOT EXISTS cuenta_cliente (
  email VARCHAR(50),
  iban  VARCHAR(34),
  PRIMARY KEY (email, iban),
  FOREIGN KEY (email) REFERENCES cliente(email),
  FOREIGN KEY (iban) REFERENCES cuenta(iban)
);

-- Tabla base para operaciones bancarias
CREATE TABLE IF NOT EXISTS operacion_bancaria (
  codigo_numerico INT PRIMARY KEY,
  iban            VARCHAR(34),
  tipo            VARCHAR(20),
  cantidad        NUMERIC(15,2),
  fecha           DATE,
  hora            TIME,
  FOREIGN KEY (iban) REFERENCES cuenta(iban)
);

-- Tablas derivadas de operacion_bancaria usando herencia
CREATE TABLE IF NOT EXISTS transferencia (
  iban_destinatario VARCHAR(34),
  PRIMARY KEY (codigo_numerico, iban, iban_destinatario),
  FOREIGN KEY (iban_destinatario) REFERENCES cuenta(iban)
) INHERITS (operacion_bancaria);

CREATE TABLE IF NOT EXISTS retirada (
  codigo_sucursal INT,
  PRIMARY KEY (codigo_numerico, iban, codigo_sucursal),
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
) INHERITS (operacion_bancaria);

CREATE TABLE IF NOT EXISTS ingreso (
  codigo_sucursal INT,
  PRIMARY KEY (codigo_numerico, iban, codigo_sucursal),
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
) INHERITS (operacion_bancaria);
"
echo "Tablas creadas (o ya existían)."

# Insertar datos de ejemplo de forma idempotente
echo "Insertando datos de ejemplo en las tablas (si están vacías)..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar un cliente de ejemplo
INSERT INTO cliente (email, nombre, apellidos, edad, telefono, direccion)
SELECT 'ejemplo@cliente.com', 'Juan', 'Pérez', 30, '123456789', 'Calle Falsa 123'
WHERE NOT EXISTS (SELECT 1 FROM cliente WHERE email = 'ejemplo@cliente.com');

-- Insertar una sucursal de ejemplo
INSERT INTO sucursal (codigo_sucursal, direccion, telefono)
SELECT 1, 'Sucursal Central', '987654321'
WHERE NOT EXISTS (SELECT 1 FROM sucursal WHERE codigo_sucursal = 1);

-- Insertar una cuenta base de ejemplo
INSERT INTO cuenta (iban, numero_cuenta, saldo, fecha_creacion)
SELECT 'ES1234567890123456789012', '1234567890', 1000.00, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM cuenta WHERE iban = 'ES1234567890123456789012');

-- Insertar una cuenta de ahorro derivada
INSERT INTO cuenta_ahorro (iban, numero_cuenta, saldo, fecha_creacion, interes)
SELECT 'ESAHORRO1234567890123456', 'AHO123456', 2000.00, CURRENT_DATE, 1.50
WHERE NOT EXISTS (SELECT 1 FROM cuenta WHERE iban = 'ESAHORRO1234567890123456');

-- Insertar una cuenta corriente derivada
INSERT INTO cuenta_corriente (iban, numero_cuenta, saldo, fecha_creacion, codigo_sucursal)
SELECT 'ESCORRIENTE1234567890123', 'COR123456', 1500.00, CURRENT_DATE, 1
WHERE NOT EXISTS (SELECT 1 FROM cuenta WHERE iban = 'ESCORRIENTE1234567890123');

-- Insertar relación cliente-cuenta
INSERT INTO cuenta_cliente (email, iban)
SELECT 'ejemplo@cliente.com', 'ES1234567890123456789012'
WHERE NOT EXISTS (SELECT 1 FROM cuenta_cliente WHERE email = 'ejemplo@cliente.com' AND iban = 'ES1234567890123456789012');
"
echo "Datos insertados (o ya estaban presentes)."

echo "Script docker_postgres_create_tables.sh completado."
