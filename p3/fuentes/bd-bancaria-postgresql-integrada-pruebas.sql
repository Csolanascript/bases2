-- Crear conexiones dblink
SELECT dblink_connect('db1_connection', 'dbname=db1 user=postgres password=admin host=localhost');
SELECT dblink_connect('db2_connection', 'dbname=db2 user=postgres password=admin host=localhost');

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

-- Eliminar funciones asociadas
DROP FUNCTION IF EXISTS esquema_global.insert_global_company();
DROP FUNCTION IF EXISTS esquema_global.update_global_company();
DROP FUNCTION IF EXISTS esquema_global.delete_global_company();
DROP FUNCTION IF EXISTS esquema_global.insert_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.update_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.delete_global_videogame();
DROP FUNCTION IF EXISTS esquema_global.insert_global_platform();
DROP FUNCTION IF EXISTS esquema_global.update_global_platform();
DROP FUNCTION IF EXISTS esquema_global.delete_global_platform();
DROP FUNCTION IF EXISTS esquema_global.insert_global_user();
DROP FUNCTION IF EXISTS esquema_global.update_global_user();
DROP FUNCTION IF EXISTS esquema_global.delete_global_user();
DROP FUNCTION IF EXISTS esquema_global.insert_global_ownership();
DROP FUNCTION IF EXISTS esquema_global.update_global_ownership();
DROP FUNCTION IF EXISTS esquema_global.delete_global_ownership();

-- ==========================
-- FUNCIONES PARA INSERTAR, MODIFICAR Y ELIMINAR EN DB2
-- ==========================

-- 1. GlobalCompany
CREATE OR REPLACE FUNCTION esquema_global.insert_global_company()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Company (Name, Director, CreatedAt, Country, License, Type)
                VALUES (%L, %L, %L, %L, %L, %L)',
                NEW.CompanyName, NEW.Director, NEW.CreationDate, NEW.Country, NEW.License, NEW.Type));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_company()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_company()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Company WHERE Name = %L',
                    OLD.CompanyName));
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 2. GlobalVideogame
CREATE OR REPLACE FUNCTION esquema_global.insert_global_videogame()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Videogame (Name, Developer, Console, Price, ReleaseDate, Rating, Genres)
                VALUES (%L, %L, %L, %L, %L, %L, %L)',
                NEW.Name, NEW.Developer, NEW.Console, NEW.Price, NEW.ReleaseDate, NEW.Rating, NEW.Genres));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_videogame()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_videogame()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Videogame WHERE Name = %L',
                    OLD.Name));
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 3. GlobalPlatform
CREATE OR REPLACE FUNCTION esquema_global.insert_global_platform()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Platform (Name, ReleaseDate, SalesVolume, Manufacturer, Generation)
                VALUES (%L, %L, %L, %L, %L)',
                NEW.Name, NEW.ReleaseDate, NEW.SalesVolume, NEW.Manufacturer, NEW.Generation));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_platform()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_platform()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Platform WHERE Name = %L',
                    OLD.Name));
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 4. GlobalUser
CREATE OR REPLACE FUNCTION esquema_global.insert_global_user()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.Account (NickName, RegisteredAt, Name, Email, Country, BalanceAmount, MembershipType, ExpiresAt, AutoRenew, AdsPerSession)
                VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %L, %L)',
                NEW.NickName, NEW.RegisteredAt, NEW.Name, NEW.Email, NEW.Country, NEW.BalanceAmount, NEW.MembershipType, NEW.ExpiresAt, NEW.AutoRenew, NEW.AdsPerSession));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_user()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_user()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.Account WHERE NickName = %L',
                    OLD.NickName));
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 5. GlobalOwnership
CREATE OR REPLACE FUNCTION esquema_global.insert_global_ownership()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM dblink_exec('db2_connection',
        FORMAT('INSERT INTO esquema_videojuegos_en.GameOwnership (NickName, Videogame, PurchasedAt, TotalPlaytime)
                VALUES (%L, %L, %L, %L)',
                NEW.NickName, NEW.Videogame, NEW.PurchasedAt, NEW.TotalPlaytime));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.update_global_ownership()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION esquema_global.delete_global_ownership()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Source = 'db2' THEN
        PERFORM dblink_exec('db2_connection',
            FORMAT('DELETE FROM esquema_videojuegos_en.GameOwnership
                    WHERE NickName = %L AND Videogame = %L',
                    OLD.NickName, OLD.Videogame));
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

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

SELECT CompanyName, Director, CreationDate, Country, License, Type
FROM esquema_global.GlobalCompany;

SELECT Name, Developer, Console, Price, ReleaseDate, Rating, Genres
FROM esquema_global.GlobalVideogame;

SELECT Name, ReleaseDate, SalesVolume, Manufacturer, Generation
FROM esquema_global.GlobalPlatform;

SELECT NickName, RegisteredAt, Name, Email, Country, BalanceAmount,
       MembershipType, ExpiresAt, AutoRenew, AdsPerSession
FROM esquema_global.GlobalUser;

SELECT NickName, Videogame, PurchasedAt, TotalPlaytime
FROM esquema_global.GlobalOwnership;