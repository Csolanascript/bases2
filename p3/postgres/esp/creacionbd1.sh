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
    Director VARCHAR(300) NOT NULL,
    FechaCreacion DATE NOT NULL,
    Pais VARCHAR(300) NOT NULL
);

-- Desarrolladora
CREATE TABLE esquema_videojuegos.Desarrolladora (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaCopyright VARCHAR(300) NOT NULL,
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Fabricante
CREATE TABLE esquema_videojuegos.Fabricante (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaFabricacion VARCHAR(300) NOT NULL,
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Consola
CREATE TABLE esquema_videojuegos.Consola (
    Nombre VARCHAR(300) PRIMARY KEY,
    FechaLanzamiento DATE NOT NULL,
    NumVentas INTEGER NOT NULL,
    Fabricante VARCHAR(300) NOT NULL,
    Generacion VARCHAR(300) NOT NULL,
    FOREIGN KEY(Fabricante) REFERENCES esquema_videojuegos.Fabricante(Nombre)
);

-- Videojuego
CREATE TABLE esquema_videojuegos.Videojuego (
    Nombre VARCHAR(300) PRIMARY KEY,
    Desarrolladora VARCHAR(300) NOT NULL,
    Consola VARCHAR(300) NOT NULL,
    Precio NUMERIC(10,2) NOT NULL,
    FechaLanzamiento DATE NOT NULL,
    Puntuacion NUMERIC(3,1) NOT NULL,
    FOREIGN KEY(Desarrolladora) REFERENCES esquema_videojuegos.Desarrolladora(Nombre),
    FOREIGN KEY(Consola) REFERENCES esquema_videojuegos.Consola(Nombre),
    CHECK (Puntuacion >= 0 AND Puntuacion <= 10),
    CHECK (Precio >= 0)
);

-- GeneroVideojuego
CREATE TABLE esquema_videojuegos.GeneroVideojuego (
    Videojuego VARCHAR(300) NOT NULL,
    Genero VARCHAR(300) NOT NULL,
    PRIMARY KEY (Videojuego, Genero),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);

-- Usuario
CREATE TABLE esquema_videojuegos.Usuario (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCreacion DATE NOT NULL,
    Nombre VARCHAR(300) NOT NULL,
    Apellido1 VARCHAR(300) NOT NULL,
    Apellido2 VARCHAR(300) NOT NULL,
    Email VARCHAR(300) NOT NULL,
    Pais VARCHAR(300) NOT NULL,
    Saldo NUMERIC(10,2) NOT NULL,
    EsPremium BOOLEAN NOT NULL
);

-- Usuario Premium
CREATE TABLE esquema_videojuegos.UsuarioPremium (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCaducidad DATE NOT NULL,
    RenovacionAutomatica BOOLEAN NOT NULL,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- Usuario Corriente
CREATE TABLE esquema_videojuegos.UsuarioCorriente (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    NumeroAnunciosPorSesion INTEGER NOT NULL,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- PosesionVideojuego
CREATE TABLE esquema_videojuegos.PosesionVideojuego (
    NombreUsuario VARCHAR(300) NOT NULL,
    Videojuego VARCHAR(300) NOT NULL,
    FechaCompra DATE NOT NULL,
    NumHorasJugadas INTEGER NOT NULL,
    PRIMARY KEY (NombreUsuario, Videojuego),
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);
"
echo "Tablas creadas correctamente en 'db1'."
