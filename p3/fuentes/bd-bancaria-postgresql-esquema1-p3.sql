-- Crear esquema si no existe
CREATE SCHEMA IF NOT EXISTS esquema_videojuegos;

-- Borrar tablas existentes en orden de dependencias
DROP TABLE IF EXISTS esquema_videojuegos.PosesionVideojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.UsuarioCorriente CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.UsuarioPremium CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Usuario CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.GeneroVideojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Videojuego CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Consola CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Fabricante CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Desarrolladora CASCADE;
DROP TABLE IF EXISTS esquema_videojuegos.Compania CASCADE;

-- Crear tablas

-- Compañía
CREATE TABLE esquema_videojuegos.Compania (
    Nombre VARCHAR(100) PRIMARY KEY,
    Director VARCHAR(100) NOT NULL,
    FechaCreacion DATE NOT NULL,
    Pais VARCHAR(100) NOT NULL
);

-- Desarrolladora
CREATE TABLE esquema_videojuegos.Desarrolladora (
    Nombre VARCHAR(100) PRIMARY KEY,
    LicenciaCopyright VARCHAR(500) NOT NULL,
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Fabricante
CREATE TABLE esquema_videojuegos.Fabricante (
    Nombre VARCHAR(100) PRIMARY KEY,
    LicenciaFabricacion VARCHAR(500) NOT NULL,
    FOREIGN KEY(Nombre) REFERENCES esquema_videojuegos.Compania(Nombre)
);

-- Consola
CREATE TABLE esquema_videojuegos.Consola (
    Nombre VARCHAR(100) PRIMARY KEY,
    FechaLanzamiento DATE NOT NULL,
    NumVentas INTEGER NOT NULL,
    Fabricante VARCHAR(100) NOT NULL,
    Generacion VARCHAR(50) NOT NULL,
    FOREIGN KEY(Fabricante) REFERENCES esquema_videojuegos.Fabricante(Nombre)
);

-- Videojuego
CREATE TABLE esquema_videojuegos.Videojuego (
    Nombre VARCHAR(100) PRIMARY KEY,
    Desarrolladora VARCHAR(100) NOT NULL,
    Consola VARCHAR(100) NOT NULL,
    Precio NUMERIC(10,2) NOT NULL,
    FechaLanzamiento DATE NOT NULL,
    Puntuacion NUMERIC(3,1) NOT NULL,
    FOREIGN KEY(Desarrolladora) REFERENCES esquema_videojuegos.Desarrolladora(Nombre),
    FOREIGN KEY(Consola) REFERENCES esquema_videojuegos.Consola(Nombre),
    CHECK (Puntuacion >= 0 AND Puntuacion <= 10),
    CHECK (Precio >= 0)
);

-- GeneroVideojuego
CREATE TABLE esquema_videojuegos.GeneroVideojuego (
    Videojuego VARCHAR(100) NOT NULL,
    Genero VARCHAR(50) NOT NULL,
    PRIMARY KEY (Videojuego, Genero),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);

-- Usuario
CREATE TABLE esquema_videojuegos.Usuario (
    NombreUsuario VARCHAR(100) PRIMARY KEY,
    FechaCreacion DATE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido1 VARCHAR(50) NOT NULL,
    Apellido2 VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Pais VARCHAR(100) NOT NULL,
    Saldo NUMERIC(10,2) NOT NULL,
    EsPremium BOOLEAN NOT NULL
);

-- Usuario Premium
CREATE TABLE esquema_videojuegos.UsuarioPremium (
    NombreUsuario VARCHAR(100) PRIMARY KEY,
    FechaCaducidad DATE NOT NULL,
    RenovacionAutomatica BOOLEAN NOT NULL,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- Usuario Corriente
CREATE TABLE esquema_videojuegos.UsuarioCorriente (
    NombreUsuario VARCHAR(100) PRIMARY KEY,
    NumeroAnunciosPorSesion INTEGER NOT NULL,
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario)
);

-- PosesionVideojuego
CREATE TABLE esquema_videojuegos.PosesionVideojuego (
    NombreUsuario VARCHAR(100) NOT NULL,
    Videojuego VARCHAR(100) NOT NULL,
    FechaCompra DATE NOT NULL,
    NumHorasJugadas INTEGER NOT NULL,
    PRIMARY KEY (NombreUsuario, Videojuego),
    FOREIGN KEY(NombreUsuario) REFERENCES esquema_videojuegos.Usuario(NombreUsuario),
    FOREIGN KEY(Videojuego) REFERENCES esquema_videojuegos.Videojuego(Nombre)
);

-- Insertar datos en la tabla 'Compania'
INSERT INTO esquema_videojuegos.Compania (Nombre, Director, FechaCreacion, Pais) VALUES
('Ubisoft', 'Yves Guillemot', '1986-03-28', 'Francia'),
('Electronic Arts', 'Andrew Wilson', '1982-05-28', 'Estados Unidos'),
('Naughty Dog', 'Evan Wells', '1984-01-01', 'Estados Unidos'),
('Sony', 'Kenichiro Yoshida', '1946-05-07', 'Japón'),
('Microsoft', 'Satya Nadella', '1975-04-04', 'Estados Unidos');

-- Insertar datos en la tabla 'Desarrolladora'
INSERT INTO esquema_videojuegos.Desarrolladora (Nombre, LicenciaCopyright) VALUES
('Ubisoft', 'Copyright 2025 Ubisoft Entertainment'),
('Electronic Arts', 'Copyright 2025 Electronic Arts'),
('Naughty Dog', 'Copyright 2025 Naughty Dog Studios');

-- Insertar datos en la tabla 'Fabricante'
INSERT INTO esquema_videojuegos.Fabricante (Nombre, LicenciaFabricacion) VALUES
('Sony', 'Copyright 2025 Sony Interactive Entertainment'),
('Microsoft', 'Copyright 2025 Microsoft Corp.');

-- Insertar datos en la tabla 'Consola'
INSERT INTO esquema_videojuegos.Consola (Nombre, FechaLanzamiento, NumVentas, Fabricante, Generacion) VALUES
('PlayStation 5', '2020-11-12', 50000000, 'Sony', 'Novena'),
('Xbox Series X', '2020-11-10', 40000000, 'Microsoft', 'Novena');

-- Insertar datos en la tabla 'Videojuego'
INSERT INTO esquema_videojuegos.Videojuego (Nombre, Desarrolladora, Consola, Precio, FechaLanzamiento, Puntuacion) VALUES
('The Last of Us Part II', 'Naughty Dog', 'PlayStation 5', 59.99, '2020-06-19', 9.8),
('FIFA 21', 'Electronic Arts', 'PlayStation 5', 59.99, '2020-10-09', 8.5),
('Assassins Creed Valhalla', 'Ubisoft', 'PlayStation 5', 59.99, '2020-11-10', 8.7);

-- Insertar datos en la tabla 'GeneroVideojuego'
INSERT INTO esquema_videojuegos.GeneroVideojuego (Videojuego, Genero) VALUES
('The Last of Us Part II', 'Aventura'),
('The Last of Us Part II', 'Acción'),
('The Last of Us Part II', 'Historia'),
('FIFA 21', 'Deportes'),
('Assassins Creed Valhalla', 'Acción');

-- Insertar datos en la tabla 'Usuario'
INSERT INTO esquema_videojuegos.Usuario (NombreUsuario, FechaCreacion, Nombre, Apellido1, Apellido2, Email, Pais, Saldo, EsPremium) VALUES
('user1', '2021-01-01', 'Juan', 'Pérez', 'García', 'juan@example.com', 'España', 100.00, TRUE),
('user2', '2021-02-15', 'Ana', 'López', 'Martínez', 'ana@example.com', 'México', 50.00, FALSE);

-- Insertar datos en la tabla 'UsuarioPremium'
INSERT INTO esquema_videojuegos.UsuarioPremium (NombreUsuario, FechaCaducidad, RenovacionAutomatica) VALUES
('user1', '2023-01-01', TRUE);

-- Insertar datos en la tabla 'UsuarioCorriente'
INSERT INTO esquema_videojuegos.UsuarioCorriente (NombreUsuario, NumeroAnunciosPorSesion) VALUES
('user2', 5);

-- Insertar datos en la tabla 'PosesionVideojuego'
INSERT INTO esquema_videojuegos.PosesionVideojuego (NombreUsuario, Videojuego, FechaCompra, NumHorasJugadas) VALUES
('user1', 'The Last of Us Part II', '2021-01-05', 10),
('user1', 'Assassins Creed Valhalla', '2022-11-10', 25),
('user2', 'The Last of Us Part II', '2021-02-15', 15),
('user2', 'FIFA 21', '2021-03-01', 5);

SELECT * FROM esquema_videojuegos.Compania;
SELECT * FROM esquema_videojuegos.Desarrolladora;
SELECT * FROM esquema_videojuegos.Fabricante;
SELECT * FROM esquema_videojuegos.Consola;
SELECT * FROM esquema_videojuegos.Videojuego;
SELECT * FROM esquema_videojuegos.GeneroVideojuego;
SELECT * FROM esquema_videojuegos.Usuario;
SELECT * FROM esquema_videojuegos.UsuarioPremium;
SELECT * FROM esquema_videojuegos.UsuarioCorriente;
SELECT * FROM esquema_videojuegos.PosesionVideojuego;