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

  -- 2) Según tipo de cuenta, inserta en Ahorro o Corriente
  IF UPPER(:NEW.tipo_cuenta) = 'AHORRO' THEN
    -- Se requiere un interés para la cuenta de ahorro
    IF :NEW.interes IS NULL THEN
      RAISE_APPLICATION_ERROR(-20035, 'Cuentas de ahorro deben tener interés');
    END IF;
    INSERT INTO Ahorro (iban, interes)
    VALUES (:NEW.iban, :NEW.interes);

  ELSIF UPPER(:NEW.tipo_cuenta) = 'CORRIENTE' THEN
    -- Se requiere un código de sucursal para la cuenta corriente
    IF :NEW.codigo_sucursal IS NULL THEN
      RAISE_APPLICATION_ERROR(-20036, 'Cuentas corrientes deben tener oficina asignada');
    END IF;
    INSERT INTO Corriente (iban, codigo_sucursal)
    VALUES (:NEW.iban, :NEW.codigo_sucursal);
  END IF;
END;
/

UPPER
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

    -- Si cambia el tipo de cuenta, hay que gestionar la tabla Ahorro/Corriente
    IF UPPER(:NEW.tipo_cuenta) = 'AHORRO' THEN
      -- Quita de Corriente, si existía
      DELETE FROM Corriente WHERE iban = v_old_iban;
      -- Inserta o actualiza Ahorro
      MERGE INTO Ahorro A
           USING (SELECT :NEW.iban as ib) tmp
           ON (A.iban = tmp.ib)
      WHEN MATCHED THEN
           UPDATE SET interes = :NEW.interes
      WHEN NOT MATCHED THEN
           INSERT (iban, interes) VALUES (:NEW.iban, :NEW.interes);

    ELSIF UPPER(:NEW.tipo_cuenta) = 'CORRIENTE' THEN
      -- Quita de Ahorro, si existía
      DELETE FROM Ahorro WHERE iban = v_old_iban;
      -- Inserta o actualiza Corriente
      MERGE INTO Corriente C
           USING (SELECT :NEW.iban as ib) tmp
           ON (C.iban = tmp.ib)
      WHEN MATCHED THEN
           UPDATE SET codigo_sucursal = :NEW.codigo_sucursal
      WHEN NOT MATCHED THEN
           INSERT (iban, codigo_sucursal) VALUES (:NEW.iban, :NEW.codigo_sucursal);
    END IF;

  END IF;
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

    -- Si cambia el tipo de cuenta, hay que gestionar la tabla Ahorro/Corriente
    IF UPPER(:NEW.tipo_cuenta) = 'AHORRO' THEN
      -- Quita de Corriente, si existía
      DELETE FROM Corriente WHERE iban = v_old_iban;
      -- Inserta o actualiza Ahorro
      MERGE INTO Ahorro A
           USING (SELECT :NEW.iban as ib) tmp
           ON (A.iban = tmp.ib)
      WHEN MATCHED THEN
           UPDATE SET interes = :NEW.interes
      WHEN NOT MATCHED THEN
           INSERT (iban, interes) VALUES (:NEW.iban, :NEW.interes);

    ELSIF UPPER(:NEW.tipo_cuenta) = 'CORRIENTE' THEN
      -- Quita de Ahorro, si existía
      DELETE FROM Ahorro WHERE iban = v_old_iban;
      -- Inserta o actualiza Corriente
      MERGE INTO Corriente C
           USING (SELECT :NEW.iban as ib) tmp
           ON (C.iban = tmp.ib)
      WHEN MATCHED THEN
           UPDATE SET codigo_sucursal = :NEW.codigo_sucursal
      WHEN NOT MATCHED THEN
           INSERT (iban, codigo_sucursal) VALUES (:NEW.iban, :NEW.codigo_sucursal);
    END IF;

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
DECLARE
  v_tipo VARCHAR2(20);
BEGIN
  v_tipo := UPPER(:NEW.tipo);

  -- 1) Insertar siempre en la tabla OperacionBancaria
  INSERT INTO OperacionBancaria (
    codigo_numerico,
    iban,
    cantidad,
    tipo,
    fecha,
    hora
  ) VALUES (
    :NEW.codigo_numerico,
    :NEW.iban,
    :NEW.cantidad,
    v_tipo,
    :NEW.fecha,
    :NEW.hora
  );

  -- 2) Según el tipo, insertar en la subentidad correspondiente
  IF v_tipo = 'RETIRADA' THEN
    -- Se requiere un campo extra para la sucursal (p.ej. :NEW.codigo_sucursal)
    INSERT INTO Retirada (
      codigo_numerico,
      codigo_sucursal,
      iban
    ) VALUES (
      :NEW.codigo_numerico,
      :NEW.codigo_sucursal,
      :NEW.iban
    );

  ELSIF v_tipo = 'INGRESO' THEN
    INSERT INTO Ingreso (
      codigo_numerico,
      codigo_sucursal,
      iban
    ) VALUES (
      :NEW.codigo_numerico,
      :NEW.codigo_sucursal,
      :NEW.iban
    );

  ELSIF v_tipo = 'TRANSFERENCIA' THEN
    -- Transferencia requiere iban_emisor e iban_receptor.
    INSERT INTO Transferencia (
      codigo_numerico,
      iban_emisor,
      iban_receptor
    ) VALUES (
      :NEW.codigo_numerico,
      :NEW.iban,         -- asumimos que :NEW.iban es el emisor
      :NEW.iban_receptor -- se requiere un campo adicional en la vista
    );
  END IF;
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
       SET descripcion = :NEW.descripcionOP,  -- si has añadido este campo en la vista
           fecha       = :NEW.fecha,
           hora        = :NEW.hora,
           cantidad    = :NEW.cantidad,
           tipo        = UPPER(:NEW.tipo)
     WHERE codigo_numerico = :OLD.codigo_numerico
       AND iban = :OLD.iban;

    -- Opcionalmente, podrías actualizar subentidades, aunque a menudo se gestionan por separado
    -- Por ejemplo, si se cambia la operación de RETIRADA a INGRESO (caso extraño), habría que
    -- eliminar de la tabla Retirada y crear en Ingreso. Depende de tu lógica de negocio.
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

  -- Validación adicional para formato de teléfono, si se desea:
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
