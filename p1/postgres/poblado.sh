#!/bin/bash
# Script: docker_postgres_tables.sh
# Objetivo: Ingresar al contenedor p1-postgres-1 y crear (si no existe) la tabla 'my_table'
#           para luego poblarla con datos de ejemplo, de forma idempotente.
# Se asume que el contenedor tiene psql disponible.

CONTAINER_NAME="p1-postgres-1"
DATABASE="postgres"
ADMIN_USER="postgres"

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear y poblar tablas en PostgreSQL..."

# Crear tabla si no existe
echo "Creando tabla 'my_table' (si no existe)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "CREATE TABLE IF NOT EXISTS my_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
echo "Tabla 'my_table' creada (o ya existía)."

# Insertar datos de ejemplo solo si la tabla está vacía
echo "Insertando datos de ejemplo en 'my_table' (si está vacía)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "INSERT INTO my_table (name)
SELECT 'Sample Data'
WHERE NOT EXISTS (SELECT 1 FROM my_table);"
echo "Datos insertados (o ya estaban presentes)."

echo "Script docker_postgres_tables.sh completado."
