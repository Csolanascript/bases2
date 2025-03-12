#!/usr/bin/env bash

docker exec -i p2_oracle_1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<EOF

-- Insertar datos en CLIENTE
INSERT INTO Cliente (id_cliente, nombre, apellidos, edad, telefono)
VALUES (1, 'Juan', 'Pérez', 35, '555-1234');
INSERT INTO Cliente (id_cliente, nombre, apellidos, edad, telefono)
VALUES (2, 'María', 'González', 42, '555-5678');
INSERT INTO Cliente (id_cliente, nombre, apellidos, edad, telefono)
VALUES (3, 'Pedro', 'López', 29, '555-8765');
INSERT INTO Cliente (id_cliente, nombre, apellidos, edad, telefono)
VALUES (4, 'Ana', 'Martínez', 50, '555-4321');
INSERT INTO Cliente (id_cliente, nombre, apellidos, edad, telefono)
VALUES (5, 'Luis', 'Ramírez', 33, '555-9876');

-- Insertar datos en CUENTA
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion, tipo_cuenta)
VALUES ('ES0001', '0001', 1000.00, DATE '2023-01-10', 'AHORRO');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion, tipo_cuenta)
VALUES ('ES0002', '0002', 2500.00, DATE '2023-02-15', 'CORRIENTE');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion, tipo_cuenta)
VALUES ('ES0003', '0003', 15000.50, DATE '2022-12-01', 'AHORRO');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion, tipo_cuenta)
VALUES ('ES0004', '0004', 200.00, DATE '2023-03-05', 'CORRIENTE');
INSERT INTO Cuenta (iban, numero_cuenta, saldo, fecha_creacion, tipo_cuenta)
VALUES ('ES0005', '0005', 3200.75, DATE '2023-03-10', 'AHORRO');

-- Insertar datos en CUENTACLIENTE (relación entre Cliente y Cuenta)
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (1, 'ES0001');
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (1, 'ES0002');  -- El cliente 1 tiene dos cuentas
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (2, 'ES0002');  -- La cuenta ES0002 está a nombre de dos clientes
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (3, 'ES0003');
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (4, 'ES0004');
INSERT INTO CuentaCliente (id_cliente, iban)
VALUES (5, 'ES0005');

-- Insertar datos en SUCURSAL
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (101, 'Calle Principal 123', '555-1000');
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (102, 'Avenida Central 456', '555-2000');
INSERT INTO Sucursal (codigo_sucursal, direccion, telefono)
VALUES (103, 'Plaza Mayor 789', '555-3000');

-- Insertar datos en OPERACIONBANCARIA (superentidad)
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1001, 'ES0001', 101, 500.00, DATE '2023-03-15');
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1002, 'ES0002', 102, 1000.00, DATE '2023-03-16');
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1003, 'ES0003', 101, 250.00, DATE '2023-03-17');
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1004, 'ES0002', 103, 100.00, DATE '2023-03-18');
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1005, 'ES0004', 101, 75.50, DATE '2023-03-19');
INSERT INTO OperacionBancaria (id_operacion, iban, codigo_sucursal, monto, fecha)
VALUES (1006, 'ES0005', 102, 600.00, DATE '2023-03-20');

-- Insertar datos en RETIRADA (subentidad)
-- Supongamos que las operaciones 1001, 1003 y 1005 son retiradas
INSERT INTO Retirada (id_operacion)
VALUES (1001);
INSERT INTO Retirada (id_operacion)
VALUES (1003);
INSERT INTO Retirada (id_operacion)
VALUES (1005);

-- Insertar datos en INGRESO (subentidad)
-- Supongamos que las operaciones 1002, 1004 y 1006 son ingresos
INSERT INTO Ingreso (id_operacion)
VALUES (1002);
INSERT INTO Ingreso (id_operacion)
VALUES (1004);
INSERT INTO Ingreso (id_operacion)
VALUES (1006);

-- Insertar datos en TRANSFERENCIA
INSERT INTO Transferencia (id_transferencia, iban_emisor, iban_receptor, monto, fecha)
VALUES (2001, 'ES0001', 'ES0003', 300.00, DATE '2023-03-20');
INSERT INTO Transferencia (id_transferencia, iban_emisor, iban_receptor, monto, fecha)
VALUES (2002, 'ES0002', 'ES0005', 400.00, DATE '2023-03-21');
INSERT INTO Transferencia (id_transferencia, iban_emisor, iban_receptor, monto, fecha)
VALUES (2003, 'ES0003', 'ES0004', 150.00, DATE '2023-03-22');
INSERT INTO Transferencia (id_transferencia, iban_emisor, iban_receptor, monto, fecha)
VALUES (2004, 'ES0005', 'ES0001', 250.00, DATE '2023-03-23');

COMMIT;
EXIT;
EOF
