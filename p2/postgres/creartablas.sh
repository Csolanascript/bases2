#!/bin/bash
# Script: docker_postgres_create_tables.sh
# Objetivo: Crear las tablas del esquema bancario en PostgreSQL si no existen,
#           y poblarlas con datos de ejemplo de forma idempotente.
# Se asume que el contenedor tiene psql disponible.

CONTAINER_NAME="eb099d90c2ae"  # Contenedor de PostgreSQL
DATABASE="p2"  # Nombre de la base de datos
ADMIN_USER="postgres"  # Usuario administrador de PostgreSQL

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear y poblar tablas en PostgreSQL..."

# Crear la base de datos p2 si no existe
echo "Creando base de datos '$DATABASE' (si no existe)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -c "CREATE DATABASE $DATABASE;"
echo "Base de datos '$DATABASE' creada (o ya existía)."

# Crear las tablas si no existen

echo "Creando tablas bancarias (si no existen)..."

docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Primero, crear las tablas que no tienen dependencias
CREATE TABLE IF NOT EXISTS sucursal (
  codigo_sucursal INT PRIMARY KEY,
  direccion       VARCHAR(100),
  telefono        VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS cliente (
  email         VARCHAR(50) PRIMARY KEY,
  nombre        VARCHAR(50),
  apellidos     VARCHAR(50),
  edad          INT,
  telefono      VARCHAR(15),
  direccion     VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS cuenta (
  iban           VARCHAR(34) PRIMARY KEY,
  numero_cuenta  VARCHAR(50),
  saldo          NUMERIC(15,2),
  fecha_creacion DATE
);

-- Ahora, crear las tablas dependientes
CREATE TABLE IF NOT EXISTS cuenta_ahorro (
  iban           VARCHAR(34) PRIMARY KEY,
  interes        NUMERIC(5,2),
  FOREIGN KEY (iban) REFERENCES cuenta(iban)
);

CREATE TABLE IF NOT EXISTS cuenta_corriente (
  iban           VARCHAR(34) PRIMARY KEY,
  codigo_sucursal INT,
  FOREIGN KEY (iban) REFERENCES cuenta(iban),
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
);

CREATE TABLE IF NOT EXISTS operacion_bancaria (
  codigo_numerico INT PRIMARY KEY,
  iban            VARCHAR(34),
  tipo            VARCHAR(20),
  cantidad        NUMERIC(15,2),
  fecha           DATE,
  hora            TIME,
  FOREIGN KEY (iban) REFERENCES cuenta(iban)
);

CREATE TABLE IF NOT EXISTS transferencia (
  codigo_numerico INT PRIMARY KEY,
  iban            VARCHAR(34),
  tipo            VARCHAR(20),
  cantidad        NUMERIC(15,2),
  fecha           DATE,
  hora            TIME,
  iban_destinatario VARCHAR(34),
  FOREIGN KEY (iban) REFERENCES cuenta(iban),
  FOREIGN KEY (iban_destinatario) REFERENCES cuenta(iban)
);

CREATE TABLE IF NOT EXISTS retirada (
  codigo_numerico INT PRIMARY KEY,
  iban            VARCHAR(34),
  tipo            VARCHAR(20),
  cantidad        NUMERIC(15,2),
  fecha           DATE,
  hora            TIME,
  codigo_sucursal INT,
  FOREIGN KEY (iban) REFERENCES cuenta(iban),
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
);

CREATE TABLE IF NOT EXISTS ingreso (
  codigo_numerico INT PRIMARY KEY,
  iban            VARCHAR(34),
  tipo            VARCHAR(20),
  cantidad        NUMERIC(15,2),
  fecha           DATE,
  hora            TIME,
  codigo_sucursal INT,
  FOREIGN KEY (iban) REFERENCES cuenta(iban),
  FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
);

CREATE TABLE IF NOT EXISTS cuenta_cliente (
  email VARCHAR(50),
  iban  VARCHAR(34),
  PRIMARY KEY (email, iban),
  FOREIGN KEY (email) REFERENCES cliente(email),
  FOREIGN KEY (iban) REFERENCES cuenta(iban)
);
"

echo "Tablas creadas (o ya existían)."

# Insertar datos de ejemplo (si es necesario)
echo "Insertando datos de ejemplo en las tablas (si están vacías)..."

docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar datos de ejemplo solo si las tablas están vacías
INSERT INTO cliente (email, nombre, apellidos, edad, telefono, direccion)
SELECT 'ejemplo@cliente.com', 'Juan', 'Pérez', 30, '123456789', 'Calle Falsa 123'
WHERE NOT EXISTS (SELECT 1 FROM cliente WHERE email = 'ejemplo@cliente.com');

INSERT INTO sucursal (codigo_sucursal, direccion, telefono)
SELECT 1, 'Sucursal Central', '987654321'
WHERE NOT EXISTS (SELECT 1 FROM sucursal WHERE codigo_sucursal = 1);

INSERT INTO cuenta (iban, numero_cuenta, saldo, fecha_creacion)
SELECT 'ES1234567890123456789012', '1234567890', 1000.00, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1 FROM cuenta WHERE iban = 'ES1234567890123456789012');
"

echo "Datos insertados (o ya estaban presentes)."

echo "Script docker_postgres_create_tables.sh completado."
