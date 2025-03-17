#!/usr/bin/env bash

docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<-SQL

-- 1️⃣ Insertar Datos en Sucursales
INSERT INTO Sucursales (codigo_sucursal, direccion, telefono) VALUES (1, 'Calle Mayor 123', '912345678');
INSERT INTO Sucursales (codigo_sucursal, direccion, telefono) VALUES (2, 'Avenida Central 456', '917654321');

-- 2️⃣ Insertar Datos en Clientes
INSERT INTO Clientes (id_cliente, nombre, apellidos, edad, telefono, email, direccion, dni) 
VALUES (1, 'Juan', 'Pérez', 30, '612345678', 'juan.perez@email.com', 'Calle Falsa 456', '12345678X');
INSERT INTO Clientes (id_cliente, nombre, apellidos, edad, telefono, email, direccion, dni) 
VALUES (2, 'Ana', 'Gómez', 25, '623456789', 'ana.gomez@email.com', 'Calle Real 789', '23456789Y');

-- 3️⃣ Insertar Datos en Cuentas
-- Los IBANs deben tener un máximo de 34 caracteres y el número de cuenta un máximo de 20
INSERT INTO Cuentas (numero_cuenta, iban, saldo, fecha_creacion, tipo_cuenta) 
VALUES ('0001', 'ES7620770024003102576762', 1000.00, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'AHORRO');
INSERT INTO Cuentas (numero_cuenta, iban, saldo, fecha_creacion, tipo_cuenta) 
VALUES ('0002', 'ES7620770024003102576763', 500.00, TO_DATE('2023-02-01', 'YYYY-MM-DD'), 'CORRIENTE');

-- 4️⃣ Insertar Datos en Operaciones Bancarias
-- Asegúrate de que las cuentas referenciadas existen
INSERT INTO OperacionesBancarias (id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal) 
VALUES (1, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 200.00, 'Transferencia', 'Transferencia de Juan a Ana', 'ES7620770024003102576762', 1);
INSERT INTO OperacionesBancarias (id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal) 
VALUES (2, TO_DATE('2023-03-02', 'YYYY-MM-DD'), 50.00, 'Ingreso', 'Ingreso de efectivo en cuenta', 'ES7620770024003102576763', 2);
-- Inserta la operación con id_operacion = 3 para que no falle la clave foránea en Retiradas
INSERT INTO OperacionesBancarias (id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal) 
VALUES (3, TO_DATE('2023-03-03', 'YYYY-MM-DD'), 100.00, 'Retirada', 'Retiro en cajero automático', 'ES7620770024003102576762', 1);
-- Inserta la operación con id_operacion = 4 para que no falle la clave foránea en Ingresos
INSERT INTO OperacionesBancarias (id_operacion, fecha, monto, tipo_operacion, descripcion, iban, codigo_sucursal) 
VALUES (4, TO_DATE('2023-03-04', 'YYYY-MM-DD'), 150.00, 'Ingreso', 'Ingreso adicional en cuenta', 'ES7620770024003102576763', 2);

-- 5️⃣ Insertar Datos en Transferencias (subentidad de OperacionBancaria)
-- Asegúrate de que las operaciones de transferencia ya están insertadas
INSERT INTO Transferencias (id_operacion, iban_emisor, iban_receptor) 
VALUES (1, 'ES7620770024003102576762', 'ES7620770024003102576763');
INSERT INTO Transferencias (id_operacion, iban_emisor, iban_receptor) 
VALUES (2, 'ES7620770024003102576763', 'ES7620770024003102576762');

-- 6️⃣ Insertar Datos en Retiradas (subentidad de OperacionBancaria)
-- La operación 3 debe existir previamente en OperacionesBancarias
-- Ajustar el valor para que no exceda los 20 caracteres en el campo `metodo_retiro`
INSERT INTO Retiradas (id_operacion, metodo_retiro) 
VALUES (3, 'Cajero automático');

-- 7️⃣ Insertar Datos en Ingresos (subentidad de OperacionBancaria)
-- La operación 4 debe existir previamente en OperacionesBancarias
-- Ajustar el valor para que no exceda los 20 caracteres en el campo `metodo_pago`
INSERT INTO Ingresos (id_operacion, metodo_pago) 
VALUES (4, 'Transferencia');

-- 8️⃣ Insertar Datos en Cuentas Ahorro
-- Asegúrate de que el IBAN esté en Cuentas y el interés esté correctamente definido
-- No se debe dejar NULL en el campo IBAN de CuentasAhorro
INSERT INTO CuentasAhorro (numero_cuenta, iban, interes) 
VALUES ('0001', 'ES7620770024003102576762', 2.5);

-- 9️⃣ Insertar Datos en Cuentas Corriente
-- Asegúrate de que el IBAN esté en Cuentas y el límite de crédito esté correctamente definido
-- No se debe dejar NULL en el campo IBAN de CuentasCorriente
INSERT INTO CuentasCorriente (numero_cuenta, iban, limite_credito) 
VALUES ('0002', 'ES7620770024003102576763', 2000.00);

-- 4️⃣ Verificación de Inserciones
SELECT * FROM Sucursales;
SELECT * FROM Clientes;
SELECT * FROM Cuentas;
SELECT * FROM OperacionesBancarias;
SELECT * FROM Transferencias;
SELECT * FROM Retiradas;
SELECT * FROM Ingresos;
SELECT * FROM CuentasAhorro;
SELECT * FROM CuentasCorriente;

SQL
