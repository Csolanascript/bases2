#!/bin/bash
# Script: crear_vistas_globales_con_dblink.sh
# Objetivo: Instalar dblink, habilitarlo y crear las vistas globales unificadas entre db1 y db2 en db_global

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="db_global"            # Base de datos global destino
ADMIN_USER="postgres"           # Usuario administrador

# Crear la base de datos 'db_global' si no existe
echo "Verificando existencia de la base de datos '$DATABASE'..."
RESULT=$(docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE'")
if [ "$RESULT" != "1" ]; then
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $DATABASE"
    echo "Base de datos '$DATABASE' creada."
else
    echo "La base de datos '$DATABASE' ya existe."
fi

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
DROP VIEW IF EXISTS esquema_global.GlobalPlatform;
DROP VIEW IF EXISTS esquema_global.GlobalUser;
DROP VIEW IF EXISTS esquema_global.GlobalOwnership;

DROP FUNCTION IF EXISTS esquema_global.insert_global_company();
DROP FUNCTION IF EXISTS esquema_global.insert_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.insert_global_platform();
DROP FUNCTION IF EXISTS esquema_global.insert_global_user();
DROP FUNCTION IF EXISTS esquema_global.insert_global_ownership();
DROP FUNCTION IF EXISTS esquema_global.update_global_company();
DROP FUNCTION IF EXISTS esquema_global.update_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.update_global_platform();
DROP FUNCTION IF EXISTS esquema_global.update_global_user();
DROP FUNCTION IF EXISTS esquema_global.update_global_ownership();
DROP FUNCTION IF EXISTS esquema_global.delete_global_company();
DROP FUNCTION IF EXISTS esquema_global.delete_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.delete_global_platform();
DROP FUNCTION IF EXISTS esquema_global.delete_global_user();
DROP FUNCTION IF EXISTS esquema_global.delete_global_ownership();


-- Eliminar triggers si existen (en orden por vista)
DROP TRIGGER IF EXISTS trg_insert_global_company ON esquema_global.GlobalCompany;
DROP TRIGGER IF EXISTS trg_insert_global_videogame ON esquema_global.GlobalVideogame;
DROP TRIGGER IF EXISTS trg_insert_global_platform ON esquema_global.GlobalPlatform;
DROP TRIGGER IF EXISTS trg_insert_global_user ON esquema_global.GlobalUser;
DROP TRIGGER IF EXISTS trg_insert_global_ownership ON esquema_global.GlobalOwnership;
DROP TRIGGER IF EXISTS trg_update_global_company ON esquema_global.GlobalCompany;
DROP TRIGGER IF EXISTS trg_update_global_videogame ON esquema_global.GlobalVideogame;
DROP TRIGGER IF EXISTS trg_update_global_platform ON esquema_global.GlobalPlatform;
DROP TRIGGER IF EXISTS trg_update_global_user ON esquema_global.GlobalUser;
DROP TRIGGER IF EXISTS trg_update_global_ownership ON esquema_global.GlobalOwnership;
DROP TRIGGER IF EXISTS trg_delete_global_company ON esquema_global.GlobalCompany;
DROP TRIGGER IF EXISTS trg_delete_global_videogame ON esquema_global.GlobalVideogame;
DROP TRIGGER IF EXISTS trg_delete_global_platform ON esquema_global.GlobalPlatform;
DROP TRIGGER IF EXISTS trg_delete_global_user ON esquema_global.GlobalUser;
DROP TRIGGER IF EXISTS trg_delete_global_ownership ON esquema_global.GlobalOwnership;





-- Crear vista global unificada de compañías
CREATE OR REPLACE VIEW esquema_global.GlobalCompany AS

-- Parte 1: Desarrolladoras desde db1
SELECT 
    db1_desarrolladora.Nombre AS CompanyName,
    db1_companies.Director,
    db1_companies.FechaCreacion AS CreationDate,
    db1_companies.Pais AS Country,
    db1_desarrolladora.LicenciaCopyright AS License,
    'Desarrolladora' AS Type,
    'db1' AS Source
FROM dblink('db1_connection', 'SELECT Nombre, LicenciaCopyright FROM esquema_videojuegos.Desarrolladora')
AS db1_desarrolladora(Nombre VARCHAR(300), LicenciaCopyright VARCHAR(300))
LEFT JOIN dblink('db1_connection', 'SELECT Nombre, Director, FechaCreacion, Pais FROM esquema_videojuegos.Compania')
AS db1_companies(Nombre VARCHAR(300), Director VARCHAR(300), FechaCreacion DATE, Pais VARCHAR(300)) 
ON db1_desarrolladora.Nombre = db1_companies.Nombre

UNION

-- Parte 2: Fabricantes desde db1
SELECT 
    db1_fabricante.Nombre AS CompanyName,
    db1_companies.Director,
    db1_companies.FechaCreacion AS CreationDate,
    db1_companies.Pais AS Country,
    db1_fabricante.LicenciaFabricacion AS License,
    'Fabricante' AS Type,
    'db1' AS Source
FROM dblink('db1_connection', 'SELECT Nombre, LicenciaFabricacion FROM esquema_videojuegos.Fabricante')
AS db1_fabricante(Nombre VARCHAR(300), LicenciaFabricacion VARCHAR(300))
LEFT JOIN dblink('db1_connection', 'SELECT Nombre, Director, FechaCreacion, Pais FROM esquema_videojuegos.Compania')
AS db1_companies(Nombre VARCHAR(300), Director VARCHAR(300), FechaCreacion DATE, Pais VARCHAR(300)) 
ON db1_fabricante.Nombre = db1_companies.Nombre

UNION

-- Parte 3: Compañías desde db2
SELECT DISTINCT ON (en_company.Name)
    en_company.Name AS CompanyName,
    en_company.Director,
    en_company.CreatedAt AS CreationDate,
    en_company.Country,
    en_company.License AS License,
    en_company.Type AS Type,
    'db2' AS Source
FROM dblink('db2_connection', 'SELECT Name, Director, CreatedAt, Country, License, Type FROM esquema_videojuegos_en.Company')
AS en_company(Name VARCHAR(300), Director VARCHAR(300), CreatedAt DATE, Country VARCHAR(300), License VARCHAR(300), Type VARCHAR(100))
WHERE en_company.Name NOT IN (
    SELECT Nombre FROM dblink('db1_connection', 'SELECT Nombre FROM esquema_videojuegos.Desarrolladora')
    AS devs(Nombre VARCHAR(300))
    UNION
    SELECT Nombre FROM dblink('db1_connection', 'SELECT Nombre FROM esquema_videojuegos.Fabricante')
    AS fabs(Nombre VARCHAR(300))
);

SELECT * FROM esquema_global.GlobalCompany;

CREATE OR REPLACE VIEW esquema_global.GlobalVideogame AS

-- Parte 1: Videojuegos desde db1
SELECT 
    vj.Nombre AS Name,
    vj.Desarrolladora AS Developer,
    vj.Consola AS Console,
    vj.Precio AS Price,
    vj.FechaLanzamiento AS ReleaseDate,
    vj.Puntuacion AS Rating,
    gen.Generos AS Genres,
    'db1' AS Source
FROM dblink('db1_connection', '
    SELECT v.Nombre, v.Desarrolladora, v.Consola, v.Precio, v.FechaLanzamiento, v.Puntuacion 
    FROM esquema_videojuegos.Videojuego v
') AS vj(Nombre VARCHAR(300), Desarrolladora VARCHAR(300), Consola VARCHAR(300), Precio NUMERIC(10,2), FechaLanzamiento DATE, Puntuacion NUMERIC(3,1))
LEFT JOIN (
    SELECT 
        gv.Videojuego, 
        STRING_AGG(gv.Genero, ', ') AS Generos
    FROM dblink('db1_connection', '
        SELECT Videojuego, Genero FROM esquema_videojuegos.GeneroVideojuego
    ') AS gv(Videojuego VARCHAR(300), Genero VARCHAR(300))
    GROUP BY gv.Videojuego
) AS gen ON vj.Nombre = gen.Videojuego

UNION

-- Parte 2: Videojuegos desde db2
SELECT 
    vg.Name,
    vg.Developer,
    vg.Console,
    vg.Price,
    vg.ReleaseDate,
    vg.Rating,
    vg.Genres,
    'db2' AS Source
FROM dblink('db2_connection', '
    SELECT Name, Developer, Console, Price, ReleaseDate, Rating, Genres FROM esquema_videojuegos_en.Videogame
') AS vg(Name VARCHAR(255), Developer VARCHAR(255), Console VARCHAR(255), Price NUMERIC(10,2), ReleaseDate DATE, Rating INT, Genres VARCHAR(255))
WHERE vg.Name NOT IN (
    SELECT Nombre FROM dblink('db1_connection', '
        SELECT Nombre FROM esquema_videojuegos.Videojuego
    ') AS sub(Nombre VARCHAR(300))
);


SELECT * FROM esquema_global.GlobalVideogame;


CREATE OR REPLACE VIEW esquema_global.GlobalPlatform AS

-- Parte 1: Consolas desde db1
SELECT 
    c.Nombre AS Name,
    c.FechaLanzamiento AS ReleaseDate,
    c.NumVentas AS SalesVolume,
    c.Fabricante AS Manufacturer,
    c.Generacion AS Generation,
    'db1' AS Source
FROM dblink('db1_connection', '
    SELECT Nombre, FechaLanzamiento, NumVentas, Fabricante, Generacion
    FROM esquema_videojuegos.Consola
') AS c(Nombre VARCHAR(300), FechaLanzamiento DATE, NumVentas INTEGER, Fabricante VARCHAR(300), Generacion VARCHAR(300))

UNION

-- Parte 2: Plataformas desde db2
SELECT 
    p.Name,
    p.ReleaseDate,
    p.SalesVolume,
    p.Manufacturer,
    p.Generation,
    'db2' AS Source
FROM dblink('db2_connection', '
    SELECT Name, ReleaseDate, SalesVolume, Manufacturer, Generation
    FROM esquema_videojuegos_en.Platform
') AS p(Name VARCHAR(255), ReleaseDate DATE, SalesVolume INT, Manufacturer VARCHAR(255), Generation VARCHAR(255))
WHERE p.Name NOT IN (
    SELECT Nombre FROM dblink('db1_connection', '
        SELECT Nombre FROM esquema_videojuegos.Consola
    ') AS sub(Nombre VARCHAR(300))
);

SELECT * FROM esquema_global.GlobalPlatform;


CREATE OR REPLACE VIEW esquema_global.GlobalUser AS

-- Parte 1: Usuario Premium (db1)
SELECT 
    u.NombreUsuario AS NickName,
    u.FechaCreacion AS RegisteredAt,
    CONCAT(u.Nombre, ' ', u.Apellido1, ' ', u.Apellido2) AS Name,
    u.Email,
    u.Pais AS Country,
    u.Saldo AS BalanceAmount,
    'premium' AS MembershipType,
    up.FechaCaducidad AS ExpiresAt,
    up.RenovacionAutomatica AS AutoRenew,
    0 AS AdsPerSession,
    'db1' AS Source
FROM dblink('db1_connection', '
    SELECT NombreUsuario, FechaCreacion, Nombre, Apellido1, Apellido2, Email, Pais, Saldo, EsPremium
    FROM esquema_videojuegos.Usuario WHERE EsPremium = true
') AS u(NombreUsuario VARCHAR(300), FechaCreacion DATE, Nombre VARCHAR(300), Apellido1 VARCHAR(300), Apellido2 VARCHAR(300), Email VARCHAR(300), Pais VARCHAR(300), Saldo NUMERIC(10,2), EsPremium BOOLEAN)
JOIN dblink('db1_connection', '
    SELECT NombreUsuario, FechaCaducidad, RenovacionAutomatica FROM esquema_videojuegos.UsuarioPremium
') AS up(NombreUsuario VARCHAR(300), FechaCaducidad DATE, RenovacionAutomatica BOOLEAN)
ON u.NombreUsuario = up.NombreUsuario

UNION

-- Parte 2: Usuario Corriente (db1)
SELECT 
    u.NombreUsuario AS NickName,
    u.FechaCreacion AS RegisteredAt,
    CONCAT(u.Nombre, ' ', u.Apellido1, ' ', u.Apellido2) AS Name,
    u.Email,
    u.Pais AS Country,
    u.Saldo AS BalanceAmount,
    'base' AS MembershipType,
    NULL AS ExpiresAt,
    NULL AS AutoRenew,
    uc.NumeroAnunciosPorSesion AS AdsPerSession,
    'db1' AS Source
FROM dblink('db1_connection', '
    SELECT NombreUsuario, FechaCreacion, Nombre, Apellido1, Apellido2, Email, Pais, Saldo, EsPremium
    FROM esquema_videojuegos.Usuario WHERE EsPremium = false
') AS u(NombreUsuario VARCHAR(300), FechaCreacion DATE, Nombre VARCHAR(300), Apellido1 VARCHAR(300), Apellido2 VARCHAR(300), Email VARCHAR(300), Pais VARCHAR(300), Saldo NUMERIC(10,2), EsPremium BOOLEAN)
JOIN dblink('db1_connection', '
    SELECT NombreUsuario, NumeroAnunciosPorSesion FROM esquema_videojuegos.UsuarioCorriente
') AS uc(NombreUsuario VARCHAR(300), NumeroAnunciosPorSesion INTEGER)
ON u.NombreUsuario = uc.NombreUsuario

UNION

-- Parte 3: Cuentas desde db2
SELECT 
    a.NickName,
    a.RegisteredAt,
    a.Name,
    a.Email,
    a.Country,
    a.BalanceAmount,
    a.MembershipType,
    a.ExpiresAt,
    a.AutoRenew,
    a.AdsPerSession,
    'db2' AS Source
FROM dblink('db2_connection', '
    SELECT NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession
    FROM esquema_videojuegos_en.Account
') AS a(NickName VARCHAR(255), RegisteredAt DATE, Name VARCHAR(255), Email VARCHAR(255), Country VARCHAR(255), BalanceAmount NUMERIC(10,2), MembershipType VARCHAR(255), ExpiresAt DATE, AutoRenew BOOLEAN, AdsPerSession INTEGER)
WHERE a.NickName NOT IN (
    SELECT NombreUsuario FROM dblink('db1_connection', '
        SELECT NombreUsuario FROM esquema_videojuegos.Usuario
    ') AS sub(NombreUsuario VARCHAR(300))
);

SELECT * FROM esquema_global.GlobalUser;


CREATE OR REPLACE VIEW esquema_global.GlobalOwnership AS

-- Parte 1: Posesiones desde db1
SELECT 
    p.NombreUsuario AS NickName,
    p.Videojuego AS Videogame,
    p.FechaCompra AS PurchasedAt,
    p.NumHorasJugadas AS TotalPlaytime,
    'db1' AS Source
FROM dblink('db1_connection', '
    SELECT NombreUsuario, Videojuego, FechaCompra, NumHorasJugadas
    FROM esquema_videojuegos.PosesionVideojuego
') AS p(NombreUsuario VARCHAR(300), Videojuego VARCHAR(300), FechaCompra DATE, NumHorasJugadas INTEGER)

UNION

-- Parte 2: Posesiones desde db2
SELECT 
    o.NickName,
    o.Videogame,
    o.PurchasedAt,
    o.TotalPlaytime,
    'db2' AS Source
FROM dblink('db2_connection', '
    SELECT NickName, Videogame, PurchasedAt, TotalPlaytime
    FROM esquema_videojuegos_en.GameOwnership
') AS o(NickName VARCHAR(255), Videogame VARCHAR(255), PurchasedAt DATE, TotalPlaytime INT)
WHERE (o.NickName, o.Videogame) NOT IN (
    SELECT NombreUsuario, Videojuego FROM dblink('db1_connection', '
        SELECT NombreUsuario, Videojuego
        FROM esquema_videojuegos.PosesionVideojuego
    ') AS sub(NombreUsuario VARCHAR(300), Videojuego VARCHAR(300))
);

SELECT * FROM esquema_global.GlobalOwnership;



-- ==========================
-- FUNCIONES PARA INSERTAR, MODIFICAR Y ELIMINAR EN DB2
-- ==========================

-- 1. GlobalCompany
CREATE OR REPLACE FUNCTION esquema_global.insert_global_company()
RETURNS TRIGGER AS \$\$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Company (Name, Director, CreatedAt, Country, License, Type)
                VALUES (%L, %L, %L, %L, %L, %L)',
                NEW.CompanyName, NEW.Director, NEW.CreationDate, NEW.Country, NEW.License, NEW.Type));
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_company()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('UPDATE esquema_videojuegos_en.Company
                    SET Director = %L,
                        CreatedAt = %L,
                        Country = %L,
                        License = %L,
                        Type = %L
                    WHERE Name = %L',
                    NEW.Director, NEW.CreationDate, NEW.Country, NEW.License, NEW.Type, NEW.CompanyName));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_company()
RETURNS TRIGGER AS \$\$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Company WHERE Name = %L',
                    OLD.CompanyName));
    END IF;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;





-- 2. GlobalVideogame
CREATE OR REPLACE FUNCTION esquema_global.insert_global_videogame()
RETURNS TRIGGER AS \$\$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Videogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres)
                VALUES (%L, %L, %L, %L, %L, %L, %L)',
                NEW.Name, NEW.Developer, NEW.Console, NEW.Price, NEW.ReleaseDate, NEW.Rating, NEW.Genres));
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_videogame()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('UPDATE esquema_videojuegos_en.Videogame
                    SET Developer = %L,
                        Console = %L,
                        Price = %L,
                        ReleaseDate = %L,
                        Rating = %L,
                        Genres = %L
                    WHERE Name = %L',
                    NEW.Developer, NEW.Console, NEW.Price, NEW.ReleaseDate, NEW.Rating, NEW.Genres, OLD.Name));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_videogame()
RETURNS TRIGGER AS \$\$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Videogame WHERE Name = %L',
                    OLD.Name));
    END IF;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;




-- 3. GlobalPlatform
CREATE OR REPLACE FUNCTION esquema_global.insert_global_platform()
RETURNS TRIGGER AS \$\$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Platform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation)
                VALUES (%L, %L, %L, %L, %L)',
                NEW.Name, NEW.ReleaseDate, NEW.SalesVolume, NEW.Manufacturer, NEW.Generation));
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_platform()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('UPDATE esquema_videojuegos_en.Platform
                    SET ReleaseDate = %L,
                        SalesVolume = %L,
                        Manufacturer = %L,
                        Generation = %L
                    WHERE Name = %L',
                    NEW.ReleaseDate, NEW.SalesVolume, NEW.Manufacturer, NEW.Generation, OLD.Name));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_platform()
RETURNS TRIGGER AS \$\$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Platform WHERE Name = %L',
                    OLD.Name));
    END IF;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;

