#!/bin/bash

# Nombre del contenedor de Cassandra
CONTAINER_NAME="cassandra-node"

echo "🔹 Ejecutando comandos en Cassandra..."

# Ejecutar todos los comandos en un solo bloque para mantener el contexto del keyspace
docker exec -i $CONTAINER_NAME cqlsh -u cassandra -p cassandra <<EOF
-- Crear el KEYSPACE si no existe
CREATE KEYSPACE IF NOT EXISTS mi_keyspace 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE mi_keyspace;

-- Crear la tabla si no existe
CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY,
    nombre TEXT,
    edad INT
);

-- Insertar datos de ejemplo
INSERT INTO usuarios (id, nombre, edad) VALUES (1, 'Alice', 25);
INSERT INTO usuarios (id, nombre, edad) VALUES (2, 'Bob', 30);
INSERT INTO usuarios (id, nombre, edad) VALUES (3, 'Charlie', 22);
INSERT INTO usuarios (id, nombre, edad) VALUES (4, 'David', 27);

-- Verificar si los roles existen antes de crearlos
-- Si el rol 'lector' no existe, lo creamos
CREATE ROLE IF NOT EXISTS lector WITH PASSWORD = 'lector' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS escritor WITH PASSWORD = 'escritor' AND LOGIN = true;

-- Asignar permisos solo si los roles existen
GRANT MODIFY ON KEYSPACE mi_keyspace TO escritor;
GRANT SELECT ON KEYSPACE mi_keyspace TO escritor;
GRANT SELECT ON KEYSPACE mi_keyspace TO lector;

-- Mostrar los datos para verificar que todo esté correcto
SELECT * FROM usuarios;
EOF

echo "✅ Script finalizado con éxito."
