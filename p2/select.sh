#!/usr/bin/env bash

docker exec -i p2-oracle-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<EOF

-- Comprobar datos de la tabla CLIENTE
SELECT * FROM Cliente;

-- Comprobar datos de la tabla CUENTA
SELECT * FROM Cuenta;

-- Comprobar relación Cliente-Cuenta
SELECT cc.id_cliente, c.nombre, cc.iban
FROM CuentaCliente cc
JOIN Cliente c ON cc.id_cliente = c.id_cliente;

-- Comprobar datos de la tabla SUCURSAL
SELECT * FROM Sucursal;

-- Comprobar operaciones bancarias (superentidad)
SELECT * FROM OperacionBancaria;

-- Comprobar retiradas (subentidad)
SELECT ob.id_operacion, ob.iban, ob.monto, ob.fecha
FROM Retirada r
JOIN OperacionBancaria ob ON r.id_operacion = ob.id_operacion;

-- Comprobar ingresos (subentidad)
SELECT ob.id_operacion, ob.iban, ob.monto, ob.fecha
FROM Ingreso i
JOIN OperacionBancaria ob ON i.id_operacion = ob.id_operacion;

-- Comprobar transferencias realizadas
SELECT * FROM Transferencia;

EXIT;
EOF
