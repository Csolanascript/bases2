#!/bin/bash

docker exec -i p2-oracle2-1 sqlplus admin/admin@//localhost:1521/XEPDB1 <<EOF




DROP TABLE Clientes CASCADE CONSTRAINTS;
DROP TABLE Cuentas CASCADE CONSTRAINTS;
DROP TABLE OperacionesBancarias CASCADE CONSTRAINTS;
DROP TABLE Sucursales CASCADE CONSTRAINTS;
DROP TABLE Transferencias CASCADE CONSTRAINTS;
DROP TABLE Retiradas CASCADE CONSTRAINTS;
DROP TABLE Ingresos CASCADE CONSTRAINTS;
DROP TABLE CuentasAhorro CASCADE CONSTRAINTS;
DROP TABLE CuentasCorriente CASCADE CONSTRAINTS;

-- 2️⃣ Eliminar los tipos de objetos en el orden correcto (subentidades primero)
DROP TYPE TransferenciaUDT FORCE;
DROP TYPE RetiradaUDT FORCE;
DROP TYPE IngresoUDT FORCE;

-- Eliminar tipos de objetos hijos
DROP TYPE CuentaAhorroUDT FORCE;
DROP TYPE CuentaCorrienteUDT FORCE;

-- Eliminar tipos de objetos base
DROP TYPE OperacionBancariaUDT FORCE;
DROP TYPE SucursalUDT FORCE;
DROP TYPE ClienteUDT FORCE;
DROP TYPE CuentaUDT FORCE;

EOF

echo "Tipos de objetos y tablas eliminados correctamente."
