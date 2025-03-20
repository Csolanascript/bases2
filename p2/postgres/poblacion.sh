#!/bin/bash
# Script: docker_postgres_insert_and_read.sh
# Objetivo: Insertar muchas filas en las tablas de la base de datos y luego ejecutar SELECTs para comprobar la inserción.
# Se asume que el contenedor tiene psql disponible.

CONTAINER_NAME="eb099d90c2ae"  # Contenedor de PostgreSQL
DATABASE="p2"                  # Nombre de la base de datos
ADMIN_USER="postgres"          # Usuario administrador de PostgreSQL

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para insertar y leer datos en PostgreSQL..."

# Generar archivo SQL temporal para las inserciones masivas
SQL_FILE="/tmp/insert_data.sql"
rm -f $SQL_FILE

echo "-- Inserciones para cliente" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 1000); do
  AGE=$((RANDOM % 60 + 18))
  echo "INSERT INTO cliente (email, nombre, apellidos, edad, telefono, direccion) VALUES ('cliente${i}@ejemplo.com', 'Nombre${i}', 'Apellido${i}', ${AGE}, '123456789', 'Calle Falsa ${i}');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

echo "-- Inserciones para sucursal" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 1000); do
  echo "INSERT INTO sucursal (codigo_sucursal, direccion, telefono) VALUES (${i}, 'Sucursal ${i}', '987654321');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

echo "-- Inserciones para cuenta" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
# Cambiamos el rango para evitar colisión con el registro manual (que usa el IBAN 'ES1234567890123456789012')
for i in $(seq 1001 2000); do
  echo "INSERT INTO cuenta (iban, numero_cuenta, saldo, fecha_creacion) VALUES ('ES12345678901234567890${i}', '123456789${i}', $((RANDOM % 10000 + 100)), CURRENT_DATE);" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

echo "Insertando datos masivos..."
cat $SQL_FILE | docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE

echo "Datos insertados exitosamente."

# Ejecutar SELECTs para leer algunos registros y mostrarlos
echo "Mostrando 10 registros de la tabla cliente:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT email, nombre, apellidos, edad FROM cliente LIMIT 10;"

echo "Mostrando 10 registros de la tabla sucursal:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT codigo_sucursal, direccion, telefono FROM sucursal LIMIT 10;"

echo "Mostrando 10 registros de la tabla cuenta:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT iban, numero_cuenta, saldo FROM cuenta LIMIT 10;"

echo "Script docker_postgres_insert_and_read.sh completado."
