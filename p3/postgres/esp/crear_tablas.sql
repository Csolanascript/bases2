-- Compañía
CREATE TABLE Compania (
    Nombre VARCHAR(300) PRIMARY KEY,
    Director VARCHAR(300),
    FechaCreacion DATE,
    Pais VARCHAR(300)
);

-- Desarrolladora
CREATE TABLE Desarrolladora (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaCopyright VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES Compania(Nombre)
);

-- Fabricante
CREATE TABLE Fabricante (
    Nombre VARCHAR(300) PRIMARY KEY,
    LicenciaFabricacion VARCHAR(300),
    FOREIGN KEY(Nombre) REFERENCES Compania(Nombre)
);

-- Consola
CREATE TABLE Consola (
    Nombre VARCHAR(300) PRIMARY KEY,
    FechaLanzamiento DATE,
    NumVentas INTEGER,
    Fabricante VARCHAR(300),
    Generacion VARCHAR(300),
    FOREIGN KEY(Fabricante) REFERENCES Fabricante(Nombre)
);

-- Videojuego
CREATE TABLE Videojuego (
    Nombre VARCHAR(300) PRIMARY KEY,
    Desarrolladora VARCHAR(300) REFERENCES Desarrolladora(Nombre),
    Consola VARCHAR(300) REFERENCES Consola(Nombre),
    Precio NUMERIC(10,2),
    FechaLanzamiento DATE,
    Puntuacion NUMERIC(3,1),
    FOREIGN KEY(Desarrolladora) REFERENCES Desarrolladora(Nombre),
    FOREIGN KEY(Consola) REFERENCES Consola(Nombre)
);

-- GeneroVideojuego
CREATE TABLE GeneroVideojuego (
    Videojuego VARCHAR(300),
    Genero VARCHAR(300),
    PRIMARY KEY (Videojuego, Genero),
    FOREIGN KEY(Videojuego) REFERENCES Videojuego(Nombre)
);

-- Usuario
CREATE TABLE Usuario (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCreacion DATE,
    Nombre VARCHAR(300),
    Apellido1 VARCHAR(300),
    Apellido2 VARCHAR(300),
    Email VARCHAR(300),
    Pais VARCHAR(300),
    Saldo NUMERIC(10,2),
    EsPremium BOOLEAN
);

-- Usuario Premium
CREATE TABLE UsuarioPremium (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    FechaCaducidad DATE,
    RenovacionAutomatica BOOLEAN,
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario)
);

-- Usuario Corriente
CREATE TABLE UsuarioCorriente (
    NombreUsuario VARCHAR(300) PRIMARY KEY,
    NumeroAnunciosPorSesion INTEGER,
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario)
);

-- PosesionVideojuego
CREATE TABLE PosesionVideojuego (
    NombreUsuario VARCHAR(300),
    Videojuego VARCHAR(300),
    FechaCompra DATE,
    NumHorasJugadas INTEGER,
    PRIMARY KEY (NombreUsuario, Videojuego),
    FOREIGN KEY(NombreUsuario) REFERENCES Usuario(NombreUsuario),
    FOREIGN KEY (Videojuego) REFERENCES Videojuego(Nombre)
);
