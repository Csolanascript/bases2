#!/usr/bin/env bash

docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<SQL

-- 1️⃣ Insertar datos en la tabla Clientes
INSERT INTO Clientes (nombre, apellidos, edad, telefono, email, direccion, dni)
VALUES ('Juan', 'Pérez', 30, '555-1234', 'juan.perez@email.com', 'Calle Falsa 123, Ciudad X', '123456789A');

INSERT INTO Clientes (nombre, apellidos, edad, telefono, email, direccion, dni)
VALUES ('Ana', 'Gómez', 28, '555-5678', 'ana.gomez@email.com', 'Avenida Siempre Viva 456, Ciudad Y', '987654321B');

INSERT INTO Clientes (nombre, apellidos, edad, telefono, email, direccion, dni)
VALUES ('Carlos', 'Martínez', 35, '555-9876', 'carlos.martinez@email.com', 'Calle Principal 789, Ciudad Z', '112233445C');

INSERT INTO Clientes (nombre, apellidos, edad, telefono, email, direccion, dni)
VALUES ('Laura', 'Hernández', 40, '555-1111', 'laura.hernandez@email.com', 'Plaza Mayor 12, Ciudad W', '223344556D');

INSERT INTO Clientes (nombre, apellidos, edad, telefono, email, direccion, dni)
VALUES ('Pedro', 'López', 25, '555-2222', 'pedro.lopez@email.com', 'Calle del Sol 45, Ciudad V', '334455667E');

-- 2️⃣ Insertar datos en la tabla Sucursales
INSERT INTO Sucursales (codigo_sucursal, direccion, telefono)
VALUES (101, 'Sucursal Central, Ciudad X', '555-1111');

INSERT INTO Sucursales (codigo_sucursal, direccion, telefono)
VALUES (102, 'Sucursal Norte, Ciudad Y', '555-2222');

INSERT INTO Sucursales (codigo_sucursal, direccion, telefono)
VALUES (103, 'Sucursal Este, Ciudad Z', '555-3333');

-- 3️⃣ Insertar datos en la tabla Cuentas
INSERT INTO Cuentas (numero_cuenta, iban, saldo, fecha_creacion)
VALUES ('1234567890', 'ES1234567890123456789012', 1000.00, TO_DATE('2022-01-15', 'YYYY-MM-DD'));

INSERT INTO Cuentas (numero_cuenta, iban, saldo, fecha_creacion)
VALUES ('0987654321', 'ES9876543210987654321098', 2500.00, TO_DATE('2022-02-20', 'YYYY-MM-DD'));

INSERT INTO Cuentas (numero_cuenta, iban, saldo, fecha_creacion)
VALUES ('5432167890', 'ES5432167890123456789012', 1500.00, TO_DATE('2022-03-01', 'YYYY-MM-DD'));

-- 4️⃣ Insertar datos en la tabla OperacionesBancarias
INSERT INTO OperacionesBancarias (codigo_numerico, fecha, cantidad, tipo_operacion, descripcion, iban)
VALUES (1, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 200.00, 'TRANSFERENCIA', 'Transferencia de dinero', 'ES1234567890123456789012');

INSERT INTO OperacionesBancarias (codigo_numerico, fecha, cantidad, tipo_operacion, descripcion, iban)
VALUES (2, TO_DATE('2023-03-02', 'YYYY-MM-DD'), 500.00, 'RETIRO', 'Retiro en cajero automático', 'ES9876543210987654321098');

INSERT INTO OperacionesBancarias (codigo_numerico, fecha, cantidad, tipo_operacion, descripcion, iban)
VALUES (3, TO_DATE('2023-03-03', 'YYYY-MM-DD'), 300.00, 'INGRESO', 'Ingreso en cuenta', 'ES5432167890123456789012');

-- 5️⃣ Insertar datos en la tabla Transferencias
INSERT INTO Transferencias (codigo_numerico, iban, iban_receptor)
VALUES (1, 'ES1234567890123456789012', 'ES9876543210987654321098');

INSERT INTO Transferencias (codigo_numerico, iban, iban_receptor)
VALUES (2, 'ES9876543210987654321098', 'ES1234567890123456789012');

-- 6️⃣ Insertar datos en la tabla Retiradas
INSERT INTO Retiradas (codigo_numerico, iban, codigo_sucursal)
VALUES (1, 'ES1234567890123456789012', 101);

INSERT INTO Retiradas (codigo_numerico, iban, codigo_sucursal)
VALUES (2, 'ES9876543210987654321098', 102);

-- 7️⃣ Insertar datos en la tabla Ingresos
INSERT INTO Ingresos (codigo_numerico, iban, codigo_sucursal)
VALUES (1, 'ES1234567890123456789012', 101);

INSERT INTO Ingresos (codigo_numerico, iban, codigo_sucursal)
VALUES (2, 'ES9876543210987654321098', 102);

-- 8️⃣ Insertar datos en la tabla CuentaAhorro
INSERT INTO CuentasAhorro (iban, interes)
VALUES ('ES1234567890123456789012', 1.5);

INSERT INTO CuentasAhorro (iban, interes)
VALUES ('ES9876543210987654321098', 2.0);

-- 9️⃣ Insertar datos en la tabla CuentaCorriente
INSERT INTO CuentasCorriente (iban, codigo_sucursal)
VALUES ('ES1234567890123456789012', 101);

INSERT INTO CuentasCorriente (iban, codigo_sucursal)
VALUES ('ES9876543210987654321098', 102);

-- 🔟 Insertar datos en la tabla CuentaCliente (relación entre Cliente y Cuenta)
INSERT INTO CuentaCliente (dni_cliente, iban)
VALUES ('123456789A', 'ES1234567890123456789012');

INSERT INTO CuentaCliente (dni_cliente, iban)
VALUES ('987654321B', 'ES9876543210987654321098');

INSERT INTO CuentaCliente (dni_cliente, iban)
VALUES ('112233445C', 'ES5432167890123456789012');

SQL
