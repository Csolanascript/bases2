#!/usr/bin/env bash

# Ejemplo de script para crear las tablas en Oracle XE dentro de un contenedor Docker.
# Asegúrate de que tu contenedor se llame "oracle" (según tu docker-compose.yml).
# Revisa que el usuario y contraseña sean correctos, así como el nombre del servicio (XEPDB1).

docker exec -i p2_oracle_1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<EOF

-- Opcionalmente, puedes desactivar temporalmente la verificación de FK para poder recrear tablas sin conflictos:
-- ALTER SESSION SET "_ORACLE_SCRIPT"=true;  -- Suele ser necesario en algunos contenedores que usan schemas diferenciados
-- SET FOREIGN_KEY_CHECKS = 0;  -- No aplica en Oracle, es solo ilustrativo (existe en MySQL).

-- Tabla CLIENTE
CREATE TABLE Cliente (
    id_cliente      NUMBER(10)        NOT NULL,
    nombre          VARCHAR2(50)      NOT NULL,
    apellidos       VARCHAR2(50)      NOT NULL,
    edad            NUMBER(3),
    telefono        VARCHAR2(20),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

-- Tabla CUENTA
CREATE TABLE Cuenta (
    iban            VARCHAR2(34)      NOT NULL, 
    numero_cuenta   VARCHAR2(20)      NOT NULL,
    saldo           NUMBER(15,2),
    fecha_creacion  DATE,
    tipo_cuenta     VARCHAR2(10)
        CHECK (tipo_cuenta IN ('AHORRO','CORRIENTE')),
    CONSTRAINT pk_cuenta PRIMARY KEY (iban)
);

-- Tabla intermedia CUENTACLIENTE
CREATE TABLE CuentaCliente (
    id_cliente  NUMBER(10)    NOT NULL,
    iban        VARCHAR2(34)  NOT NULL,
    CONSTRAINT pk_cuentacliente PRIMARY KEY (id_cliente, iban),
    CONSTRAINT fk_cuentacliente_cliente 
        FOREIGN KEY (id_cliente) 
        REFERENCES Cliente (id_cliente),
    CONSTRAINT fk_cuentacliente_cuenta 
        FOREIGN KEY (iban) 
        REFERENCES Cuenta (iban)
);

-- Tabla SUCURSAL
CREATE TABLE Sucursal (
    codigo_sucursal NUMBER(10)     NOT NULL,
    direccion       VARCHAR2(100),
    telefono        VARCHAR2(20),
    CONSTRAINT pk_sucursal PRIMARY KEY (codigo_sucursal)
);

-- Tabla OPERACIONBANCARIA (superentidad)
CREATE TABLE OperacionBancaria (
    id_operacion    NUMBER(10)     NOT NULL,
    iban            VARCHAR2(34)   NOT NULL,  -- cuenta sobre la que se hace la operación
    codigo_sucursal NUMBER(10)     NOT NULL,  -- sucursal donde se realiza
    monto           NUMBER(15,2),
    fecha           DATE,
    CONSTRAINT pk_operacionbancaria PRIMARY KEY (id_operacion),
    CONSTRAINT fk_operacionbancaria_cuenta
        FOREIGN KEY (iban)
        REFERENCES Cuenta (iban),
    CONSTRAINT fk_operacionbancaria_sucursal
        FOREIGN KEY (codigo_sucursal)
        REFERENCES Sucursal (codigo_sucursal)
);

-- Subentidad RETIRADA
CREATE TABLE Retirada (
    id_operacion NUMBER(10) NOT NULL,
    CONSTRAINT pk_retirada PRIMARY KEY (id_operacion),
    CONSTRAINT fk_retirada_operacion
        FOREIGN KEY (id_operacion)
        REFERENCES OperacionBancaria (id_operacion)
);

-- Subentidad INGRESO
CREATE TABLE Ingreso (
    id_operacion NUMBER(10) NOT NULL,
    CONSTRAINT pk_ingreso PRIMARY KEY (id_operacion),
    CONSTRAINT fk_ingreso_operacion
        FOREIGN KEY (id_operacion)
        REFERENCES OperacionBancaria (id_operacion)
);

-- Tabla TRANSFERENCIA
CREATE TABLE Transferencia (
    id_transferencia    NUMBER(10)     NOT NULL,
    iban_emisor         VARCHAR2(34)   NOT NULL,
    iban_receptor       VARCHAR2(34)   NOT NULL,
    monto               NUMBER(15,2),
    fecha               DATE,
    CONSTRAINT pk_transferencia PRIMARY KEY (id_transferencia),
    CONSTRAINT fk_transferencia_emisor
        FOREIGN KEY (iban_emisor)
        REFERENCES Cuenta (iban),
    CONSTRAINT fk_transferencia_receptor
        FOREIGN KEY (iban_receptor)
        REFERENCES Cuenta (iban)
);

EXIT;
EOF
