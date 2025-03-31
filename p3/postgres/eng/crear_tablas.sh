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
DROP TABLE IF EXISTS GameOwnership CASCADE;
DROP TABLE IF EXISTS Videogame CASCADE;
DROP TABLE IF EXISTS Platform CASCADE;
DROP TABLE IF EXISTS Account CASCADE;
DROP TABLE IF EXISTS Company CASCADE;

"
echo "Tablas eliminadas."

# Crear las tablas
echo "Creando tablas..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Company
CREATE TABLE Company (
    Name VARCHAR(255) NOT NULL,
    Director VARCHAR(255),
    CreatedAt DATE,
    Country VARCHAR(255),
    License VARCHAR(255),
    Type VARCHAR(255),  
    PRIMARY KEY (Name),
    CONSTRAINT chk_company_type CHECK (Type IN ('developer', 'manufacturer'))
);


CREATE TABLE Platform (
    Name VARCHAR(255) NOT NULL,
    ReleaseDate DATE,
    SalesVolume INT,
    Manufacturer VARCHAR(255),
    Generation VARCHAR(255),
    PRIMARY KEY (Name),
    FOREIGN KEY (Manufacturer) REFERENCES Company(Name)
);


CREATE TABLE Videogame (
    Name VARCHAR(255) NOT NULL,
    Developer VARCHAR(255),
    Console VARCHAR(255),
    Price NUMERIC(10, 2),
    ReleaseDate DATE,
    Rating INT,
    Genres VARCHAR(255),
    PRIMARY KEY (Name),
    FOREIGN KEY(Developer) REFERENCES Company(Name) ON DELETE CASCADE,
    FOREIGN KEY(Console) REFERENCES Platform(Name) ON DELETE CASCADE
);


CREATE TABLE Account (
    NickName VARCHAR(255) NOT NULL,
    RegisteredAt DATE,
    Name VARCHAR(255),
    Email VARCHAR(255),
    Country VARCHAR(255),
    BalanceAmount NUMERIC(10, 2),
    MembershipType VARCHAR(255),
    ExpiresAt DATE,
    AutoRenew BOOLEAN,
    AdsPerSession INTEGER,
    PRIMARY KEY (NickName),
    CONSTRAINT chk_membership_type CHECK (MembershipType IN ('premium', 'base')),
    CONSTRAINT chk_ads_for_premium CHECK (
        (MembershipType = 'premium' AND AdsPerSession = 0) OR MembershipType != 'premium'
    )
);


CREATE TABLE GameOwnership (
    NickName VARCHAR(255),
    Videogame VARCHAR(255),
    PurchasedAt DATE,
    TotalPlaytime INT,
    PRIMARY KEY (NickName, Videogame),
    FOREIGN KEY (NickName) REFERENCES Account(NickName) ON DELETE CASCADE,
    FOREIGN KEY (Videogame) REFERENCES Videogame(Name) ON DELETE CASCADE
);
"



echo "Tablas creadas correctamente."