-- 4. GlobalUser
CREATE OR REPLACE FUNCTION esquema_global.insert_global_user()
RETURNS TRIGGER AS \$\$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Account (NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession)
                VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %L, %L)',
                NEW.NickName, NEW.RegisteredAt, NEW.Name, NEW.Email, NEW.Country, NEW.BalanceAmount, NEW.MembershipType, NEW.ExpiresAt, NEW.AutoRenew, NEW.AdsPerSession));
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_user()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('UPDATE esquema_videojuegos_en.Account
                    SET RegisteredAt = %L,
                        Name = %L,
                        Email = %L,
                        Country = %L,
                        BalanceAmount = %L,
                        MembershipType = %L,
                        ExpiresAt = %L,
                        AutoRenew = %L,
                        AdsPerSession = %L
                    WHERE NickName = %L',
                    NEW.RegisteredAt, NEW.Name, NEW.Email, NEW.Country, NEW.BalanceAmount,
                    NEW.MembershipType, NEW.ExpiresAt, NEW.AutoRenew, NEW.AdsPerSession,
                    OLD.NickName));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_user()
RETURNS TRIGGER AS \$\$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Account WHERE NickName = %L',
                    OLD.NickName));
    END IF;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;

-- 5. GlobalOwnership
CREATE OR REPLACE FUNCTION esquema_global.insert_global_ownership()
RETURNS TRIGGER AS \$\$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.GameOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime)
                VALUES (%L, %L, %L, %L)',
                NEW.NickName, NEW.Videogame, NEW.PurchasedAt, NEW.TotalPlaytime));
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_ownership()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('UPDATE esquema_videojuegos_en.GameOwnership
                    SET PurchasedAt = %L,
                        TotalPlaytime = %L
                    WHERE NickName = %L AND Videogame = %L',
                    NEW.PurchasedAt, NEW.TotalPlaytime, OLD.NickName, OLD.Videogame));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_ownership()
