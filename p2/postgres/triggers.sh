#!/bin/bash
# Script: docker_postgres_create_triggers.sh
# Objetivo:
#  - Eliminar triggers y funciones existentes (si existen).
#  - Crear triggers adaptados a PostgreSQL para validar:
#       • Que haya saldo suficiente antes de una transferencia.
#       • Que se actualice el saldo después de un ingreso o retirada.
#       • Que se eliminen las relaciones de cliente con cuenta al borrar un cliente.
#       • Que no se pueda realizar una transferencia a la misma cuenta.
#       • Que el campo 'tipo' (extraído de operacion_bancaria) coincida con el tipo de operación
#         esperado al insertar en las tablas derivadas (ingreso, transferencia, retirada).
#
#  - Ejecutar inserts de prueba para comprobar el funcionamiento de los triggers.
#
# Se asume que:
#  • El contenedor de Postgres se llama "eb099d90c2ae".
#  • La base de datos se llama "p2".
#  • El usuario administrador es "postgres".

CONTAINER_NAME="15a3fa6d5e95"  # Nombre del contenedor de PostgreSQL
DATABASE="p2"                  # Nombre de la base de datos
ADMIN_USER="postgres"          # Usuario administrador

echo "Eliminando triggers y funciones existentes (si existen)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DROP TRIGGER IF EXISTS check_balance_before_transfer ON transferencia;
DROP FUNCTION IF EXISTS check_balance_before_transfer_func();

DROP TRIGGER IF EXISTS update_balance_after_ingreso ON ingreso;
DROP FUNCTION IF EXISTS update_balance_after_ingreso_func();

DROP TRIGGER IF EXISTS update_balance_after_retiro ON retirada;
DROP FUNCTION IF EXISTS update_balance_after_retiro_func();

DROP TRIGGER IF EXISTS delete_cliente_cuentas ON cliente;
DROP FUNCTION IF EXISTS delete_cliente_cuentas_func();

DROP TRIGGER IF EXISTS check_transferencia_same_account ON transferencia;
DROP FUNCTION IF EXISTS check_transferencia_same_account_func();

DROP TRIGGER IF EXISTS check_tipo_operacion_ingreso ON ingreso;
DROP FUNCTION IF EXISTS check_tipo_operacion_ingreso_func();

DROP TRIGGER IF EXISTS check_tipo_operacion_transferencia ON transferencia;
DROP FUNCTION IF EXISTS check_tipo_operacion_transferencia_func();

DROP TRIGGER IF EXISTS check_tipo_operacion_retiro ON retirada;
DROP FUNCTION IF EXISTS check_tipo_operacion_retiro_func();
"

echo "Creando funciones y triggers..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
-- Función y trigger para validar el saldo antes de una transferencia
CREATE OR REPLACE FUNCTION check_balance_before_transfer_func() RETURNS trigger AS \$\$
DECLARE
    v_saldo NUMERIC;
BEGIN
    SELECT saldo INTO v_saldo FROM cuenta WHERE iban = NEW.iban;
    IF v_saldo < NEW.cantidad THEN
        RAISE EXCEPTION 'Saldo insuficiente para realizar la transferencia.';
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER check_balance_before_transfer
BEFORE INSERT ON transferencia
FOR EACH ROW
EXECUTE FUNCTION check_balance_before_transfer_func();

-- Función y trigger para actualizar el saldo después de un ingreso
CREATE OR REPLACE FUNCTION update_balance_after_ingreso_func() RETURNS trigger AS \$\$
BEGIN
    UPDATE cuenta SET saldo = saldo + NEW.cantidad WHERE iban = NEW.iban;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER update_balance_after_ingreso
AFTER INSERT ON ingreso
FOR EACH ROW
EXECUTE FUNCTION update_balance_after_ingreso_func();

-- Función y trigger para actualizar el saldo después de una retirada
CREATE OR REPLACE FUNCTION update_balance_after_retiro_func() RETURNS trigger AS \$\$
BEGIN
    UPDATE cuenta SET saldo = saldo - NEW.cantidad WHERE iban = NEW.iban;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER update_balance_after_retiro
AFTER INSERT ON retirada
FOR EACH ROW
EXECUTE FUNCTION update_balance_after_retiro_func();

-- Función y trigger para eliminar las relaciones de cliente con cuenta al borrar un cliente
CREATE OR REPLACE FUNCTION delete_cliente_cuentas_func() RETURNS trigger AS \$\$
BEGIN
    DELETE FROM cuenta_cliente WHERE email = OLD.email;
    RETURN OLD;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER delete_cliente_cuentas
AFTER DELETE ON cliente
FOR EACH ROW
EXECUTE FUNCTION delete_cliente_cuentas_func();

-- Función y trigger para evitar transferencias a la misma cuenta
CREATE OR REPLACE FUNCTION check_transferencia_same_account_func() RETURNS trigger AS \$\$
BEGIN
    IF NEW.iban = NEW.iban_destinatario THEN
        RAISE EXCEPTION 'No se puede realizar una transferencia a la misma cuenta.';
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER check_transferencia_same_account
BEFORE INSERT ON transferencia
FOR EACH ROW
EXECUTE FUNCTION check_transferencia_same_account_func();

-- Función y trigger para validar que el codigo_numerico y el iban correspondan a una operación de INGRESO
CREATE OR REPLACE FUNCTION check_tipo_operacion_ingreso_func() RETURNS trigger AS \$\$
DECLARE
    v_tipo TEXT;
