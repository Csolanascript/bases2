BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Retirada CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Ingreso CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Transferencia CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE OperacionBancaria CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Sucursal CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Corriente CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Ahorro CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE CuentaCliente CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Cuenta CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Cliente CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Creaci�n de tablas en el orden adecuado

-- Tabla CLIENTE
CREATE TABLE Cliente (
    dni         NUMBER(10)       NOT NULL,
    nombre      VARCHAR2(50)     NOT NULL,
    apellidos   VARCHAR2(50)     NOT NULL,
    edad        NUMBER(3)        NOT NULL,
    telefono    VARCHAR2(20)     NOT NULL,
    email       VARCHAR2(50),     -- Opcional
    direccion   VARCHAR2(100)    NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (dni)
);

-- Tabla CUENTA
CREATE TABLE Cuenta (
    iban            VARCHAR2(34)      NOT NULL, 
    numero_cuenta   VARCHAR2(20)      NOT NULL,
    saldo           NUMBER(15,2)      NOT NULL,
    fecha_creacion  DATE,
    CONSTRAINT pk_cuenta PRIMARY KEY (iban)
);

-- Tabla intermedia CUENTACLIENTE (relaciona Cliente y Cuenta)
CREATE TABLE CuentaCliente (
    dni  NUMBER(10)       NOT NULL,
    iban VARCHAR2(34)     NOT NULL,
    CONSTRAINT pk_cuentacliente PRIMARY KEY (dni, iban),
    CONSTRAINT fk_cuentacliente_cliente 
        FOREIGN KEY (dni) 
        REFERENCES Cliente (dni),
    CONSTRAINT fk_cuentacliente_cuenta 
        FOREIGN KEY (iban) 
        REFERENCES Cuenta (iban)
);

-- Tabla AHORRO (para cuentas de ahorro)
CREATE TABLE Ahorro (
    iban    VARCHAR2(34)  NOT NULL,
    interes NUMBER(5,2)   NOT NULL,
    CONSTRAINT pk_ahorro PRIMARY KEY (iban),
    CONSTRAINT fk_ahorro_cuenta 
        FOREIGN KEY (iban) 
        REFERENCES Cuenta (iban)
);

-- Tabla CORRIENTE (para cuentas corrientes)
CREATE TABLE Corriente (
    iban            VARCHAR2(34)  NOT NULL,
    codigo_sucursal NUMBER(10)    NOT NULL,
    CONSTRAINT pk_corriente PRIMARY KEY (iban, codigo_sucursal),
    CONSTRAINT fk_corriente_cuenta 
        FOREIGN KEY (iban) 
        REFERENCES Cuenta (iban)
);

-- Tabla SUCURSAL
CREATE TABLE Sucursal (
    codigo_sucursal NUMBER(10)     NOT NULL,
    direccion       VARCHAR2(100)  NOT NULL,
    telefono        VARCHAR2(20)   NOT NULL,
    CONSTRAINT pk_sucursal PRIMARY KEY (codigo_sucursal)
);

-- Tabla OPERACIONBANCARIA (superentidad)
CREATE TABLE OperacionBancaria (
    codigo_numerico NUMBER(10)    NOT NULL,
    iban            VARCHAR2(34)  NOT NULL,  -- Cuenta sobre la que se hace la operaci�n
    cantidad        NUMBER(15,2),
    tipo            VARCHAR2(20),
    fecha           DATE,
    hora            TIMESTAMP,
    CONSTRAINT pk_operacionbancaria PRIMARY KEY (codigo_numerico, iban),
    CONSTRAINT fk_operacionbancaria_cuenta
        FOREIGN KEY (iban)
        REFERENCES Cuenta (iban),    
    CONSTRAINT tipo_operacion CHECK (tipo IN ('Retirada', 'Ingreso', 'Transferencia'))
);

-- Subentidad RETIRADA
CREATE TABLE Retirada (
    codigo_numerico NUMBER(10)    NOT NULL,
    codigo_sucursal NUMBER(10)    NOT NULL,
    iban            VARCHAR2(34)  NOT NULL,
    CONSTRAINT pk_retirada PRIMARY KEY (codigo_numerico, codigo_sucursal, iban),
    CONSTRAINT fk_retirada_operacion
        FOREIGN KEY (codigo_numerico,iban)
        REFERENCES OperacionBancaria (codigo_numerico,iban),
    CONSTRAINT fk_operacionbancaria_sucursal
        FOREIGN KEY (codigo_sucursal)
        REFERENCES Sucursal (codigo_sucursal)
);

-- Subentidad INGRESO
CREATE TABLE Ingreso (
    codigo_numerico NUMBER(10)    NOT NULL,
    codigo_sucursal NUMBER(10)    NOT NULL,
    iban            VARCHAR2(34)  NOT NULL,
    CONSTRAINT pk_ingreso PRIMARY KEY (codigo_numerico, codigo_sucursal, iban),
    CONSTRAINT fk_ingreso_operacion
        FOREIGN KEY (codigo_numerico, iban)
        REFERENCES OperacionBancaria (codigo_numerico, iban),
    CONSTRAINT fk_operacionbancaria_sucursal_ingreso
        FOREIGN KEY (codigo_sucursal)
        REFERENCES Sucursal (codigo_sucursal)
);

-- Tabla TRANSFERENCIA
CREATE TABLE Transferencia (
    codigo_numerico NUMBER(10)    NOT NULL,
    iban_emisor     VARCHAR2(34)  NOT NULL,
    iban_receptor   VARCHAR2(34)  NOT NULL,
    CONSTRAINT pk_transferencia PRIMARY KEY (codigo_numerico, iban_emisor, iban_receptor),
    CONSTRAINT fk_transferencia_emisor
        FOREIGN KEY (codigo_numerico, iban_emisor)
        REFERENCES OperacionBancaria (codigo_numerico, iban),
    CONSTRAINT fk_transferencia_receptor
        FOREIGN KEY (iban_receptor)
        REFERENCES Cuenta (iban)
);


