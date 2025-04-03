#!/bin/bash
# Script: docker_postgres_videojuegos_poblar.sh
# Objetivo: Insertar datos de ejemplo en las tablas del esquema de videojuegos (mínimo 3 por tabla)

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"          # Usuario administrador

echo "Insertando datos de ejemplo en la base de datos '$DATABASE' dentro del contenedor '$CONTAINER_NAME'..."

docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar datos en la tabla Company
INSERT INTO Company (Name, Director, CreatedAt, Country, License, Type) 
VALUES
('GameSoft', 'John Doe', '2000-01-15', 'USA', 'GPL', 'developer'),
('TechPlay', 'Jane Smith', '2005-08-22', 'UK', 'MIT', 'manufacturer'),
('PlayWorld', 'David Johnson', '2010-05-30', 'USA', 'Apache', 'developer'),
('GameTech', 'Michael Lee', '2008-12-05', 'Canada', 'GPL', 'developer'),
('CreativeTech', 'Sophie Brown', '2012-09-18', 'Germany', 'GPL', 'manufacturer');

-- Insertar datos en la tabla Platform
INSERT INTO Platform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation) 
VALUES
('PlayStation 5', '2020-11-12', 1000000, 'TechPlay', 'Next Gen'),
('Xbox Series X', '2020-11-10', 800000, 'GameSoft', 'Next Gen'),
('Nintendo Switch', '2017-03-03', 8000000, 'CreativeTech', 'Current Gen'),
('Xbox One', '2013-11-22', 5000000, 'TechPlay', 'Previous Gen'),
('PlayStation 4', '2013-11-15', 9000000, 'GameSoft', 'Previous Gen');

-- Insertar datos en la tabla Videogame
INSERT INTO Videogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres) 
VALUES
('The Last of Us Part II', 'GameSoft', 'PlayStation 4', 59.99, '2020-06-19', 10, 'Action/Adventure'),
('Halo Infinite', 'GameSoft', 'Xbox Series X', 69.99, '2021-12-08', 9, 'FPS'),
('The Legend of Zelda: Breath of the Wild', 'PlayWorld', 'Nintendo Switch', 59.99, '2017-03-03', 10, 'Action/Adventure'),
('Spider-Man: Miles Morales', 'GameSoft', 'PlayStation 5', 49.99, '2020-11-12', 9, 'Action/Adventure'),
('Forza Horizon 4', 'TechPlay', 'Xbox One', 49.99, '2018-09-28', 8, 'Racing');

-- Insertar datos en la tabla Account
INSERT INTO Account (NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession) 
VALUES
('user123', '2021-05-01', 'Alice Green', 'alice@example.com', 'USA', 50.00, 'premium', '2023-05-01', TRUE, 0),
('user456', '2020-11-15', 'Bob White', 'bob@example.com', 'Canada', 20.00, 'base', null, null, 5),
('user789', '2021-08-30', 'Charlie Brown', 'charlie@example.com', 'UK', 30.00, 'premium', '2024-08-30', TRUE, 0),
('user101', '2021-01-20', 'David Black', 'david@example.com', 'Germany', 40.00, 'base', null , null, 4),
('user202', '2022-02-18', 'Eve Blue', 'eve@example.com', 'Australia', 25.00, 'premium', '2025-02-18', FALSE, 0);

-- Insertar datos en la tabla GameOwnership
INSERT INTO GameOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime) 
VALUES
('user123', 'The Last of Us Part II', '2022-06-20', 20),
('user456', 'Forza Horizon 4', '2021-12-10', 15),
('user789', 'The Legend of Zelda: Breath of the Wild', '2022-03-15', 30),
('user101', 'Halo Infinite', '2021-12-09', 10),
('user202', 'Spider-Man: Miles Morales', '2023-05-15', 25);


SELECT * FROM Company;
SELECT * FROM Platform;
SELECT * FROM Videogame;
SELECT * FROM Account;
SELECT * FROM GameOwnership;
SELECT * FROM Usuario;
"

echo "Datos de prueba insertados."




