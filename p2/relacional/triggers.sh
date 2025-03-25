docker exec -i p2-oracle-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<'EOF'
-- ##########################################################
-- Script: docker_oracle_triggers.sql
-- Objetivo:
--   - Eliminar triggers existentes (si existen).
--   - Crear triggers adaptados a Oracle para:
--       1) Verificar saldo suficiente antes de transferencia.
--       2) Actualizar saldo después de ingreso.
--       3) Actualizar saldo después de retirada.
--       4) Eliminar relaciones Cliente-Cuenta al borrar un Cliente.
--       5) Evitar transferencia a la misma cuenta.
--       6) Validar el tipo de operación (INGRESO, TRANSFERENCIA, RETIRO).
--
--   - Insertar datos de prueba que verifiquen el funcionamiento de los triggers.
-- ##########################################################

-- ----------------------------------------------------------
-- 1. Eliminación de TRIGGERS previos (si existieran)
--    Usamos bloques anónimos para evitar errores si no existen.
-- ----------------------------------------------------------

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER check_balance_before_transfer';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER update_balance_after_ingreso';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER update_balance_after_retiro';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER delete_cliente_cuentas';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER check_transferencia_same_account';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER check_tipo_operacion_ingreso';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER check_tipo_operacion_transferencia';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER check_tipo_operacion_retiro';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/
PROMPT "Triggers anteriores (si existían) han sido eliminados."

-- ----------------------------------------------------------
-- 2. Creación de funciones (PL/SQL) y TRIGGERS en ORACLE
--    Se utilizan triggers directos (sin crear funciones aparte)
--    dado que en Oracle es común escribir la lógica en el bloque
--    del propio trigger.
-- ----------------------------------------------------------

-- 2.1. Verificar saldo suficiente antes de una transferencia
CREATE OR REPLACE TRIGGER check_balance_before_transfer
BEFORE INSERT ON Transferencia
FOR EACH ROW
DECLARE
    v_saldo    NUMBER(15,2);
    v_cantidad NUMBER(15,2);
BEGIN
    -- Obtenemos la cantidad y el saldo de la cuenta emisora
    SELECT cantidad
      INTO v_cantidad
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban_emisor;
    
    SELECT saldo
      INTO v_saldo
      FROM Cuenta
     WHERE iban = :NEW.iban_emisor;

    IF v_saldo < v_cantidad THEN
       RAISE_APPLICATION_ERROR(-20001, 'Saldo insuficiente para realizar la transferencia.');
    END IF;
END;
/
PROMPT "Trigger check_balance_before_transfer creado."

-- 2.2. Actualizar saldo después de un ingreso
CREATE OR REPLACE TRIGGER update_balance_after_ingreso
AFTER INSERT ON Ingreso
FOR EACH ROW
DECLARE
    v_cantidad NUMBER(15,2);
BEGIN
    -- Obtenemos la cantidad de la operación
    SELECT cantidad
      INTO v_cantidad
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban;

    -- Actualizamos el saldo
    UPDATE Cuenta
       SET saldo = saldo + v_cantidad
     WHERE iban = :NEW.iban;
END;
/
PROMPT "Trigger update_balance_after_ingreso creado."

-- 2.3. Actualizar saldo después de una retirada
CREATE OR REPLACE TRIGGER update_balance_after_retiro
AFTER INSERT ON Retirada
FOR EACH ROW
DECLARE
    v_cantidad NUMBER(15,2);
BEGIN
    -- Obtenemos la cantidad de la operación
    SELECT cantidad
      INTO v_cantidad
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban;

    -- Actualizamos el saldo
    UPDATE Cuenta
       SET saldo = saldo - v_cantidad
     WHERE iban = :NEW.iban;
END;
/
PROMPT "Trigger update_balance_after_retiro creado."

-- 2.4. Eliminar relaciones en CUENTACLIENTE al borrar un CLIENTE
CREATE OR REPLACE TRIGGER delete_cliente_cuentas
AFTER DELETE ON Cliente
FOR EACH ROW
BEGIN
    DELETE FROM CuentaCliente
     WHERE dni = :OLD.dni;
END;
/
PROMPT "Trigger delete_cliente_cuentas creado."

-- 2.5. Evitar transferencia a la misma cuenta (mismo IBAN emisor/receptor)
CREATE OR REPLACE TRIGGER check_transferencia_same_account
BEFORE INSERT ON Transferencia
FOR EACH ROW
BEGIN
    IF :NEW.iban_emisor = :NEW.iban_receptor THEN
       RAISE_APPLICATION_ERROR(-20002, 'No se puede realizar una transferencia a la misma cuenta.');
    END IF;
END;
/
PROMPT "Trigger check_transferencia_same_account creado."

-- 2.6. Validar que el tipo de operación sea 'INGRESO' para la tabla INGRESO
CREATE OR REPLACE TRIGGER check_tipo_operacion_ingreso
BEFORE INSERT ON Ingreso
FOR EACH ROW
DECLARE
    v_tipo VARCHAR2(20);
BEGIN
    SELECT tipo
      INTO v_tipo
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban;

    IF UPPER(v_tipo) <> 'INGRESO' THEN
       RAISE_APPLICATION_ERROR(-20003, 'El tipo de operación no es "INGRESO".');
    END IF;
END;
/
PROMPT "Trigger check_tipo_operacion_ingreso creado."