BEGIN
    SELECT tipo INTO v_tipo FROM operacion_bancaria
     WHERE codigo_numerico = NEW.codigo_numerico AND iban = NEW.iban;
    IF v_tipo <> 'INGRESO' THEN
        RAISE EXCEPTION 'El codigo_numerico y el iban no están asociados a un tipo de operación \"INGRESO\".';
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER check_tipo_operacion_ingreso
BEFORE INSERT ON ingreso
FOR EACH ROW
EXECUTE FUNCTION check_tipo_operacion_ingreso_func();

-- Función y trigger para validar que el codigo_numerico y el iban correspondan a una operación de TRANSFERENCIA
CREATE OR REPLACE FUNCTION check_tipo_operacion_transferencia_func() RETURNS trigger AS \$\$
DECLARE
    v_tipo TEXT;
BEGIN
    SELECT tipo INTO v_tipo FROM operacion_bancaria
     WHERE codigo_numerico = NEW.codigo_numerico AND iban = NEW.iban;
    IF v_tipo <> 'TRANSFERENCIA' THEN
        RAISE EXCEPTION 'El codigo_numerico y el iban no están asociados a un tipo de operación \"TRANSFERENCIA\".';
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER check_tipo_operacion_transferencia
BEFORE INSERT ON transferencia
FOR EACH ROW
EXECUTE FUNCTION check_tipo_operacion_transferencia_func();

-- Función y trigger para validar que el codigo_numerico y el iban correspondan a una operación de RETIRO
CREATE OR REPLACE FUNCTION check_tipo_operacion_retiro_func() RETURNS trigger AS \$\$
DECLARE
    v_tipo TEXT;
BEGIN
    SELECT tipo INTO v_tipo FROM operacion_bancaria
     WHERE codigo_numerico = NEW.codigo_numerico AND iban = NEW.iban;
    IF v_tipo <> 'RETIRO' THEN
        RAISE EXCEPTION 'El codigo_numerico y el iban no están asociados a un tipo de operación \"RETIRO\".';
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER check_tipo_operacion_retiro
BEFORE INSERT ON retirada
FOR EACH ROW
EXECUTE FUNCTION check_tipo_operacion_retiro_func();
"

echo "Triggers y funciones creados exitosamente en la base de datos '$DATABASE'."

echo "Insertando datos de prueba para verificar el funcionamiento de los triggers..."

#------------------------------------------------------------------------------
# Nota:
# Se asume que el script de creación de tablas e inserción de datos base ya
# creó:
#   • La cuenta 'ES1234567890123456789012' con saldo 1000.00.
#   • La cuenta de ahorro 'ESAHORRO1234567890123456' con saldo 2000.00.
#   • La cuenta corriente 'ESCORRIENTE1234567890123' con saldo 1500.00.
#   • Un cliente con email 'ejemplo@cliente.com' y la relación en cuenta_cliente.
#------------------------------------------------------------------------------

# Test A1: Insertar una transferencia válida (suficiente saldo y cuentas distintas)
echo "Test A1: Insertar transferencia válida (saldo suficiente)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
INSERT INTO transferencia (codigo_numerico, iban, tipo, cantidad, fecha, hora, iban_destinatario)
VALUES (101, 'ES1234567890123456789012', 'TRANSFERENCIA', 500.00, CURRENT_DATE, CURRENT_TIME, 'ESCORRIENTE1234567890123');
"

# Test A2: Intentar insertar una transferencia con saldo insuficiente (debe fallar)
echo "Test A2: Insertar transferencia con saldo insuficiente (debe fallar)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
INSERT INTO transferencia (codigo_numerico, iban, tipo, cantidad, fecha, hora, iban_destinatario)
VALUES (102, 'ES1234567890123456789012', 'TRANSFERENCIA', 600.00, CURRENT_DATE, CURRENT_TIME, 'ESCORRIENTE1234567890123');
"

# Test E: Intentar insertar una transferencia a la misma cuenta (debe fallar)
echo "Test E: Insertar transferencia a la misma cuenta (debe fallar)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
INSERT INTO transferencia (codigo_numerico, iban, tipo, cantidad, fecha, hora, iban_destinatario)
VALUES (103, 'ESCORRIENTE1234567890123', 'TRANSFERENCIA', 100.00, CURRENT_DATE, CURRENT_TIME, 'ESCORRIENTE1234567890123');
"

# Test B: Insertar un ingreso para actualizar el saldo (cuenta 'ES1234567890123456789012')
echo "Test B: Insertar ingreso para actualizar saldo..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
INSERT INTO ingreso (codigo_numerico, iban, tipo, cantidad, fecha, hora, codigo_sucursal)
VALUES (201, 'ES1234567890123456789012', 'INGRESO', 300.00, CURRENT_DATE, CURRENT_TIME, 1);
"

# Test C: Insertar una retirada para actualizar el saldo (cuenta 'ESAHORRO1234567890123456')
echo "Test C: Insertar retirada para actualizar saldo..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
INSERT INTO retirada (codigo_numerico, iban, tipo, cantidad, fecha, hora, codigo_sucursal)
VALUES (301, 'ESAHORRO1234567890123456', 'RETIRO', 500.00, CURRENT_DATE, CURRENT_TIME, 1);
"

# Test D: Eliminar el cliente y comprobar que se borran las relaciones en cuenta_cliente
echo "Test D: Eliminar cliente 'ejemplo@cliente.com' (se deben borrar sus relaciones en cuenta_cliente)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "
DELETE FROM cliente WHERE email = 'ejemplo@cliente.com';
"

echo "Inserciones de prueba completadas. Verifica los resultados (errores y actualizaciones de saldo) en los logs del contenedor."
