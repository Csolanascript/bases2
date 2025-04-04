#!/bin/bash
# Script: docker_postgres_videojuegos_poblar_db2.sh
# Objetivo: Poblar las tablas del esquema 'esquema_videojuegos_en' en la base de datos 'db2'

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="db2"                  # Base de datos destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para poblar las tablas en inglés en 'db2'..."

docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar datos en la tabla 'Company'
INSERT INTO esquema_videojuegos_en.Company (Name, Director, CreatedAt, Country, License, Type) VALUES
('Ubisoft', 'Yves Guillemot', '1986-03-28', 'France', 'Copyright 2025 Ubisoft Entertainment', 'Desarrolladora'),
('Electronic Arts', 'Andrew Wilson', '1982-05-28', 'USA', 'Copyright 2025 Electronic Arts', 'Desarrolladora'),
('Naughty Dog', 'Evan Wells', '1984-01-01', 'USA', 'Copyright 2025 Naughty Dog Studios', 'Desarrolladora'),
('Sony', 'Kenichiro Yoshida', '1946-05-07', 'Japan', 'Copyright 2025 Sony', 'Fabricante'),
('Microsoft', 'Satya Nadella', '1975-04-04', 'USA', 'Copyright 2025 Microsoft', 'Fabricante'),
('Activision', 'Bobby Kotick', '1979-10-01', 'USA', 'Copyright 2025 Activision Blizzard', 'Desarrolladora'),
('Rockstar Games', 'Sam Houser', '1998-12-01', 'USA', 'Copyright 2025 Rockstar Games', 'Desarrolladora'),
('Valve Corporation', 'Gabe Newell', '1996-08-24', 'USA', 'Copyright 2025 Valve Corporation', 'Desarrolladora'),
('Nintendo', 'Shuntaro Furukawa', '1889-09-23', 'Japan', 'Copyright 2025 Nintendo Co., Ltd.', 'Desarrolladora'),
('CD Projekt Red', 'Adam Kicinski', '2002-05-01', 'Poland', 'Copyright 2025 CD Projekt', 'Desarrolladora'),
('Epic Games', 'Tim Sweeney', '1991-07-01', 'USA', 'Copyright 2025 Epic Games', 'Desarrolladora');

-- Insertar datos en la tabla 'Platform'
INSERT INTO esquema_videojuegos_en.Platform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation) VALUES
('PlayStation 5', '2020-11-12', 50000000, 'Sony', 'Ninth'),
('Nintendo Switch', '2017-03-03', 100000000, 'Nintendo', 'Eighth'),
('Xbox One', '2013-11-22', 50000000, 'Microsoft', 'Eighth'),
('PlayStation 4', '2013-11-15', 116000000, 'Sony', 'Eighth'),
('Xbox Series S', '2020-11-10', 20000000, 'Microsoft', 'Ninth'),
('Xbox Series X', '2020-11-10', 40000000, 'Microsoft', 'Ninth');

-- Insertar datos en la tabla 'Videogame'
INSERT INTO esquema_videojuegos_en.Videogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres) VALUES
('The Last of Us Part II', 'Naughty Dog', 'PlayStation 5', 59.99, '2020-06-19', 9.8, 'Adventure'),
('FIFA 21', 'Electronic Arts', 'PlayStation 5', 59.99, '2020-10-09', 8.5, 'Sports'),
('Mario Kart 8 Deluxe', 'Nintendo', 'Nintendo Switch', 59.99, '2017-04-28', 9.5, 'Racing'),
('Assassins Creed Valhalla', 'Ubisoft', 'PlayStation 5', 59.99, '2020-11-10', 8.7, 'Action');

-- Insertar datos en la tabla 'Account'
INSERT INTO esquema_videojuegos_en.Account (NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession) VALUES
('user1', '2021-01-01', 'Juan', 'juan@example.com', 'Spain', 100.00, 'premium', '2023-01-01', TRUE, 0),
('user3', '2024-12-11', 'Cristiano Ronaldo dos Santos Aveiro', 'cr7@example.com', 'Portugal', 60.15, 'premium', '2024-01-01', TRUE, 0),
('user2', '2021-02-15', 'Ana', 'ana@example.com', 'Mexico', 50.00, 'base', NULL, NULL, 5);

-- Insertar datos en la tabla 'GameOwnership'
INSERT INTO esquema_videojuegos_en.GameOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime) VALUES
('user1', 'The Last of Us Part II', '2021-01-05', 10),
('user1', 'FIFA 21', '2021-01-10', 20),
('user1', 'Mario Kart 8 Deluxe', '2021-01-15', 15),
('user3', 'Mario Kart 8 Deluxe', '2024-12-12', 15),
('user3', 'The Last of Us Part II', '2024-12-13', 5),
('user2', 'Assassins Creed Valhalla', '2021-03-01', 30),
('user2', 'FIFA 21', '2021-03-01', 5);

SELECT * FROM esquema_videojuegos_en.Videogame;
SELECT * FROM esquema_videojuegos_en.Platform;
SELECT * FROM esquema_videojuegos_en.Company;
SELECT * FROM esquema_videojuegos_en.Account;
SELECT * FROM esquema_videojuegos_en.GameOwnership;
"

echo "Tablas pobladas correctamente en 'db2'."
