#!/bin/bash

# 📌 IMPORTANTE: Configuración previa en el archivo de Cassandra
# Para habilitar autenticación y autorización en Cassandra, asegúrate de cambiar las siguientes líneas
# en el archivo de configuración `/etc/cassandra/cassandra.yaml`:
#
# authenticator: AllowAllAuthenticator  →  Se ha cambiado por: authenticator: PasswordAuthenticator
# authorizer: AllowAllAuthorizer        →  Se ha cambiado por: authorizer: CassandraAuthorizer
#
# Después de realizar estos cambios, reinicia Cassandra para que los ajustes tengan efecto.

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
GRANT CREATE ON KEYSPACE mi_keyspace TO escritor;
GRANT MODIFY ON KEYSPACE mi_keyspace TO escritor;
GRANT SELECT ON KEYSPACE mi_keyspace TO escritor;
GRANT SELECT ON KEYSPACE mi_keyspace TO lector;

-- Mostrar los datos para verificar que todo esté correcto
SELECT * FROM usuarios;
EOF

echo "✅ Configuración inicial completada."

echo "🔹 Probando acceso con el rol 'lector'..."
docker exec -i $CONTAINER_NAME cqlsh -u lector -p lector <<EOF
USE mi_keyspace;

-- Intentar insertar datos (debería fallar)
INSERT INTO usuarios (id, nombre, edad) VALUES (5, 'Eva', 29);

-- Intentar leer los datos (debería funcionar)
SELECT * FROM usuarios;
EOF

echo "🔹 Probando acceso con el rol 'escritor'..."
docker exec -i $CONTAINER_NAME cqlsh -u escritor -p escritor <<EOF
USE mi_keyspace;

-- Intentar crear una nueva tabla (debería funcionar)
CREATE TABLE IF NOT EXISTS productos (
    id INT PRIMARY KEY,
    nombre TEXT,
    precio DECIMAL
);

-- Intentar leer los datos de usuarios (debería funcionar)
SELECT * FROM usuarios;
EOF

echo "✅ Pruebas finalizadas."