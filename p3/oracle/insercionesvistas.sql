DROP TRIGGER VistaCuenta_Insert;
DROP TRIGGER VistaCuenta_Update;
DROP TRIGGER VistaCuentaCliente_Insert;
DROP TRIGGER VistaOperacionBancaria_Insert;
DROP TRIGGER VistaOperacionBancaria_Update;
DROP TRIGGER VistaSucursal_Insert;
DROP TRIGGER VistaAhorro_Insert;
DROP TRIGGER VistaCorriente_Insert;

CREATE OR REPLACE TRIGGER VistaCuenta_Insert
INSTEAD OF INSERT ON VistaCuenta
FOR EACH ROW
DECLARE
  v_len NUMBER;
BEGIN
  v_len := LENGTH(:NEW.iban);
  IF v_len < 5 THEN
    RAISE_APPLICATION_ERROR(-20001, 'IBAN inválido: longitud mínima no alcanzada');
  END IF;

  -- 1) Inserta en la tabla base "Cuenta"
  INSERT INTO Cuenta (
    iban,
    numero_cuenta,
    saldo,
    fecha_creacion
  ) VALUES (
    :NEW.iban,
    :NEW.numero_cuenta,
    :NEW.saldo,
    :NEW.fecha_creacion
  );
END;
/
CREATE OR REPLACE TRIGGER VistaCorriente_Insert
INSTEAD OF INSERT ON VistaCuentaCorriente
FOR EACH ROW
BEGIN
  -- Inserta en la tabla Corriente
  INSERT INTO Corriente (
    iban,
    codigo_sucursal
  ) VALUES (
    :NEW.iban,
    :NEW.codigo_sucursal
  );
  
END;
/

CREATE OR REPLACE TRIGGER VistaAhorro_Insert
INSTEAD OF INSERT ON VistaCuentaAhorro
FOR EACH ROW
BEGIN
  -- Inserta en la tabla Ahorro
  INSERT INTO Ahorro (
    iban,
    interes
  ) VALUES (
    :NEW.iban,
    :NEW.interes
  );
END;
/


CREATE OR REPLACE TRIGGER VistaCuenta_Update
INSTEAD OF UPDATE ON VistaCuenta
FOR EACH ROW
DECLARE
  v_exists NUMBER;
  v_old_iban VARCHAR2(34);
BEGIN
  -- Verificar si la cuenta antigua existe
  v_old_iban := :OLD.iban;
  SELECT COUNT(*) INTO v_exists
    FROM Cuenta
   WHERE iban = v_old_iban;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20031, 'No se puede actualizar: la cuenta no existe en la base local');
  ELSE
    -- Actualiza la tabla "Cuenta"
    UPDATE Cuenta
       SET saldo          = :NEW.saldo,
           numero_cuenta  = :NEW.numero_cuenta,
           fecha_creacion = :NEW.fecha_creacion
     WHERE iban = v_old_iban;
  END IF;
END;
/


CREATE OR REPLACE TRIGGER VistaCuentaCliente_Insert
INSTEAD OF INSERT ON VistaCuentaCliente
FOR EACH ROW
BEGIN
  INSERT INTO CuentaCliente (dni, iban)
  VALUES (:NEW.dni, :NEW.iban);
END;
/


CREATE OR REPLACE TRIGGER VistaCuentaCliente_Insert
INSTEAD OF INSERT ON VistaCuentaCliente
FOR EACH ROW
BEGIN
  INSERT INTO CuentaCliente (dni, iban)
  VALUES (:NEW.dni, :NEW.iban);
END;
/


CREATE OR REPLACE TRIGGER VistaOperacionBancaria_Insert
INSTEAD OF INSERT ON VistaOperacionBancaria
FOR EACH ROW
BEGIN
  INSERT INTO OperacionBancaria (
    codigo_numerico,
    iban,
    cantidad,
    fecha,
    hora
  ) VALUES (
    :NEW.codigo_numerico,
    :NEW.iban,
    :NEW.cantidad,
    :NEW.fecha,
    :NEW.hora
  );
END;
/


CREATE OR REPLACE TRIGGER VistaOperacionBancaria_Update
INSTEAD OF UPDATE ON VistaOperacionBancaria
FOR EACH ROW
DECLARE
  v_exists NUMBER;
