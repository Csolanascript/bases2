#!/bin/bash
# Script: docker_postgres_videojuegos_borrar.sh
# Objetivo: Eliminar todas las tablas y el esquema 'esquema_videojuegos' en la base de datos 'p3'

CONTAINER_NAME="p3-postgres-1"  # Nombre del contenedor Docker
DATABASE="p3"                   # Base de datos destino
ADMIN_USER="postgres"          # Usuario administrador

echo "Eliminando todas las tablas y el esquema 'esquema_videojuegos_en'..."

# Verificar existencia del esquema y eliminarlo junto con las tablas
docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP SCHEMA IF EXISTS esquema_videojuegos_en CASCADE;
"

echo "Esquema 'esquema_videojuegos_en' eliminado correctamente (junto con todas sus tablas)."