RETURNS TRIGGER AS \$\$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.GameOwnership
                    WHERE NickName = %L AND Videogame = %L',
                    OLD.NickName, OLD.Videogame));
    END IF;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;

-- ==========================
-- TRIGGERS SOBRE LAS VISTAS
-- ==========================

-- Trigger para GlobalCompany
CREATE TRIGGER trg_insert_global_company
INSTEAD OF INSERT ON esquema_global.GlobalCompany
FOR EACH ROW
EXECUTE FUNCTION esquema_global.insert_global_company();
CREATE TRIGGER trg_update_global_company
INSTEAD OF UPDATE ON esquema_global.GlobalCompany
FOR EACH ROW EXECUTE FUNCTION esquema_global.update_global_company();
CREATE TRIGGER trg_delete_global_company
INSTEAD OF DELETE ON esquema_global.GlobalCompany
FOR EACH ROW EXECUTE FUNCTION esquema_global.delete_global_company();

-- Trigger para GlobalVideogame
CREATE TRIGGER trg_insert_global_videogame
INSTEAD OF INSERT ON esquema_global.GlobalVideogame
FOR EACH ROW
EXECUTE FUNCTION esquema_global.insert_global_videogame();
CREATE TRIGGER trg_update_global_videogame
INSTEAD OF UPDATE ON esquema_global.GlobalVideogame
FOR EACH ROW EXECUTE FUNCTION esquema_global.update_global_videogame();
CREATE TRIGGER trg_delete_global_videogame
INSTEAD OF DELETE ON esquema_global.GlobalVideogame
FOR EACH ROW EXECUTE FUNCTION esquema_global.delete_global_videogame();