-- 2.7. Validar que el tipo de operación sea 'TRANSFERENCIA' para la tabla TRANSFERENCIA
CREATE OR REPLACE TRIGGER check_tipo_operacion_transferencia
BEFORE INSERT ON Transferencia
FOR EACH ROW
DECLARE
    v_tipo VARCHAR2(20);
BEGIN
    SELECT tipo
      INTO v_tipo
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban_emisor;

    IF UPPER(v_tipo) <> 'TRANSFERENCIA' THEN
       RAISE_APPLICATION_ERROR(-20004, 'El tipo de operación no es "TRANSFERENCIA".');
    END IF;
END;
/
PROMPT "Trigger check_tipo_operacion_transferencia creado."

-- 2.8. Validar que el tipo de operación sea 'RETIRO' para la tabla RETIRADA
CREATE OR REPLACE TRIGGER check_tipo_operacion_retiro
BEFORE INSERT ON Retirada
FOR EACH ROW
DECLARE
    v_tipo VARCHAR2(20);
BEGIN
    SELECT tipo
      INTO v_tipo
      FROM OperacionBancaria
     WHERE codigo_numerico = :NEW.codigo_numerico
       AND iban = :NEW.iban;

    IF UPPER(v_tipo) <> 'RETIRO' THEN
       RAISE_APPLICATION_ERROR(-20005, 'El tipo de operación no es "RETIRO".');
    END IF;
END;
/
PROMPT "Trigger check_tipo_operacion_retiro creado."

PROMPT "Todos los triggers han sido creados correctamente."
--

-- ######################################################
-- 3. Inserts de PRUEBA
--    Asumimos que ya existen varias cuentas y un cliente
--    creados según tu script de creación de tablas y datos
--    iniciales. En caso necesario, descomenta o ajusta
--    según tu data real (IBAN, saldo, etc.).
-- ######################################################

PROMPT "Insertando datos de prueba..."

-- Ejemplo de creación rápida de cuentas y clientes
-- (Descomenta si necesitas probar desde cero)
-- INSERT INTO Cliente(dni, nombre, apellidos, edad, telefono, email, direccion)
-- VALUES (1001, 'Juan', 'Pérez', 30, '123456789', 'ejemplo@cliente.com', 'Calle Falsa 123');
-- INSERT INTO Cuenta(iban, numero_cuenta, saldo, fecha_creacion)
-- VALUES ('ES1234567890123456789012', '1234567890', 1000, SYSDATE);
-- INSERT INTO Cuenta(iban, numero_cuenta, saldo, fecha_creacion)
-- VALUES ('ESCORRIENTE1234567890123', '5432109876', 1500, SYSDATE);
-- INSERT INTO Cuenta(iban, numero_cuenta, saldo, fecha_creacion)
-- VALUES ('ESAHORRO1234567890123456', '0987654321', 2000, SYSDATE);
-- INSERT INTO CuentaCliente(dni, iban)
-- VALUES (1001, 'ES1234567890123456789012');

-- ---------------------------
-- Test A1: Transferencia válida
--  1) Creamos la operación general en OperacionBancaria
--  2) Insertamos en Transferencia
-- ---------------------------
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (101, 'ES1234567890123456789012', 500, 'TRANSFERENCIA', SYSDATE, SYSTIMESTAMP);

INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
VALUES (101, 'ES1234567890123456789012', 'ESCORRIENTE1234567890123');

COMMIT;

-- ---------------------------
-- Test A2: Transferencia con saldo insuficiente (debe fallar)
-- ---------------------------
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (102, 'ES1234567890123456789012', 600, 'TRANSFERENCIA', SYSDATE, SYSTIMESTAMP);

BEGIN
    INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
    VALUES (102, 'ES1234567890123456789012', 'ESCORRIENTE1234567890123');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error detectado (saldo insuficiente): ' || SQLERRM);
END;
/

ROLLBACK;

-- ---------------------------
-- Test E: Transferencia a la misma cuenta (debe fallar)
-- ---------------------------
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (103, 'ESCORRIENTE1234567890123', 100, 'TRANSFERENCIA', SYSDATE, SYSTIMESTAMP);

BEGIN
    INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
    VALUES (103, 'ESCORRIENTE1234567890123', 'ESCORRIENTE1234567890123');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error detectado (transferencia a la misma cuenta): ' || SQLERRM);
END;
/

ROLLBACK;

-- ---------------------------
-- Test B: Ingreso (actualiza saldo +300)
-- ---------------------------
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (201, 'ES1234567890123456789012', 300, 'INGRESO', SYSDATE, SYSTIMESTAMP);

INSERT INTO Ingreso (codigo_numerico, codigo_sucursal, iban)
VALUES (201, 1, 'ES1234567890123456789012');

COMMIT;

-- ---------------------------
-- Test C: Retirada (actualiza saldo -500)
-- ---------------------------
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (301, 'ESAHORRO1234567890123456', 500, 'RETIRO', SYSDATE, SYSTIMESTAMP);

INSERT INTO Retirada (codigo_numerico, codigo_sucursal, iban)
VALUES (301, 1, 'ESAHORRO1234567890123456');

COMMIT;

-- ---------------------------
-- Test D: Eliminar cliente (borrado en CuentaCliente)
-- ---------------------------
BEGIN
    DELETE FROM Cliente WHERE dni = 1001;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error al eliminar el cliente: ' || SQLERRM);
END;
/

PROMPT "Inserciones de prueba completadas. Revisa los resultados/errores en la salida."

EXIT;
EOF