-- Inserciones para CLIENTE. Se usa la columna dni en lugar de id_cliente.
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (1, 'Juan', 'P�rez', 35, '555-1234', 'Calle Falsa 123');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (2, 'Mar�a', 'Gonz�lez', 42, '555-5678', 'Avenida Siempre Viva 456');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (3, 'Pedro', 'L�pez', 29, '555-8765', 'Calle Luna 789');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (4, 'Ana', 'Mart�nez', 50, '555-4321', 'Plaza Sol 101');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (5, 'Luis', 'Ram�rez', 33, '555-9876', 'Calle R�o 202');

-- Inserciones para CUENTA. Se elimin� el campo tipo_cuenta.
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion)
VALUES ('ES0001', '0001', 1000.00, DATE '2023-01-10');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion)
VALUES ('ES0002', '0002', 2500.00, DATE '2023-02-15');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion)
VALUES ('ES0003', '0003', 15000.50, DATE '2022-12-01');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion)
VALUES ('ES0004', '0004', 200.00, DATE '2023-03-05');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion)
VALUES ('ES0005', '0005', 3200.75, DATE '2023-03-10');

-- Seg�n el tipo de cuenta, se insertan datos en Ahorro o Corriente.
-- Las cuentas ES0001, ES0003 y ES0005 son de Ahorro con inter�s del 1.50%
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0001', 1.50);
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0003', 1.50);
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0005', 1.50);

-- Las cuentas ES0002 y ES0004 son Corriente, se asignan c�digos de sucursal.
INSERT INTO Corriente (iban, codigo_sucursal)
VALUES ('ES0002', 102);
INSERT INTO Corriente (iban, codigo_sucursal)
VALUES ('ES0004', 103);

-- Inserciones para la relaci�n CUENTACLIENTE
-- Se insertan en l�neas separadas sin comentarios al final.
INSERT INTO CuentaCliente (dni, iban)
VALUES (1, 'ES0001');
INSERT INTO CuentaCliente (dni, iban)
VALUES (1, 'ES0002');
INSERT INTO CuentaCliente (dni, iban)
VALUES (2, 'ES0002');
INSERT INTO CuentaCliente (dni, iban)
VALUES (3, 'ES0003');
INSERT INTO CuentaCliente (dni, iban)
VALUES (4, 'ES0004');
INSERT INTO CuentaCliente (dni, iban)
VALUES (5, 'ES0005');

-- Inserciones para SUCURSAL
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (101, 'Calle Principal 123', '555-1000');
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (102, 'Avenida Central 456', '555-2000');
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (103, 'Plaza Mayor 789', '555-3000');

-- Inserciones para OPERACIONBANCARIA (operaciones de Retirada e Ingreso)
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1001, 'ES0001', 500.00, 'Retirada', DATE '2023-03-15', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1002, 'ES0002', 1000.00, 'Ingreso', DATE '2023-03-16', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1003, 'ES0003', 250.00, 'Retirada', DATE '2023-03-17', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1004, 'ES0002', 100.00, 'Ingreso', DATE '2023-03-18', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1005, 'ES0004', 75.50, 'Retirada', DATE '2023-03-19', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (1006, 'ES0005', 600.00, 'Ingreso', DATE '2023-03-20', SYSTIMESTAMP);

-- Inserciones para las operaciones de TRANSFERENCIA.
-- Primero se crean los registros parentales en OperacionBancaria para las transferencias.
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (2001, 'ES0001', 300.00, 'Transferencia', DATE '2023-03-20', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (2002, 'ES0002', 400.00, 'Transferencia', DATE '2023-03-21', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (2003, 'ES0003', 150.00, 'Transferencia', DATE '2023-03-22', SYSTIMESTAMP);
INSERT INTO OperacionBancaria (codigo_numerico, iban, cantidad, tipo, fecha, hora)
VALUES (2004, 'ES0005', 250.00, 'Transferencia', DATE '2023-03-23', SYSTIMESTAMP);

-- Inserciones para las subentidades.
-- Para RETIRADA: se insertan las operaciones de retirada.
INSERT INTO Retirada (codigo_numerico, codigo_sucursal, iban)
VALUES (1001, 101, 'ES0001');
INSERT INTO Retirada (codigo_numerico, codigo_sucursal, iban)
VALUES (1003, 101, 'ES0003');
INSERT INTO Retirada (codigo_numerico, codigo_sucursal, iban)
VALUES (1005, 101, 'ES0004');

-- Para INGRESO: se insertan las operaciones de ingreso.
INSERT INTO Ingreso (codigo_numerico, codigo_sucursal, iban)
VALUES (1002, 102, 'ES0002');
INSERT INTO Ingreso (codigo_numerico, codigo_sucursal, iban)
VALUES (1004, 103, 'ES0002');
INSERT INTO Ingreso (codigo_numerico, codigo_sucursal, iban)
VALUES (1006, 102, 'ES0005');

-- Inserciones para TRANSFERENCIA.
-- Ahora se pueden insertar, ya que existen los registros parentales.
INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
VALUES (2001, 'ES0001', 'ES0003');
INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
VALUES (2002, 'ES0002', 'ES0005');
INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
VALUES (2003, 'ES0003', 'ES0004');
INSERT INTO Transferencia (codigo_numerico, iban_emisor, iban_receptor)
VALUES (2004, 'ES0005', 'ES0001');

COMMIT;
EXIT;