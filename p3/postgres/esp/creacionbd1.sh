#!/bin/bash
# Script: docker_postgres_videojuegos_db1.sh
# Objetivo: Crear la base de datos 'db1' y las tablas correspondientes en el esquema 'esquema_videojuegos'

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="db1"                  # Base de datos destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear las tablas en español en 'db1'..."

# Crear la base de datos si no existe
echo "Verificando existencia de la base de datos '$DATABASE'..."
RESULT=$(docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE'")
if [ "$RESULT" != "1" ]; then
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $DATABASE"
    echo "Base de datos '$DATABASE' creada."
else
    echo "La base de datos '$DATABASE' ya existe."
fi

# Crear el esquema
echo "Creando esquema 'esquema_videojuegos'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "CREATE SCHEMA IF NOT EXISTS esquema_videojuegos;"

# Borrar tablas existentes
echo "Eliminando tablas existentes..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TABLE IF EXISTS esquema_videojuegos.PosesionVideojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.UsuarioCorriente CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.UsuarioPremium CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Usuario CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.GeneroVideojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Videojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Consola CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Fabricante CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Desarrolladora CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Compania CASCADE;
"
echo "Tablas eliminadas."

# Crear las tablas en 'db1'
echo "Creando tablas en el esquema 'esquema_videojuegos'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Compañía
CREATE TABLE esquema_videojuegos.Compania (
    Nombre VARCHAR(300) PRIMARY KEY,
    Director VARCHAR(300),
    FechaCreacion DATE,
    Pais VARCHAR(300)
);

-- Desarrolladora
CREATE TABLE esquema_videojuegos.Desarrolladora (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaCopyright VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Fabricante
CREATE TABLE esquema_videojuegos.Fabricante (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaFabricacion VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Consola
CREATE TABLE esquema_videojuegos.Consola (
    Nombre VARCHAR(300) PRIMARY KEY,
    FechaLanzamiento DATE,
    NumVentas INTEGER,
    Fabricante VARCHAR(300),
    Generacion VARCHAR(300),
    FOREIGN KEY(Fabricante) REFERENCES esquema_videojuegos.Fabricante(Nombre)
);

-- Videojuego
CREATE TABLE esquema_videojuegos.Videojuego (
    Nombre VARCHAR(300) PRIMARY KEY,
    Desarrolladora VARCHAR(300),
    Consola VARCHAR(300),
    Precio NUMERIC(10,2),
    FechaLanzamiento DATE,
    Puntuacion NUMERIC(3,1),
    FOREIGN KEY(Desarrolladora) REFERENCES esquema_videojuegos.Desarrolladora(Nombre),
    FOREIGN KEY(Consola) REFERENCES esquema_videojuegos.Consola(Nombre)
);

-- GeneroVideojuego
CREATE TABLE esquema_videojuegos.GeneroVideojuego (
    Videojuego VARCHAR(300),
    Genero VARCHAR(300),
    PRIMARY KEY (Videojuego, Genero),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);

-- Usuario
CREATE TABLE esquema_videojuegos.Usuario (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCreacion DATE,
    Nombre VARCHAR(300),
    Apellido1 VARCHAR(300),
    Apellido2 VARCHAR(300),
    Email VARCHAR(300),
    Pais VARCHAR(300),
    Saldo NUMERIC(10,2),
    EsPremium BOOLEAN
);

-- Usuario Premium
CREATE TABLE esquema_videojuegos.UsuarioPremium (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCaducidad DATE,
    RenovacionAutomatica BOOLEAN,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- Usuario Corriente
CREATE TABLE esquema_videojuegos.UsuarioCorriente (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    NumeroAnunciosPorSesion INTEGER,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- PosesionVideojuego
CREATE TABLE esquema_videojuegos.PosesionVideojuego (
    NombreUsuario VARCHAR(300),
    Videojuego VARCHAR(300),
    FechaCompra DATE,
    NumHorasJugadas INTEGER,
    PRIMARY KEY (NombreUsuario, Videojuego),
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);
"
echo "Tablas creadas correctamente en 'db1'."
