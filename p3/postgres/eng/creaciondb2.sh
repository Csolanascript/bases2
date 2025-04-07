#!/bin/bash
# Script: docker_postgres_videojuegos_db2.sh
# Objetivo: Crear la base de datos 'db2' y las tablas correspondientes en el esquema 'esquema_videojuegos_en'

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="db2"                  # Base de datos destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear las tablas en inglés en 'db2'..."

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
echo "Creando esquema 'esquema_videojuegos_en'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "CREATE SCHEMA IF NOT EXISTS esquema_videojuegos_en;"

# Borrar tablas existentes
echo "Eliminando tablas existentes..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TABLE IF EXISTS esquema_videojuegos_en.GameOwnership CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Videogame CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Platform CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Account CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Company CASCADE;
"
echo "Tablas eliminadas."

# Crear las tablas en 'db2'
echo "Creando tablas en el esquema 'esquema_videojuegos_en'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Company
CREATE TABLE esquema_videojuegos_en.Company (
    Name VARCHAR(255) PRIMARY KEY,
    Director VARCHAR(255) NOT NULL,
    CreatedAt DATE NOT NULL,
    Country VARCHAR(255) NOT NULL,
    License VARCHAR(255) NOT NULL,
    Type VARCHAR(255) NOT NULL,
    CONSTRAINT chk_company_type CHECK (Type IN ('Desarrolladora', 'Fabricante'))
);

-- Platform
CREATE TABLE esquema_videojuegos_en.Platform (
    Name VARCHAR(255) PRIMARY KEY,
    ReleaseDate DATE NOT NULL,
    SalesVolume INT NOT NULL,
    Manufacturer VARCHAR(255) NOT NULL,
    Generation VARCHAR(255) NOT NULL,
    FOREIGN KEY (Manufacturer) REFERENCES esquema_videojuegos_en.Company(Name)
);

-- Videogame
CREATE TABLE esquema_videojuegos_en.Videogame (
    Name VARCHAR(255) PRIMARY KEY,
    Developer VARCHAR(255) NOT NULL,
    Console VARCHAR(255) NOT NULL,
    Price NUMERIC(10, 2) NOT NULL,
    ReleaseDate DATE NOT NULL,
    Rating INT NOT NULL,
    Genres VARCHAR(255) NOT NULL,
    FOREIGN KEY(Developer) REFERENCES esquema_videojuegos_en.Company(Name) ON DELETE CASCADE,
    FOREIGN KEY(Console) REFERENCES esquema_videojuegos_en.Platform(Name) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (Rating BETWEEN 0 AND 10),
    CONSTRAINT chk_price CHECK (Price >= 0)
);

-- Account
CREATE TABLE esquema_videojuegos_en.Account (
    NickName VARCHAR(255) PRIMARY KEY,
    RegisteredAt DATE NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL,
    BalanceAmount NUMERIC(10, 2) NOT NULL,
    MembershipType VARCHAR(255) NOT NULL,
    ExpiresAt DATE,
    AutoRenew BOOLEAN,
    AdsPerSession INTEGER NOT NULL,
    CONSTRAINT chk_membership_type CHECK (MembershipType IN ('premium', 'base')),
    CONSTRAINT chk_ads_for_premium CHECK (
        (MembershipType = 'premium' AND AdsPerSession = 0) OR MembershipType != 'premium'
    ),
    CONSTRAINT chk_base_account CHECK (
        (MembershipType = 'base' AND ExpiresAt IS NULL AND AutoRenew IS NULL) OR MembershipType != 'base'
    )
);

-- GameOwnership
CREATE TABLE esquema_videojuegos_en.GameOwnership (
    NickName VARCHAR(255),
    Videogame VARCHAR(255),
    PurchasedAt DATE NOT NULL,
    TotalPlaytime INT NOT NULL,
    PRIMARY KEY (NickName, Videogame),
    FOREIGN KEY (NickName) REFERENCES esquema_videojuegos_en.Account(NickName) ON DELETE CASCADE,
    FOREIGN KEY (Videogame) REFERENCES esquema_videojuegos_en.Videogame(Name) ON DELETE CASCADE
);
"
echo "Tablas creadas correctamente en 'db2'."