-- Trigger para GlobalPlatform
CREATE TRIGGER trg_insert_global_platform
INSTEAD OF INSERT ON esquema_global.GlobalPlatform
FOR EACH ROW
EXECUTE FUNCTION esquema_global.insert_global_platform();
CREATE TRIGGER trg_update_global_platform
INSTEAD OF UPDATE ON esquema_global.GlobalPlatform
FOR EACH ROW EXECUTE FUNCTION esquema_global.update_global_platform();
CREATE TRIGGER trg_delete_global_platform
INSTEAD OF DELETE ON esquema_global.GlobalPlatform
FOR EACH ROW EXECUTE FUNCTION esquema_global.delete_global_platform();

-- Trigger para GlobalUser
CREATE TRIGGER trg_insert_global_user
INSTEAD OF INSERT ON esquema_global.GlobalUser
FOR EACH ROW
EXECUTE FUNCTION esquema_global.insert_global_user();
CREATE TRIGGER trg_update_global_user
INSTEAD OF UPDATE ON esquema_global.GlobalUser
FOR EACH ROW EXECUTE FUNCTION esquema_global.update_global_user();
CREATE TRIGGER trg_delete_global_user
INSTEAD OF DELETE ON esquema_global.GlobalUser
FOR EACH ROW EXECUTE FUNCTION esquema_global.delete_global_user();

