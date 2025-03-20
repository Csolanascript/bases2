#!/usr/bin/env bash

# Script para dropear y crear las tablas en Oracle XE dentro de un contenedor Docker.
# Asegúrate de que tu contenedor se llame "p2-oracle-1" (según tu docker-compose.yml),
# y que las credenciales y el servicio (XEPDB1) sean correctos.

docker exec -i p2-oracle-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<'EOF'
-- Bloques para dropear tablas si existen. Se usa SQLCODE -942 (tabla no existe).

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

-- Creación de tablas en el orden adecuado

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
    iban            VARCHAR2(34)  NOT NULL,  -- Cuenta sobre la que se hace la operación
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

EXIT;
EOF
