#!/bin/bash
# Script: docker_postgres_videojuegos_poblar.sh
# Objetivo: Insertar datos de ejemplo en las tablas del esquema de videojuegos (mínimo 3 por tabla)

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"          # Usuario administrador

echo "Insertando datos de ejemplo en la base de datos '$DATABASE' dentro del contenedor '$CONTAINER_NAME'..."

docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Compañía
INSERT INTO Compania (Nombre, Director, FechaCreacion, Pais) VALUES
  ('Nintendo', 'Shuntaro Furukawa', '1889-09-23', 'Japón'),
  ('Sony', 'Kenichiro Yoshida', '1946-05-07', 'Japón'),
  ('Valve', 'Gabe Newell', '1996-08-24', 'Estados Unidos');

-- Desarrolladora
INSERT INTO Desarrolladora (Nombre, LicenciaCopyright) VALUES
  ('Nintendo', 'Licencia-NIN-001'),
  ('Sony', 'Licencia-SONY-002'),
  ('Valve', 'Licencia-VALVE-003');

-- Fabricante
INSERT INTO Fabricante (Nombre, LicenciaFabricacion) VALUES
  ('Nintendo', 'Fabricacion-NIN-001'),
  ('Sony', 'Fabricacion-SONY-002'),
  ('Valve', 'Fabricacion-VALVE-003');

-- Consola
INSERT INTO Consola (Nombre, FechaLanzamiento, NumVentas, Fabricante, Generacion) VALUES
  ('Switch', '2017-03-03', 125000000, 'Nintendo', 'Octava'),
  ('PlayStation 5', '2020-11-12', 40000000, 'Sony', 'Novena'),
  ('Steam Deck', '2022-02-25', 3000000, 'Valve', 'Portátil');

-- Videojuego
INSERT INTO Videojuego (Nombre, Desarrolladora, Consola, Precio, FechaLanzamiento, Puntuacion) VALUES
  ('Zelda: Breath of the Wild', 'Nintendo', 'Switch', 59.99, '2017-03-03', 9.7),
  ('God of War Ragnarok', 'Sony', 'PlayStation 5', 69.99, '2022-11-09', 9.3),
  ('Half-Life: Alyx', 'Valve', 'Steam Deck', 49.99, '2020-03-23', 9.5);

-- GeneroVideojuego
INSERT INTO GeneroVideojuego (Videojuego, Genero) VALUES
  ('Zelda: Breath of the Wild', 'Aventura'),
  ('God of War Ragnarok', 'Acción'),
  ('Half-Life: Alyx', 'Shooter');

-- Usuario
INSERT INTO Usuario (NombreUsuario, FechaCreacion, Nombre, Apellido1, Apellido2, Email, Pais, Saldo, EsPremium) VALUES
  ('link123', '2021-01-15', 'Link', 'Hyrule', 'Warrior', 'link@hyrule.com', 'Japón', 100.00, true),
  ('kratos_olymp', '2022-05-20', 'Kratos', 'Ghost', 'Sparta', 'kratos@olympus.com', 'Grecia', 50.00, true),
  ('alyxvance', '2023-02-10', 'Alyx', 'City', '17', 'alyx@resistance.net', 'Estados Unidos', 75.00, false);

-- UsuarioPremium
INSERT INTO UsuarioPremium (NombreUsuario, FechaCaducidad, RenovacionAutomatica) VALUES
  ('link123', '2025-12-31', true),
  ('kratos_olymp', '2025-10-15', false);

-- UsuarioCorriente
INSERT INTO UsuarioCorriente (NombreUsuario, NumeroAnunciosPorSesion) VALUES
  ('alyxvance', 3);

-- PosesionVideojuego
INSERT INTO PosesionVideojuego (NombreUsuario, Videojuego, FechaCompra, NumHorasJugadas) VALUES
  ('link123', 'Zelda: Breath of the Wild', '2021-01-20', 120),
  ('kratos_olymp', 'God of War Ragnarok', '2022-06-01', 80),
  ('alyxvance', 'Half-Life: Alyx', '2023-03-01', 60);

-- SELECTS para mostrar el contenido de cada tabla
SELECT * FROM Compania;
SELECT * FROM Desarrolladora;
SELECT * FROM Fabricante;
SELECT * FROM Consola;
SELECT * FROM Videojuego;
SELECT * FROM GeneroVideojuego;
SELECT * FROM Usuario;
SELECT * FROM UsuarioPremium;
SELECT * FROM UsuarioCorriente;
SELECT * FROM PosesionVideojuego;
"

echo "✅ Datos de ejemplo insertados correctamente."