-- Trigger para GlobalOwnership
CREATE TRIGGER trg_insert_global_ownership
INSTEAD OF INSERT ON esquema_global.GlobalOwnership
FOR EACH ROW
EXECUTE FUNCTION esquema_global.insert_global_ownership();
CREATE TRIGGER trg_update_global_ownership
INSTEAD OF UPDATE ON esquema_global.GlobalOwnership
FOR EACH ROW EXECUTE FUNCTION esquema_global.update_global_ownership();
CREATE TRIGGER trg_delete_global_ownership
INSTEAD OF DELETE ON esquema_global.GlobalOwnership
FOR EACH ROW EXECUTE FUNCTION esquema_global.delete_global_ownership();

-- ==========================
-- Pruebas de inserciones, modificaciones y eliminaciones

--GlobalCompany
-- INSERT
INSERT INTO esquema_global.GlobalCompany (CompanyName, Director, CreationDate, Country, License, Type)
VALUES ('PhantomSoft', 'Diana Cruz', '2023-08-12', 'España', 'Copyright 2023 PhantomSoft', 'Desarrolladora');

-- UPDATE
UPDATE esquema_global.GlobalCompany
SET Country = 'México', Director = 'Diana C. Rojas'
WHERE CompanyName = 'PhantomSoft';

