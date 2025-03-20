#!/bin/bash
# Script: docker_postgres_insert_and_read.sh
# Objetivo: Insertar grandes cantidades de datos en las tablas de la base de datos
#           y luego leer y mostrar los datos por pantalla para verificar el funcionamiento.

CONTAINER_NAME="eb099d90c2ae"  # Contenedor de PostgreSQL
DATABASE="p2"  # Nombre de la base de datos
ADMIN_USER="postgres"  # Usuario administrador de PostgreSQL

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para insertar y leer datos en PostgreSQL..."

# Insertar datos de ejemplo en las tablas de forma masiva

echo "Insertando grandes cantidades de datos en las tablas..."

# Generamos 1000 registros para la tabla cliente
for i in $(seq 1 1000); do
  docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
    INSERT INTO cliente (email, nombre, apellidos, edad, telefono, direccion)
    VALUES ('cliente$i@ejemplo.com', 'Nombre$i', 'Apellido$i', $((RANDOM % 60 + 18)), '123456789', 'Calle Falsa $i');
  "
done

# Generamos 1000 registros para la tabla sucursal
for i in $(seq 1 1000); do
  docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
    INSERT INTO sucursal (codigo_sucursal, direccion, telefono)
    VALUES ($i, 'Sucursal $i', '987654321');
  "
done

# Generamos 1000 registros para la tabla cuenta
for i in $(seq 1 1000); do
  docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
    INSERT INTO cuenta (iban, numero_cuenta, saldo, fecha_creacion)
    VALUES ('ES12345678901234567890$i', '123456789$i', $((RANDOM % 10000 + 100)), CURRENT_DATE);
  "
done

echo "Datos insertados exitosamente."

# Leer los datos desde las tablas y mostrarlos por pantalla

echo "Leyendo los datos desde las tablas y mostrándolos por pantalla..."

docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
SELECT email, nombre, apellidos, edad FROM cliente LIMIT 10;
"

docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
SELECT codigo_sucursal, direccion, telefono FROM sucursal LIMIT 10;
"

docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
SELECT iban, numero_cuenta, saldo FROM cuenta LIMIT 10;
"

echo "Datos leídos y mostrados correctamente."

echo "Script docker_postgres_insert_and_read.sh completado."
