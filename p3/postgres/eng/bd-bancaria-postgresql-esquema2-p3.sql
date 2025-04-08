-- Crear esquema si no existe
CREATE SCHEMA IF NOT EXISTS esquema_videojuegos_en;

-- Borrar tablas existentes en orden de dependencias
DROP TABLE IF EXISTS esquema_videojuegos_en.GameOwnership CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Videogame CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Platform CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Account CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos_en.Company CASCADE;

-- Crear tablas

-- Company
CREATE TABLE esquema_videojuegos_en.Company (
    Name VARCHAR(100) PRIMARY KEY,
    Director VARCHAR(100) NOT NULL,
    CreatedAt DATE NOT NULL,
    Country VARCHAR(100) NOT NULL,
    License VARCHAR(500) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    CONSTRAINT chk_company_type CHECK (Type IN ('Desarrolladora', 'Fabricante'))
);

-- Platform
CREATE TABLE esquema_videojuegos_en.Platform (
    Name VARCHAR(100) PRIMARY KEY,
    ReleaseDate DATE NOT NULL,
    SalesVolume INT NOT NULL,
    Manufacturer VARCHAR(100) NOT NULL,
    Generation VARCHAR(50) NOT NULL,
    FOREIGN KEY (Manufacturer) REFERENCES esquema_videojuegos_en.Company(Name)
);

-- Videogame
CREATE TABLE esquema_videojuegos_en.Videogame (
    Name VARCHAR(100) PRIMARY KEY,
    Developer VARCHAR(100) NOT NULL,
    Console VARCHAR(100) NOT NULL,
    Price NUMERIC(10, 2) NOT NULL,
    ReleaseDate DATE NOT NULL,
    Rating INT NOT NULL,
    Genres VARCHAR(250) NOT NULL,
    FOREIGN KEY(Developer) REFERENCES esquema_videojuegos_en.Company(Name) ON DELETE CASCADE,
    FOREIGN KEY(Console) REFERENCES esquema_videojuegos_en.Platform(Name) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (Rating BETWEEN 0 AND 10),
    CONSTRAINT chk_price CHECK (Price >= 0)
);

-- Account
CREATE TABLE esquema_videojuegos_en.Account (
    NickName VARCHAR(100) PRIMARY KEY,
    RegisteredAt DATE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    BalanceAmount NUMERIC(10, 2) NOT NULL,
    MembershipType VARCHAR(100) NOT NULL,
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
    NickName VARCHAR(100),
    Videogame VARCHAR(100),
    PurchasedAt DATE NOT NULL,
    TotalPlaytime INT NOT NULL,
    PRIMARY KEY (NickName, Videogame),
    FOREIGN KEY (NickName) REFERENCES esquema_videojuegos_en.Account(NickName) ON DELETE CASCADE,
    FOREIGN KEY (Videogame) REFERENCES esquema_videojuegos_en.Videogame(Name) ON DELETE CASCADE
);

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