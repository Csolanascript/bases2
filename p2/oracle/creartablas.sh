#!/usr/bin/env bash

docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<-SQL

-- 1️⃣ Crear Tipos de Objetos

-- Crear el tipo de objeto Cliente
CREATE OR REPLACE TYPE ClienteUDT AS OBJECT (
    id_cliente      NUMBER(10),
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
    fecha_creacion  DATE,
    tipo_cuenta     VARCHAR2(10)
) NOT FINAL;
/

-- Crear el tipo de objeto OperacionBancaria (superentidad, NOT FINAL)
CREATE OR REPLACE TYPE OperacionBancariaUDT AS OBJECT (
    id_operacion    NUMBER(10),
    fecha           DATE,
    monto           NUMBER(15,2),
    tipo_operacion  VARCHAR2(20),  -- Para diferenciar el tipo de operación (Transferencia, Retirada, Ingreso)
    descripcion     CLOB,
    iban            VARCHAR2(34),  -- Cuenta sobre la que se hace la operación
    codigo_sucursal NUMBER(10)     -- Sucursal donde se realiza la operación
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
    iban_emisor     VARCHAR2(34),  -- Cuenta emisora
    iban_receptor   VARCHAR2(34)   -- Cuenta receptora
);
/

-- Crear el tipo de objeto Retirada (subentidad de OperacionBancaria)
CREATE OR REPLACE TYPE RetiradaUDT UNDER OperacionBancariaUDT (
    metodo_retiro   VARCHAR2(20)  -- Atributo adicional específico para Retirada
);
/

-- Crear el tipo de objeto Ingreso (subentidad de OperacionBancaria)
CREATE OR REPLACE TYPE IngresoUDT UNDER OperacionBancariaUDT (
    metodo_pago     VARCHAR2(20)  -- Atributo adicional específico para Ingreso
);
/

-- Crear el tipo de objeto CuentaAhorro (subentidad de Cuenta)
CREATE OR REPLACE TYPE CuentaAhorroUDT UNDER CuentaUDT (
    interes         NUMBER(10,2)  -- Atributo específico para CuentaAhorro
);
/

-- Crear el tipo de objeto CuentaCorriente (subentidad de Cuenta)
CREATE OR REPLACE TYPE CuentaCorrienteUDT UNDER CuentaUDT (
    limite_credito  NUMBER(15,2)  -- Atributo específico para CuentaCorriente
);
/

-- 2️⃣ Crear las Tablas Basadas en los Tipos de Objetos

-- Tabla para Clientes
CREATE TABLE Clientes OF ClienteUDT (
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
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
    CONSTRAINT pk_operacionbancaria PRIMARY KEY (id_operacion),
    CONSTRAINT fk_operacionbancaria_cuenta
        FOREIGN KEY (iban) REFERENCES Cuentas (iban),
    CONSTRAINT fk_operacionbancaria_sucursal
        FOREIGN KEY (codigo_sucursal) REFERENCES Sucursales (codigo_sucursal)
);
/

-- Tabla para Transferencias (subentidad de OperacionBancaria)
CREATE TABLE Transferencias OF TransferenciaUDT (
    CONSTRAINT pk_transferencia PRIMARY KEY (id_operacion),
    CONSTRAINT fk_transferencia_emisor FOREIGN KEY (iban_emisor) REFERENCES Cuentas (iban),
    CONSTRAINT fk_transferencia_receptor FOREIGN KEY (iban_receptor) REFERENCES Cuentas (iban),
    CONSTRAINT fk_transferencia_operacion FOREIGN KEY (id_operacion) REFERENCES OperacionesBancarias (id_operacion)
);
/

-- Tabla para Retiradas (subentidad de OperacionBancaria)
CREATE TABLE Retiradas OF RetiradaUDT (
    CONSTRAINT pk_retirada PRIMARY KEY (id_operacion),
    CONSTRAINT fk_retirada_operacion FOREIGN KEY (id_operacion) REFERENCES OperacionesBancarias (id_operacion)
);
/

-- Tabla para Ingresos (subentidad de OperacionBancaria)
CREATE TABLE Ingresos OF IngresoUDT (
    CONSTRAINT pk_ingreso PRIMARY KEY (id_operacion),
    CONSTRAINT fk_ingreso_operacion FOREIGN KEY (id_operacion) REFERENCES OperacionesBancarias (id_operacion)
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
    CONSTRAINT fk_cuenta_corriente FOREIGN KEY (iban) REFERENCES Cuentas (iban)
);
/

-- 4️⃣ Verificación de la Creación de Tipos y Tablas

-- Verifica los tipos creados
SELECT type_name FROM user_types;
/

SQL
