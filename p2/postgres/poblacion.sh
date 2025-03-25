#!/bin/bash
# Script: docker_postgres_insert_and_read.sh
# Objetivo: Insertar muchas filas en las tablas del esquema bancario (clientes, sucursales, cuentas,
#           cuentas de ahorro, cuentas corrientes, relaciones cliente-cuenta y operaciones bancarias)
#           y luego ejecutar SELECTs para comprobar la inserción.
# Se asume que el contenedor tiene psql disponible.

CONTAINER_NAME="15a3fa6d5e95"  # Contenedor de PostgreSQL
DATABASE="p2"                  # Nombre de la base de datos
ADMIN_USER="postgres"          # Usuario administrador de PostgreSQL

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para insertar y leer datos en PostgreSQL..."

SQL_FILE="/tmp/insert_data.sql"
rm -f $SQL_FILE

# Inserciones masivas para clientes
echo "-- Inserciones para cliente" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 1000); do
  AGE=$((RANDOM % 60 + 18))
  echo "INSERT INTO cliente (email, nombre, apellidos, edad, telefono, direccion) VALUES ('cliente${i}@ejemplo.com', 'Nombre${i}', 'Apellido${i}', ${AGE}, '123456789', 'Calle Falsa ${i}');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para sucursales
echo "-- Inserciones para sucursal" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 1000); do
  echo "INSERT INTO sucursal (codigo_sucursal, direccion, telefono) VALUES (${i}, 'Sucursal ${i}', '987654321');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para cuentas base (excluyendo las de las tablas derivadas)
echo "-- Inserciones para cuenta (base)" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
# Usamos el rango 1001-2000 para evitar colisión con registros manuales
for i in $(seq 1001 2000); do
  echo "INSERT INTO cuenta (iban, numero_cuenta, saldo, fecha_creacion) VALUES ('ES12345678901234567890${i}', '123456789${i}', $((RANDOM % 10000 + 100)), CURRENT_DATE);" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para cuentas de ahorro (tabla derivada: cuenta_ahorro)
echo "-- Inserciones para cuenta_ahorro" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
# Rango de IBANs diferente (por ejemplo, 2001-2300)
for i in $(seq 2001 2300); do
  echo "INSERT INTO cuenta_ahorro (iban, numero_cuenta, saldo, fecha_creacion, interes) VALUES ('ESAHORRO${i}', 'AHO${i}', $((RANDOM % 10000 + 100)), CURRENT_DATE, $(echo "scale=2; $((RANDOM % 100)) / 100" | bc));" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para cuentas corrientes (tabla derivada: cuenta_corriente)
echo "-- Inserciones para cuenta_corriente" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
# Rango de IBANs distinto (por ejemplo, 2301-2600)
for i in $(seq 2301 2600); do
  # Asignamos un codigo_sucursal aleatorio entre 1 y 1000 (sucursales creadas anteriormente)
  codigo_sucursal=$((RANDOM % 1000 + 1))
  echo "INSERT INTO cuenta_corriente (iban, numero_cuenta, saldo, fecha_creacion, codigo_sucursal) VALUES ('ESCORR${i}', 'COR${i}', $((RANDOM % 10000 + 100)), CURRENT_DATE, ${codigo_sucursal});" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para la tabla intermedia cuenta_cliente (relacionando clientes con cuentas)
echo "-- Inserciones para cuenta_cliente" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
# Relacionamos de forma aleatoria clientes con cuentas (se asume que las cuentas base tienen IBANs con prefijo 'ES123...')
for i in $(seq 1 1000); do
  cuenta_num=$((RANDOM % 1000 + 1001))
  echo "INSERT INTO cuenta_cliente (email, iban) VALUES ('cliente${i}@ejemplo.com', 'ES12345678901234567890${cuenta_num}');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones masivas para operaciones bancarias y sus subentidades
# Primero, se insertan registros en operacion_bancaria y luego se derivan en cada tipo

