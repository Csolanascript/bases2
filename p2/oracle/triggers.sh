#!/usr/bin/env bash
docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<SQL

-- Trigger para validar el saldo en la cuenta antes de realizar una transferencia
CREATE OR REPLACE TRIGGER check_balance_before_transfer
BEFORE INSERT ON Transferencias
FOR EACH ROW
DECLARE
    v_saldo NUMBER;
BEGIN
    -- Obtener el saldo actual de la cuenta emisora
    SELECT saldo INTO v_saldo
    FROM Cuentas
    WHERE iban = :NEW.iban;

    -- Verificar que haya suficiente saldo
    IF v_saldo < :NEW.cantidad THEN
        RAISE_APPLICATION_ERROR(-20001, 'Saldo insuficiente para realizar la transferencia.');
    END IF;
END;
/


-- Trigger para actualizar el saldo de la cuenta después de un ingreso
CREATE OR REPLACE TRIGGER update_balance_after_ingreso
AFTER INSERT ON Ingresos
FOR EACH ROW
BEGIN
    UPDATE Cuentas
    SET saldo = saldo + :NEW.cantidad
    WHERE iban = :NEW.iban;
END;
/

-- Trigger para actualizar el saldo de la cuenta después de un retiro
CREATE OR REPLACE TRIGGER update_balance_after_retiro
AFTER INSERT ON Retiradas
FOR EACH ROW
BEGIN
    UPDATE Cuentas
    SET saldo = saldo - :NEW.cantidad
    WHERE iban = :NEW.iban;
END;
/

-- Trigger para eliminar las relaciones de cliente con cuentas cuando el cliente se elimina
CREATE OR REPLACE TRIGGER delete_cliente_cuentas
AFTER DELETE ON Clientes
FOR EACH ROW
BEGIN
    DELETE FROM CuentaCliente
    WHERE dni_cliente = :OLD.dni;
END;
/

-- Trigger para evitar transferencias a la misma cuenta
CREATE OR REPLACE TRIGGER check_transferencia_same_account
BEFORE INSERT ON Transferencias
FOR EACH ROW
BEGIN
    -- Verificar que el IBAN de la cuenta emisora no sea igual al IBAN de la cuenta receptora
    IF :NEW.iban = :NEW.iban_receptor THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede realizar una transferencia a la misma cuenta.');
    END IF;
END;
/

-- Trigger para asegurar que `codigo_numerico` y `iban` coincidan en `OperacionesBancarias` antes de insertar en `Ingresos`
CREATE OR REPLACE TRIGGER check_tipo_operacion_ingreso
BEFORE INSERT ON Ingresos
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    -- Verificar que el `codigo_numerico` y `iban` en `OperacionesBancarias` coincidan con el ingreso
    SELECT tipo_operacion
    INTO v_tipo_operacion
    FROM OperacionesBancarias
    WHERE codigo_numerico = :NEW.codigo_numerico
    AND iban = :NEW.iban;
    
    -- Si el tipo no es 'INGRESO', lanzar un error
    IF v_tipo_operacion != 'INGRESO' THEN
        RAISE_APPLICATION_ERROR(-20003, 'El codigo_numerico y el iban no están asociados a un tipo de operación "INGRESO".');
    END IF;
END;
/


-- Trigger para asegurar que `codigo_numerico` y `iban` coincidan en `OperacionesBancarias` antes de insertar en `Transferencias`
CREATE OR REPLACE TRIGGER check_tipo_operacion_transferencia
BEFORE INSERT ON Transferencias
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    -- Verificar que el `codigo_numerico` y `iban` en `OperacionesBancarias` coincidan con la transferencia
    SELECT tipo_operacion
    INTO v_tipo_operacion
    FROM OperacionesBancarias
    WHERE codigo_numerico = :NEW.codigo_numerico
    AND iban = :NEW.iban;
    
    -- Si el tipo no es 'TRANSFERENCIA', lanzar un error
    IF v_tipo_operacion != 'TRANSFERENCIA' THEN
        RAISE_APPLICATION_ERROR(-20001, 'El codigo_numerico y el iban no están asociados a un tipo de operación "TRANSFERENCIA".');
    END IF;
END;
/


-- Trigger para asegurar que `codigo_numerico` y `iban` coincidan en `OperacionesBancarias` antes de insertar en `Retiradas`
CREATE OR REPLACE TRIGGER check_tipo_operacion_retiro
BEFORE INSERT ON Retiradas
FOR EACH ROW
DECLARE
    v_tipo_operacion VARCHAR2(20);
BEGIN
    -- Verificar que el `codigo_numerico` y `iban` en `OperacionesBancarias` coincidan con la retirada
    SELECT tipo_operacion
    INTO v_tipo_operacion
    FROM OperacionesBancarias
    WHERE codigo_numerico = :NEW.codigo_numerico
    AND iban = :NEW.iban;
    
    -- Si el tipo no es 'RETIRO', lanzar un error
    IF v_tipo_operacion != 'RETIRO' THEN
        RAISE_APPLICATION_ERROR(-20002, 'El codigo_numerico y el iban no están asociados a un tipo de operación "RETIRO".');
    END IF;
END;
/





SQL
