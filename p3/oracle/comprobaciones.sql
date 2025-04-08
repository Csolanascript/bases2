-- Comprobar datos de la tabla CLIENTE
SELECT * FROM Cliente;

-- Comprobar datos de la tabla CUENTA
SELECT * FROM Cuenta;

-- Comprobar relación Cliente-Cuenta
SELECT cc.dni, c.nombre, cc.iban
FROM CuentaCliente cc
JOIN Cliente c ON cc.dni = c.dni;

-- Comprobar datos de la tabla SUCURSAL
SELECT * FROM Sucursal;

-- Comprobar operaciones bancarias (superentidad)
SELECT * FROM OperacionBancaria;

-- Comprobar retiradas (subentidad)
SELECT ob.codigo_numerico, ob.iban, ob.cantidad, ob.fecha
FROM Retirada r
JOIN OperacionBancaria ob ON r.codigo_numerico = ob.codigo_numerico AND r.iban = ob.iban;

-- Comprobar ingresos (subentidad)
SELECT ob.codigo_numerico, ob.iban, ob.cantidad, ob.fecha
FROM Ingreso i
JOIN OperacionBancaria ob ON i.codigo_numerico = ob.codigo_numerico AND i.iban = ob.iban;

-- Comprobar transferencias realizadas
SELECT * FROM Transferencia;

EXIT;