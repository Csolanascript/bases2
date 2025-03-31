#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos (según tu docker-compose.yml)
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/crear_triggers.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

--#SET TERMINATOR @

-- Verifica saldo antes de una transferencia
CREATE TRIGGER check_balance_before_transfer
NO CASCADE BEFORE INSERT ON Transferencia
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   DECLARE v_saldo DECIMAL(15,2);
   SELECT Saldo INTO v_saldo FROM FINAL TABLE (SELECT * FROM Cuenta WHERE id_cuenta = N.Cuenta_Emisora);
   IF v_saldo < N.Cantidad THEN
      SIGNAL SQLSTATE '75001' SET MESSAGE_TEXT = 'Saldo insuficiente para realizar la transferencia.';
   END IF;
END@

-- Suma cantidad al saldo tras un ingreso
CREATE TRIGGER update_balance_after_ingreso
AFTER INSERT ON Ingreso
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   UPDATE Cuenta SET Saldo = Saldo + N.Cantidad WHERE id_cuenta = N.Cuenta_Emisora;
END@

-- Resta cantidad del saldo tras un retiro
CREATE TRIGGER update_balance_after_retiro
AFTER INSERT ON Retirada
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   UPDATE Cuenta SET Saldo = Saldo - N.Cantidad WHERE id_cuenta = N.Cuenta_Emisora;
END@

-- Elimina entradas en 'Tiene' cuando se elimina un cliente
CREATE TRIGGER delete_cliente_tiene
AFTER DELETE ON Cliente
REFERENCING OLD AS O
FOR EACH ROW
BEGIN ATOMIC
   DELETE FROM Tiene WHERE DNI = O.id_cliente;
END@

-- Evita transferencia a la misma cuenta
CREATE TRIGGER check_transferencia_same_account
NO CASCADE BEFORE INSERT ON Transferencia
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   IF N.Cuenta_Emisora = N.Cuenta_Receptor THEN
      SIGNAL SQLSTATE '75002' SET MESSAGE_TEXT = 'No se puede transferir a la misma cuenta.';
   END IF;
END@

-- Verifica que el tipo de operación sea INGRESO para tabla Ingreso
CREATE TRIGGER check_tipo_operacion_ingreso
NO CASCADE BEFORE INSERT ON Ingreso
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   DECLARE v_tipo VARCHAR(255);
   SELECT Tipo INTO v_tipo FROM Operacion_Bancaria WHERE id_operacion = N.id_operacion;
   IF v_tipo != 'INGRESO' THEN
      SIGNAL SQLSTATE '75003' SET MESSAGE_TEXT = 'La operación no es un INGRESO.';
   END IF;
END@

-- Verifica que el tipo sea TRANSFERENCIA para la tabla Transferencia
CREATE TRIGGER check_tipo_operacion_transferencia
NO CASCADE BEFORE INSERT ON Transferencia
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   DECLARE v_tipo VARCHAR(255);
   SELECT Tipo INTO v_tipo FROM Operacion_Bancaria WHERE id_operacion = N.id_operacion;
   IF v_tipo != 'TRANSFERENCIA' THEN
      SIGNAL SQLSTATE '75004' SET MESSAGE_TEXT = 'La operación no es una TRANSFERENCIA.';
   END IF;
END@

-- Verifica que el tipo sea RETIRO para tabla Retirada
CREATE TRIGGER check_tipo_operacion_retiro
NO CASCADE BEFORE INSERT ON Retirada
REFERENCING NEW AS N
FOR EACH ROW
BEGIN ATOMIC
   DECLARE v_tipo VARCHAR(255);
   SELECT Tipo INTO v_tipo FROM Operacion_Bancaria WHERE id_operacion = N.id_operacion;
   IF v_tipo != 'RETIRO' THEN
      SIGNAL SQLSTATE '75005' SET MESSAGE_TEXT = 'La operación no es un RETIRO.';
   END IF;
END@

EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > crear_triggers.sql

# Copiar el archivo al contenedor DB2
docker cp crear_triggers.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f crear_triggers.sql

echo "Creación de triggers completada en DB2 dentro del contenedor $CONTAINER_NAME."