BEGIN
  -- Comprueba si la operación existe en la tabla local
  SELECT COUNT(*) INTO v_exists
    FROM OperacionBancaria
   WHERE codigo_numerico = :OLD.codigo_numerico
     AND iban = :OLD.iban;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20033, 'No se puede actualizar: la operación no existe en la base local');
  ELSE
    -- Actualiza la operación principal
    UPDATE OperacionBancaria
       SET 
           fecha       = :NEW.fecha,
           hora        = :NEW.hora,
           cantidad    = :NEW.cantidad
     WHERE codigo_numerico = :OLD.codigo_numerico
       AND iban = :OLD.iban;
  END IF;
END;
/


CREATE OR REPLACE TRIGGER VistaSucursal_Insert
INSTEAD OF INSERT ON VistaSucursal
FOR EACH ROW
BEGIN
  IF :NEW.codoficina IS NULL THEN
    RAISE_APPLICATION_ERROR(-20010, 'Código de oficina no puede ser nulo');
  ELSIF :NEW.dir IS NULL THEN
    RAISE_APPLICATION_ERROR(-20011, 'Dirección no puede ser nula');
  ELSIF :NEW.tfno IS NULL THEN
    RAISE_APPLICATION_ERROR(-20012, 'Teléfono no puede ser nulo');
  END IF;

  IF LENGTH(:NEW.tfno) != 9 THEN
    RAISE_APPLICATION_ERROR(-20013, 'El teléfono debe tener 9 dígitos');
  END IF;

  -- Inserta en la tabla local Sucursal
  INSERT INTO Sucursal (
    codigo_sucursal,
    direccion,
    telefono
  ) VALUES (
    :NEW.codoficina,
    :NEW.dir,
    :NEW.tfno
  );
END;
/


CREATE OR REPLACE TRIGGER VistaSucursal_Update
INSTEAD OF UPDATE ON VistaSucursal
FOR EACH ROW
DECLARE
  v_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_exists
    FROM Sucursal
   WHERE codigo_sucursal = :OLD.codoficina;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20034, 'No se puede actualizar: la oficina no existe en la base local');
  ELSE
    UPDATE Sucursal
       SET direccion = :NEW.dir,
           telefono  = :NEW.tfno
     WHERE codigo_sucursal = :OLD.codoficina;
  END IF;
END;
/


-- ======================================================
-- Ejemplos de inserciones y actualizaciones para probar los triggers
-- ======================================================

-- Insert en VistaCuenta
INSERT INTO VistaCuenta (
  iban,
  numero_cuenta,
  saldo,
  fecha_creacion
) VALUES (
  'ES123456789012345678901234567890',  -- IBAN válido (más de 5 caracteres)
  '00123456789',
  1000,
  TO_DATE('2025-04-01', 'YYYY-MM-DD')
);

-- Insert en VistaCuentaCliente (dni numérico)
INSERT INTO VistaCuentaCliente (
  dni,
  iban
) VALUES (
  12345678,
  'ES123456789012345678901234567890'
);

-- Insert en VistaOperacionBancaria
INSERT INTO VistaOperacionBancaria (
  codigo_numerico,
  iban,
  cantidad,
  fecha,
  hora
) VALUES (
  1001,
  'ES123456789012345678901234567890',
  250,
  TO_DATE('2025-04-05', 'YYYY-MM-DD'),
  TO_TIMESTAMP('2025-04-05 10:30:00', 'YYYY-MM-DD HH24:MI:SS')
);

-- Insert en VistaSucursal (codoficina numérico)
INSERT INTO VistaSucursal (
  codoficina,
  dir,
  tfno
) VALUES (
  100,           -- código numérico
  'Calle Falsa 123',
  '123456789'
);

-- 3. Insertar en VistaCorriente para activar el trigger que inserta en Corriente
-- y actualiza el tipo de cuenta a "CORRIENTE" en la tabla Cuenta
INSERT INTO VistaCuentaCorriente (iban, codigo_sucursal)
VALUES ('ES000000000000000000000000000001', 101);

-- 4. Insertar en VistaAhorro para activar el trigger que inserta en Ahorro
-- y actualiza el tipo de cuenta a "AHORRO" en la tabla Cuenta
INSERT INTO VistaCuentaAhorro (iban, interes)
VALUES ('ES000000000000000000000000000002', 2.50);