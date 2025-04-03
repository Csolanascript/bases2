#!/bin/bash
# Script: docker_postgres_videojuegos.sh
# Objetivo: Crear base de datos de videojuegos en contenedor Docker PostgreSQL

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"          # Usuario administrador

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para eliminadas la base de datos de videojuegos..."

# Crear la base de datos si no existe
echo "Verificando existencia de la base de datos '$DATABASE'..."
RESULT=$(docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DATABASE'")
if [ "$RESULT" != "1" ]; then
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $DATABASE"
    echo "Base de datos '$DATABASE' creada."
else
    echo "La base de datos '$DATABASE' ya existe."
fi

# Borrar todas las tablas en orden por dependencias
echo "Eliminando tablas existentes..."
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TABLE IF EXISTS PosesionVideojuego CASCADE;
DROP TABLE IF EXISTS UsuarioCorriente CASCADE;
DROP TABLE IF EXISTS UsuarioPremium CASCADE;
DROP TABLE IF EXISTS Usuario CASCADE;
DROP TABLE IF EXISTS GeneroVideojuego CASCADE;
DROP TABLE IF EXISTS Videojuego CASCADE;
DROP TABLE IF EXISTS Consola CASCADE;
DROP TABLE IF EXISTS Fabricante CASCADE;
DROP TABLE IF EXISTS Desarrolladora CASCADE;
DROP TABLE IF EXISTS Compania CASCADE;
"
echo "Tablas eliminadas."

echo "Tablas eliminadas correctamente."
