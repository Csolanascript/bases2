-- Crear base de datos 'db_global' (esto no se puede hacer desde una conexión a 'db_global' directamente, así que hazlo desde 'postgres')
-- Solo si no existe
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'db_global') THEN
      EXECUTE 'CREATE DATABASE db_global';
   END IF;
END
$$;

-- Cambiar de base de datos: asegúrate de conectarte a 'db_global' antes de ejecutar lo siguiente

-- Habilitar extensión dblink
CREATE EXTENSION IF NOT EXISTS dblink;

-- Crear esquema
CREATE SCHEMA IF NOT EXISTS esquema_global;

-- Desconectar si había conexiones anteriores activas (por limpieza)
SELECT dblink_disconnect('db1_connection') WHERE dblink_get_connections() @> ARRAY['db1_connection'];
SELECT dblink_disconnect('db2_connection') WHERE dblink_get_connections() @> ARRAY['db2_connection'];

-- Crear conexiones dblink
SELECT dblink_connect('db1_connection', 'dbname=db1 user=postgres password=admin host=localhost');
SELECT dblink_connect('db2_connection', 'dbname=db2 user=postgres password=admin host=localhost');

-- Eliminar vistas y triggers si ya existían
DROP VIEW IF EXISTS esquema_global.GlobalCompany CASCADE;
DROP VIEW IF EXISTS esquema_global.GlobalVideogame CASCADE;
DROP VIEW IF EXISTS esquema_global.GlobalPlatform CASCADE;
DROP VIEW IF EXISTS esquema_global.GlobalUser CASCADE;
DROP VIEW IF EXISTS esquema_global.GlobalOwnership CASCADE;

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
') AS u(NombreUsuario VARCHAR(300)Metroid: Zero Mission (メトロイドゼロミッション, Metoroido Zero Misshon) es un videojuego de acción-aventura de 2004 de la serie Metroid, desarrollado por ..., FechaCreacion DATE, Nombre VARCHAR(300), Apellido1 VARCHAR(300), Apellido2 VARCHAR(300), Email VARCHAR(300), Pais VARCHAR(300), Saldo NUMERIC(10,2), EsPremium BOOLEAN)
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