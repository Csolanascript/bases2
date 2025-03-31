#!/bin/bash
# Script: docker_postgres_videojuegos.sh
# Objetivo: Crear base de datos de videojuegos en contenedor Docker PostgreSQL

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"          # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear la base de datos de videojuegos..."

# Crear la base de datos si no existe
echo "Verificando existencia de la base de datos '$DATABASE'..."
RESULT=$(docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE'")
if [ "$RESULT" != "1" ]; then
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $DATABASE"
    echo "Base de datos '$DATABASE' creada."
else
    echo "La base de datos '$DATABASE' ya existe."
fi

# Borrar todas las tablas en orden por dependencias
echo "Eliminando tablas existentes..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TABLE IF EXISTS PosesionVideojuego CASCADE;
DROP TABLE IF EXISTS UsuarioCorriente CASCADE;
DROP TABLE IF EXISTS UsuarioPremium CASCADE;
DROP TABLE IF EXISTS Usuario CASCADE;
DROP TABLE IF EXISTS GeneroVideojuego CASCADE;
DROP TABLE IF EXISTS Videojuego CASCADE;
DROP TABLE IF EXISTS Consola CASCADE;
DROP TABLE IF EXISTS Fabricante CASCADE;
DROP TABLE IF EXISTS Desarrolladora CASCADE;
DROP TABLE IF EXISTS Compania CASCADE;
"
echo "Tablas eliminadas."

# Crear las tablas
echo "Creando tablas..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Compañía
CREATE TABLE Compania (
    Nombre VARCHAR(300) PRIMARY KEY,
    Director VARCHAR(300),
    FechaCreacion DATE,
    Pais VARCHAR(300)
);

-- Desarrolladora
CREATE TABLE Desarrolladora (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaCopyright VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES Compania(Nombre)
);

-- Fabricante
CREATE TABLE Fabricante (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaFabricacion VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES Compania(Nombre)
);

-- Consola
CREATE TABLE Consola (
    Nombre VARCHAR(300) PRIMARY KEY,
    FechaLanzamiento DATE,
    NumVentas INTEGER,
    Fabricante VARCHAR(300),
    Generacion VARCHAR(300),
    FOREIGN KEY(Fabricante) REFERENCES Fabricante(Nombre)
);

-- Videojuego
CREATE TABLE Videojuego (
    Nombre VARCHAR(300) PRIMARY KEY,
    Desarrolladora VARCHAR(300),
    Consola VARCHAR(300),
    Precio NUMERIC(10,2),
    FechaLanzamiento DATE,
    Puntuacion NUMERIC(3,1),
    FOREIGN KEY(Desarrolladora) REFERENCES Desarrolladora(Nombre),
    FOREIGN KEY(Consola) REFERENCES Consola(Nombre)
);

-- GeneroVideojuego
CREATE TABLE GeneroVideojuego (
    Videojuego VARCHAR(300),
    Genero VARCHAR(300),
    PRIMARY KEY (Videojuego, Genero),
    FOREIGN KEY(Videojuego) REFERENCES Videojuego(Nombre)
);

-- Usuario
CREATE TABLE Usuario (
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
CREATE TABLE UsuarioPremium (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCaducidad DATE,
    RenovacionAutomatica BOOLEAN,
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario)
);

-- Usuario Corriente
CREATE TABLE UsuarioCorriente (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    NumeroAnunciosPorSesion INTEGER,
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario)
);

-- PosesionVideojuego
CREATE TABLE PosesionVideojuego (
    NombreUsuario VARCHAR(300),
    Videojuego VARCHAR(300),
    FechaCompra DATE,
    NumHorasJugadas INTEGER,
    PRIMARY KEY (NombreUsuario, Videojuego),
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario),
    FOREIGN KEY(Videojuego) REFERENCES Videojuego(Nombre)
);
"
echo "Tablas creadas correctamente."
