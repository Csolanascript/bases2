#!/bin/bash
# Script: crear_vistas_globales_con_dblink.sh
# Objetivo: Instalar dblink, habilitarlo y crear las vistas globales unificadas entre db1 y db2 en db_global

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="db_global"            # Base de datos global destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script para habilitar la extensión dblink y crear las vistas globales..."

# 1. Instalar la extensión dblink en la base de datos 'db_global'
echo "Instalando la extensión dblink en la base de datos '$DATABASE'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "CREATE EXTENSION IF NOT EXISTS dblink;"

# 2. Conectar a db_global y crear el esquema para las vistas globales
echo "Creando esquema 'esquema_global' en 'db_global'..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "CREATE SCHEMA IF NOT EXISTS esquema_global;"

# 3. Crear vistas globales usando dblink

docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Conectar a db1 y db2 usando dblink
SELECT dblink_connect('db1_connection', 'dbname=db1 user=postgres password=admin host=localhost');
SELECT dblink_connect('db2_connection', 'dbname=db2 user=postgres password=admin host=localhost');

DROP VIEW IF EXISTS esquema_global.GlobalCompany;
DROP VIEW IF EXISTS esquema_global.GlobalVideogame;
DROP VIEW IF EXISTS esquema_global.GlobalUser;
-- Crear vista unificada para la tabla 'Company' desde 'db1' y 'db2'
CREATE VIEW esquema_global.GlobalCompany AS
-- Datos de db1 (España)
SELECT 
    db1_companies.Nombre AS CompanyName,
    COALESCE(db1_companies.Director, '') AS Director,  -- Usamos COALESCE para evitar valores nulos
    COALESCE(db1_companies.FechaCreacion, '1900-01-01'::DATE) AS CreationDate,
    COALESCE(db1_companies.Pais, '') AS Country,
    COALESCE(db1_desarrolladora.LicenciaCopyright, '') AS License,
    'Desarrolladora' AS Type  -- Establecer el tipo como 'Desarrolladora' para estas compañías
FROM dblink('db1_connection', 'SELECT Nombre, Director, FechaCreacion, Pais FROM esquema_videojuegos.Compania')
AS db1_companies(Nombre VARCHAR(300), Director VARCHAR(300), FechaCreacion DATE, Pais VARCHAR(300))

LEFT JOIN dblink('db1_connection', 'SELECT Nombre, LicenciaCopyright FROM esquema_videojuegos.Desarrolladora')
AS db1_desarrolladora(Nombre VARCHAR(300), LicenciaCopyright VARCHAR(300)) 
ON db1_companies.Nombre = db1_desarrolladora.Nombre

UNION

SELECT 
    db1_companies.Nombre AS CompanyName,
    COALESCE(db1_companies.Director, '') AS Director,
    COALESCE(db1_companies.FechaCreacion, '1900-01-01'::DATE) AS CreationDate,
    COALESCE(db1_companies.Pais, '') AS Country,
    COALESCE(db1_fabricante.LicenciaFabricacion, '') AS License,
    'Fabricante' AS Type  -- Establecer el tipo como 'Fabricante' para estas compañías
FROM dblink('db1_connection', 'SELECT Nombre, Director, FechaCreacion, Pais FROM esquema_videojuegos.Compania')
AS db1_companies(Nombre VARCHAR(300), Director VARCHAR(300), FechaCreacion DATE, Pais VARCHAR(300))

LEFT JOIN dblink('db1_connection', 'SELECT Nombre, LicenciaFabricacion FROM esquema_videojuegos.Fabricante')
AS db1_fabricante(Nombre VARCHAR(300), LicenciaFabricacion VARCHAR(300)) 
ON db1_companies.Nombre = db1_fabricante.Nombre

UNION

-- Datos de db2 (Inglés)
SELECT 
    db2_companies.Name AS CompanyName,
    COALESCE(db2_companies.Director, '') AS Director,
    COALESCE(db2_companies.CreatedAt, '1900-01-01'::DATE) AS CreationDate,
    COALESCE(db2_companies.Country, '') AS Country,
    COALESCE(db2_companies.License, '') AS License,
    db2_companies.Type AS Type
