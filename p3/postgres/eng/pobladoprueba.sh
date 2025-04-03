#!/bin/bash
# Script: docker_postgres_videojuegos_poblar_en.sh
# Objetivo: Poblar las tablas del esquema 'esquema_videojuegos_en' con datos de ejemplo

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear las tablas en inglés..."

# Insertar datos en el esquema 'esquema_videojuegos_en'
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar datos en la tabla 'Company'
INSERT INTO esquema_videojuegos_en.Company (Name, Director, CreatedAt, Country, License, Type) VALUES
('Ubisoft', 'Yves Guillemot', '1986-03-28', 'France', 'Copyright 2025 Ubisoft Entertainment', 'developer'),
('Electronic Arts', 'Andrew Wilson', '1982-05-28', 'USA', 'Copyright 2025 Electronic Arts', 'developer'),
('Naughty Dog', 'Evan Wells', '1984-01-01', 'USA', 'Copyright 2025 Naughty Dog Studios', 'developer'),
('Sony', 'Kenichiro Yoshida', '1946-05-07', 'Japón', 'Copyright 2025 Sony', 'manufacturer'),
('Microsoft', 'Satya Nadella', '1975-04-04', 'Estados Unidos', 'Copyright 2025 Microsoft', 'manufacturer');

-- Insertar datos en la tabla 'Platform'
INSERT INTO esquema_videojuegos_en.Platform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation) VALUES
('PlayStation 5', '2020-11-12', 50000000, 'Sony', 'Ninth'),
('Xbox Series X', '2020-11-10', 40000000, 'Microsoft', 'Ninth');

-- Insertar datos en la tabla 'Videogame'
INSERT INTO esquema_videojuegos_en.Videogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres) VALUES
('The Last of Us Part II', 'Naughty Dog', 'PlayStation 5', 59.99, '2020-06-19', 9.8, 'Adventure'),
('FIFA 21', 'Electronic Arts', 'PlayStation 5', 59.99, '2020-10-09', 8.5, 'Sports'),
('Assassins Creed Valhalla', 'Ubisoft', 'PlayStation 5', 59.99, '2020-11-10', 8.7, 'Action');

-- Insertar datos en la tabla 'Account'
INSERT INTO esquema_videojuegos_en.Account (NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession) VALUES
('user1', '2021-01-01', 'Juan', 'juan@example.com', 'Spain', 100.00, 'premium', '2023-01-01', TRUE, 0),
('user2', '2021-02-15', 'Ana', 'ana@example.com', 'Mexico', 50.00, 'base', NULL, NULL, 5);

-- Insertar datos en la tabla 'GameOwnership'
INSERT INTO esquema_videojuegos_en.GameOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime) VALUES
('user1', 'The Last of Us Part II', '2021-01-05', 10),
('user2', 'FIFA 21', '2021-03-01', 5);


SELECT * FROM esquema_videojuegos_en.Videogame;
SELECT * FROM esquema_videojuegos_en.Platform;
SELECT * FROM esquema_videojuegos_en.Company;
SELECT * FROM esquema_videojuegos_en.Account;
SELECT * FROM esquema_videojuegos_en.GameOwnership;
"

echo "Tablas pobladas correctamente en el esquema 'esquema_videojuegos_en'."
