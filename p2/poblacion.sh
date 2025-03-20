#!/usr/bin/env bash

docker exec -i p2-oracle-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<'EOF'
-- Inserciones para CLIENTE. Se usa la columna dni en lugar de id_cliente.
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (1, 'Juan', 'Pérez', 35, '555-1234', 'Calle Falsa 123');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (2, 'María', 'González', 42, '555-5678', 'Avenida Siempre Viva 456');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (3, 'Pedro', 'López', 29, '555-8765', 'Calle Luna 789');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (4, 'Ana', 'Martínez', 50, '555-4321', 'Plaza Sol 101');
INSERT INTO Cliente (dni, nombre, apellidos, edad, telefono, direccion)
VALUES (5, 'Luis', 'Ramírez', 33, '555-9876', 'Calle Río 202');

-- Inserciones para CUENTA. Se eliminó el campo tipo_cuenta.
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

-- Según el tipo de cuenta, se insertan datos en Ahorro o Corriente.
-- Las cuentas ES0001, ES0003 y ES0005 son de Ahorro con interés del 1.50%
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0001', 1.50);
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0003', 1.50);
INSERT INTO Ahorro (iban, interes)
VALUES ('ES0005', 1.50);

-- Las cuentas ES0002 y ES0004 son Corriente, se asignan códigos de sucursal.
INSERT INTO Corriente (iban, codigo_sucursal)
VALUES ('ES0002', 102);
INSERT INTO Corriente (iban, codigo_sucursal)
VALUES ('ES0004', 103);

-- Inserciones para la relación CUENTACLIENTE
-- Se insertan en líneas separadas sin comentarios al final.
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
EOF
