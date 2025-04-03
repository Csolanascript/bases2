#!/bin/bash
# Script: docker_postgres_videojuegos_poblar_es.sh
# Objetivo: Poblar las tablas del esquema 'esquema_videojuegos' con datos de ejemplo

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"           # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para poblar las tablas en español..."

# Insertar datos en el esquema 'esquema_videojuegos'
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Insertar datos en la tabla 'Compania'
INSERT INTO esquema_videojuegos.Compania (Nombre, Director, FechaCreacion, Pais) VALUES
('Ubisoft', 'Yves Guillemot', '1986-03-28', 'Francia'),
('Electronic Arts', 'Andrew Wilson', '1982-05-28', 'Estados Unidos'),
('Naughty Dog', 'Neil Druckmann', '1984-09-27', 'Estados Unidos'),
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
('user2', 'FIFA 21', '2021-03-01', 5);

SELECT * FROM esquema_videojuegos.Videojuego;
SELECT * FROM esquema_videojuegos.Compania;
SELECT * FROM esquema_videojuegos.Desarrolladora;
SELECT * FROM esquema_videojuegos.Fabricante;
SELECT * FROM esquema_videojuegos.Consola;
SELECT * FROM esquema_videojuegos.GeneroVideojuego;
SELECT * FROM esquema_videojuegos.Usuario;
SELECT * FROM esquema_videojuegos.UsuarioPremium;
SELECT * FROM esquema_videojuegos.UsuarioCorriente;
SELECT * FROM esquema_videojuegos.PosesionVideojuego;
"

echo "Tablas pobladas correctamente en el esquema 'esquema_videojuegos'."