FROM dblink('db2_connection', 'SELECT Name, Director, CreatedAt, Country, License, Type FROM esquema_videojuegos_en.Company')
AS db2_companies(Name VARCHAR(255), Director VARCHAR(255), CreatedAt DATE, Country VARCHAR(255), License VARCHAR(255), Type VARCHAR(255));



-- Crear vista unificada para la tabla 'Videogame' desde 'db1' y 'db2'
CREATE VIEW esquema_global.GlobalVideogame AS
SELECT 
    Nombre AS VideogameName,
    Desarrolladora AS Developer,
    Consola AS Console,
    Precio AS Price,
    FechaLanzamiento AS ReleaseDate,
    Puntuacion AS Rating
FROM dblink('db1_connection', 'SELECT Nombre, Desarrolladora, Consola, Precio, FechaLanzamiento, Puntuacion FROM esquema_videojuegos.Videojuego')
AS db1_videogames(Nombre VARCHAR(300), Desarrolladora VARCHAR(300), Consola VARCHAR(300), Precio NUMERIC(10,2), FechaLanzamiento DATE, Puntuacion NUMERIC(3,1))

UNION ALL

SELECT 
    Name AS VideogameName,
    Developer AS Developer,
    Console AS Console,
    Price AS Price,
    ReleaseDate AS ReleaseDate,
    Rating AS Rating
FROM dblink('db2_connection', 'SELECT Name, Developer, Console, Price, ReleaseDate, Rating FROM esquema_videojuegos_en.Videogame')
AS db2_videogames(Name VARCHAR(255), Developer VARCHAR(255), Console VARCHAR(255), Price NUMERIC(10,2), ReleaseDate DATE, Rating INT);

-- Crear vista unificada para la tabla 'User' desde 'db1' y 'db2'
CREATE VIEW esquema_global.GlobalUser AS
SELECT 
    NombreUsuario AS UserName,
    FechaCreacion AS CreationDate,
    Nombre AS FirstName,
    Apellido1 AS LastName1,
    Apellido2 AS LastName2,
    Email,
    Pais AS Country,
    Saldo AS Balance,
    EsPremium AS IsPremium
FROM dblink('db1_connection', 'SELECT NombreUsuario, FechaCreacion, Nombre, Apellido1, Apellido2, Email, Pais, Saldo, EsPremium FROM esquema_videojuegos.Usuario')
AS db1_users(NombreUsuario VARCHAR(300), FechaCreacion DATE, Nombre VARCHAR(300), Apellido1 VARCHAR(300), Apellido2 VARCHAR(300), Email VARCHAR(300), Pais VARCHAR(300), Saldo NUMERIC(10,2), EsPremium BOOLEAN)

UNION ALL

SELECT 
    NickName AS UserName,
    RegisteredAt AS CreationDate,
    Name AS FirstName,
    NULL AS LastName1,  -- 'LastName1' no está en 'db2'
    NULL AS LastName2,  -- 'LastName2' no está en 'db2'
    Email,
    Country,
    BalanceAmount AS Balance,
    CASE WHEN MembershipType = 'premium' THEN TRUE ELSE FALSE END AS IsPremium
FROM dblink('db2_connection', 'SELECT NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType FROM esquema_videojuegos_en.Account')
AS db2_users(NickName VARCHAR(255), RegisteredAt DATE, Name VARCHAR(255), Email VARCHAR(255), Country VARCHAR(255), BalanceAmount NUMERIC(10,2), MembershipType VARCHAR(255));

SELECT * FROM esquema_global.GlobalCompany;
SELECT * FROM esquema_global.GlobalVideogame;
SELECT * FROM esquema_global.GlobalUser;

-- Desconectar las conexiones remotas
SELECT dblink_disconnect('db1_connection');
SELECT dblink_disconnect('db2_connection');
"

echo "Vistas globales creadas correctamente en 'db_global'."