# Inserciones para TRANSFERENCIA
echo "-- Inserciones para transferencia" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 300); do
  cod=$((2000 + i))
  # Seleccionar aleatoriamente dos números para las cuentas (emisor y destinatario) asegurando que sean distintos
  issuer_num=$((RANDOM % 1000 + 1001))
  recipient_num=$((RANDOM % 1000 + 1001))
  while [ $recipient_num -eq $issuer_num ]; do
    recipient_num=$((RANDOM % 1000 + 1001))
  done
  iban_emisor="ES12345678901234567890${issuer_num}"
  iban_destinatario="ES12345678901234567890${recipient_num}"
  cantidad=$((RANDOM % 500 + 50))
  echo "INSERT INTO transferencia (codigo_numerico, iban, tipo, cantidad, fecha, hora, iban_destinatario) VALUES (${cod}, '${iban_emisor}', 'TRANSFERENCIA', ${cantidad}, CURRENT_DATE, CURRENT_TIME, '${iban_destinatario}');" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE

# Inserciones para INGRESO
echo "-- Inserciones para ingreso" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 300); do
  cod=$((3000 + i))
  iban="ES12345678901234567890$((1001 + (i % 1000)))"
  cantidad=$((RANDOM % 500 + 50))
  echo "INSERT INTO ingreso (codigo_numerico, iban, tipo, cantidad, fecha, hora, codigo_sucursal) VALUES (${cod}, '${iban}', 'INGRESO', ${cantidad}, CURRENT_DATE, CURRENT_TIME, (SELECT codigo_sucursal FROM sucursal ORDER BY random() LIMIT 1));" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE


# Inserciones para RETIRADA
echo "-- Inserciones para retirada" >> $SQL_FILE
echo "BEGIN;" >> $SQL_FILE
for i in $(seq 1 300); do
  cod=$((4000 + i))
  iban="ESAHORRO$((2001 + (i % 300)))"
  cantidad=$((RANDOM % 500 + 50))
  echo "INSERT INTO retirada (codigo_numerico, iban, tipo, cantidad, fecha, hora, codigo_sucursal) VALUES (${cod}, '${iban}', 'RETIRO', ${cantidad}, CURRENT_DATE, CURRENT_TIME, (SELECT codigo_sucursal FROM sucursal ORDER BY random() LIMIT 1));" >> $SQL_FILE
done
echo "COMMIT;" >> $SQL_FILE


echo "Insertando datos masivos..."
cat $SQL_FILE | docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE

echo "Datos insertados exitosamente."

# Ejecución de SELECTs para verificar las inserciones en cada tabla
echo "Mostrando 10 registros de la tabla cliente:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT email, nombre, apellidos, edad FROM cliente LIMIT 10;"

echo "Mostrando 10 registros de la tabla sucursal:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT codigo_sucursal, direccion, telefono FROM sucursal LIMIT 10;"

echo "Mostrando 10 registros de la tabla cuenta:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT iban, numero_cuenta, saldo FROM cuenta LIMIT 10;"

echo "Mostrando 10 registros de la tabla cuenta_ahorro:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT iban, numero_cuenta, saldo, interes FROM cuenta_ahorro LIMIT 10;"

echo "Mostrando 10 registros de la tabla cuenta_corriente:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT iban, numero_cuenta, saldo, codigo_sucursal FROM cuenta_corriente LIMIT 10;"

echo "Mostrando 10 registros de la tabla cuenta_cliente:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT email, iban FROM cuenta_cliente LIMIT 10;"

echo "Mostrando 10 registros de la tabla transferencia:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT codigo_numerico, iban, tipo, cantidad, iban_destinatario FROM transferencia LIMIT 10;"

echo "Mostrando 10 registros de la tabla ingreso:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT codigo_numerico, iban, tipo, cantidad, codigo_sucursal FROM ingreso LIMIT 10;"

echo "Mostrando 10 registros de la tabla retirada:"
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "SELECT codigo_numerico, iban, tipo, cantidad, codigo_sucursal FROM retirada LIMIT 10;"

echo "Script docker_postgres_insert_and_read.sh completado."
