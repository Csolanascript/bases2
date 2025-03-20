#!/usr/bin/env bash

docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<SQL

-- 1️⃣ Crear Tipos de Objetos

-- Crear el tipo de objeto Cliente
CREATE OR REPLACE TYPE ClienteUDT AS OBJECT (
    nombre          VARCHAR2(50),
    apellidos       VARCHAR2(50),
    edad            NUMBER(3),
    telefono        VARCHAR2(20),
    email           VARCHAR2(100),
    direccion       VARCHAR2(100),
    dni             VARCHAR2(20)
);
/

-- Crear el tipo de objeto Cuenta (superentidad, NOT FINAL para permitir subtipos)
CREATE OR REPLACE TYPE CuentaUDT AS OBJECT (
    numero_cuenta   VARCHAR2(20),
    iban            VARCHAR2(34),
    saldo           NUMBER(15,2),
    fecha_creacion  DATE
) NOT FINAL;
/

-- Crear el tipo de objeto OperacionBancaria (superentidad, NOT FINAL)
CREATE OR REPLACE TYPE OperacionBancariaUDT AS OBJECT (
    codigo_numerico    NUMBER(10),
    fecha           DATE,
    cantidad           NUMBER(15,2),
    tipo_operacion  VARCHAR2(20),  -- Para diferenciar el tipo de operación (Transferencia, Retirada, Ingreso)
    descripcion     CLOB,
    iban            VARCHAR2(34)  -- Cuenta sobre la que se hace la operación
) NOT FINAL;
/

-- Crear el tipo de objeto Sucursal
CREATE OR REPLACE TYPE SucursalUDT AS OBJECT (
    codigo_sucursal NUMBER(10),
    direccion       VARCHAR2(100),
    telefono        VARCHAR2(20)
);
/

-- Crear el tipo de objeto Transferencia (subentidad de OperacionBancaria)
CREATE OR REPLACE TYPE TransferenciaUDT UNDER OperacionBancariaUDT (
    iban_receptor   VARCHAR2(34)   -- Cuenta receptora
);
/

-- Crear el tipo de objeto Retirada (subentidad de OperacionBancaria)
CREATE OR REPLACE TYPE RetiradaUDT UNDER OperacionBancariaUDT (
    codigo_sucursal NUMBER(10)
);
/

-- Crear el tipo de objeto Ingreso (subentidad de OperacionBancaria)
CREATE OR REPLACE TYPE IngresoUDT UNDER OperacionBancariaUDT (
    codigo_sucursal NUMBER(10)
);   
/

-- Crear el tipo de objeto CuentaAhorro (subentidad de Cuenta)
CREATE OR REPLACE TYPE CuentaAhorroUDT UNDER CuentaUDT (
    interes         NUMBER(10,2)  -- Atributo específico para CuentaAhorro
);
/

-- Crear el tipo de objeto CuentaCorriente (subentidad de Cuenta)
CREATE OR REPLACE TYPE CuentaCorrienteUDT UNDER CuentaUDT (
    codigo_sucursal NUMBER(10)
);
/

-- 2️⃣ Crear las Tablas Basadas en los Tipos de Objetos

-- Tabla para Clientes
CREATE TABLE Clientes OF ClienteUDT (
    CONSTRAINT pk_cliente PRIMARY KEY (dni)
);
/

-- Tabla para Sucursales (debe crearse antes de Operaciones Bancarias)
CREATE TABLE Sucursales OF SucursalUDT (
    CONSTRAINT pk_sucursal PRIMARY KEY (codigo_sucursal)
);
/

-- Tabla para Cuentas
CREATE TABLE Cuentas OF CuentaUDT (
    CONSTRAINT pk_cuenta PRIMARY KEY (iban)
);
/

-- Tabla para Operaciones Bancarias (superentidad)
CREATE TABLE OperacionesBancarias OF OperacionBancariaUDT (
    CONSTRAINT pk_operacionbancaria PRIMARY KEY (codigo_numerico,iban),
    CONSTRAINT fk_operacionbancaria_cuenta
        FOREIGN KEY (iban) REFERENCES Cuentas (iban)    
);
/

-- Tabla para Transferencias (subentidad de OperacionBancaria)
CREATE TABLE Transferencias OF TransferenciaUDT (
    CONSTRAINT pk_transferencia PRIMARY KEY (codigo_numerico, iban, iban_receptor),  -- Clave primaria compuesta
    CONSTRAINT fk_transferencia_operacion FOREIGN KEY (codigo_numerico, iban) 
        REFERENCES OperacionesBancarias (codigo_numerico, iban),  -- Relación correcta
    CONSTRAINT fk_transferencia_receptor FOREIGN KEY (iban_receptor) REFERENCES Cuentas (iban)
);
/


-- Tabla para Retiradas (subentidad de OperacionBancaria)
CREATE TABLE Retiradas OF RetiradaUDT (
    CONSTRAINT pk_retirada PRIMARY KEY (codigo_numerico,iban,codigo_sucursal),
    CONSTRAINT fk_retirada_operacion FOREIGN KEY (codigo_numerico,iban) REFERENCES OperacionesBancarias (codigo_numerico,iban),
    CONSTRAINT fk_retirada_sucursal FOREIGN KEY (codigo_sucursal) REFERENCES Sucursales (codigo_sucursal)
);
/

-- Tabla para Ingresos (subentidad de OperacionBancaria)
CREATE TABLE Ingresos OF IngresoUDT (
    CONSTRAINT pk_ingreso PRIMARY KEY (codigo_numerico,iban,codigo_sucursal),
    CONSTRAINT fk_ingreso_operacion FOREIGN KEY (codigo_numerico,iban) REFERENCES OperacionesBancarias (codigo_numerico,iban),
    CONSTRAINT fk_ingreso_sucursal FOREIGN KEY (codigo_sucursal) REFERENCES Sucursales (codigo_sucursal)
);
/

-- Tabla para CuentaAhorro (subentidad de Cuenta)
CREATE TABLE CuentasAhorro OF CuentaAhorroUDT (
    CONSTRAINT pk_cuenta_ahorro PRIMARY KEY (iban),
    CONSTRAINT fk_cuenta_ahorro FOREIGN KEY (iban) REFERENCES Cuentas (iban)
);
/

-- Tabla para CuentaCorriente (subentidad de Cuenta)
CREATE TABLE CuentasCorriente OF CuentaCorrienteUDT (
    CONSTRAINT pk_cuenta_corriente PRIMARY KEY (iban),
    CONSTRAINT fk_cuenta_corriente FOREIGN KEY (iban) REFERENCES Cuentas (iban),
    CONSTRAINT fk_cuenta_corriente_sucursal FOREIGN KEY (codigo_sucursal) REFERENCES Sucursales (codigo_sucursal)
);
/

-- Tabla intermedia entre Cliente y Cuenta (relación N:M)
CREATE TABLE CuentaCliente (
    dni_cliente   VARCHAR2(20),  -- Referencia al DNI de Cliente
    iban          VARCHAR2(34),  -- Referencia al IBAN de Cuenta
    CONSTRAINT pk_cuentacliente PRIMARY KEY (dni_cliente, iban),
    CONSTRAINT fk_cuentacliente_cliente FOREIGN KEY (dni_cliente) REFERENCES Clientes (dni),
    CONSTRAINT fk_cuentacliente_cuenta FOREIGN KEY (iban) REFERENCES Cuentas (iban)
);
/


-- 4️⃣ Verificación de la Creación de Tipos y Tablas

-- Verifica los tipos creados
SELECT type_name FROM user_types;
/

SQL