-- DELETE
DELETE FROM esquema_global.GlobalCompany
WHERE CompanyName = 'PhantomSoft';


--GlobalVideogame
-- INSERT
INSERT INTO esquema_global.GlobalVideogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres)
VALUES ('Galaxy Strike', 'Ubisoft', 'PlayStation 4', 39.99, '2024-01-10', 8, 'Arcade, Sci-Fi');

-- UPDATE
UPDATE esquema_global.GlobalVideogame
SET Price = 29.99, Rating = 9
WHERE Name = 'Galaxy Strike';

-- DELETE
DELETE FROM esquema_global.GlobalVideogame
WHERE Name = 'Galaxy Strike';



--GlobalPlatform
-- INSERT
INSERT INTO esquema_global.GlobalPlatform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation)
VALUES ('NeoBox', '2023-11-01', 1000000, 'Sony', 'Novena');

-- UPDATE
UPDATE esquema_global.GlobalPlatform
SET SalesVolume = 1500000, Generation = 'Décima'
WHERE Name = 'NeoBox';

-- DELETE
DELETE FROM esquema_global.GlobalPlatform
WHERE Name = 'NeoBox';

--GlobalUser
-- INSERT
INSERT INTO esquema_global.GlobalUser (
    NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession) 
    VALUES ('elena_gamer', '2024-07-10', 'Elena Torres', 'elena@example.com', 'Spain', 100.00,'premium', '2025-07-10', true, 0);

-- UPDATE
UPDATE esquema_global.GlobalUser
SET BalanceAmount = 150.00
WHERE NickName = 'elena_gamer';

-- DELETE
DELETE FROM esquema_global.GlobalUser
WHERE NickName = 'elena_gamer';

--GlobalOwnership
-- INSERT
INSERT INTO esquema_global.GlobalOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime)
VALUES ('user3', 'FIFA 21', '2024-09-16', 5);

-- UPDATE
UPDATE esquema_global.GlobalOwnership
SET TotalPlaytime = 12
WHERE NickName = 'user3' AND Videogame = 'FIFA 21';

-- DELETE
DELETE FROM esquema_global.GlobalOwnership
WHERE NickName = 'user3' AND Videogame = 'FIFA 21';

-- Desconectar las conexiones remotas
SELECT dblink_disconnect('db1_connection');
SELECT dblink_disconnect('db2_connection');
"

echo "Vistas globales creadas correctamente en 'db_global'."
