#!/bin/bash

# Nombre del contenedor de DB2
CONTAINER_NAME="db2-server"

# Usuario, contraseña y base de datos (según tu docker-compose.yml)
DB_USER="db2inst1"
DB_PASSWORD="admin"
DB_NAME="testdb"

# Ruta dentro del contenedor donde se copiará el script SQL
SQL_SCRIPT_PATH="/tmp/poblado.sql"

echo "Verificando si el contenedor $CONTAINER_NAME está corriendo..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: El contenedor $CONTAINER_NAME no está corriendo. Inícialo con:"
    echo "docker-compose up -d"
    exit 1
fi

# Crear el script SQL
SQL_SCRIPT=$(cat <<EOF
CONNECT TO $DB_NAME USER $DB_USER USING '$DB_PASSWORD';

-- CLIENTES
INSERT INTO Cliente (id_cliente, DNI, Edad, Nombre, Apellidos, Email, Direccion, Telefono) VALUES
(ClienteUdt(1), '11111111A', 30, 'Juan', 'Pérez', 'juan.perez@email.com', 'Calle Falsa 123, Ciudad X', '555-1234'),
(ClienteUdt(2), '22222222A', 28, 'Ana', 'Gómez', 'ana.gomez@email.com', 'Avenida Siempre Viva 456, Ciudad Y', '555-5678'),
(ClienteUdt(3), '33333333A', 35, 'Carlos', 'Martínez', 'carlos.martinez@email.com', 'Calle Principal 789, Ciudad Z', '555-9876'),
(ClienteUdt(4), '44444444A', 40, 'Laura', 'Hernández', 'laura.hernandez@email.com', 'Plaza Mayor 12, Ciudad W', '555-1111'),
(ClienteUdt(5), '55555555A', 25, 'Pedro', 'López', 'pedro.lopez@email.com', 'Calle del Sol 45, Ciudad V', '555-2222');

-- SUCURSALES
INSERT INTO Sucursal (id_sucursal, Codigo, Direccion, Telefono) VALUES
(SucursalUdt(1), 101, 'Sucursal Central, Ciudad X', 5551111),
(SucursalUdt(2), 102, 'Sucursal Norte, Ciudad Y', 5552222),
(SucursalUdt(3), 103, 'Sucursal Este, Ciudad Z', 5553333);

-- CUENTAS
INSERT INTO Cuenta (id_cuenta, IBAN, Numero_Cuenta, Saldo, Fecha_Creacion) VALUES
(CuentaUdt(1), 'ES1234567890123456789012', 1234567890, 1000.00, '2022-01-15'),
(CuentaUdt(2), 'ES9876543210987654321098', 987654321, 2500.00, '2022-02-20'),
(CuentaUdt(3), 'ES5432167890123456789012', 543216789, 1500.00, '2022-03-01');

-- CUENTAS AHORRO (subtipo)
INSERT INTO CuentaAhorro VALUES
(CuentaAhorroUdt(4), 'ES1234567890123456789012', 1234567890, 1000.00, '2022-01-15', 0.2),
(CuentaAhorroUdt(5), 'ES9876543210987654321098', 987654321, 2500.00, '2022-02-20', 0.5);

-- CUENTAS CORRIENTE (subtipo)
INSERT INTO CuentaCorriente VALUES
(CuentaCorrienteUdt(6), 'ES5432167890123456789012', 543216789, 1500.00, '2022-03-01', SucursalUdt(1));


-- OPERACIONES BANCARIAS (padre)
INSERT INTO Operacion_Bancaria VALUES
(OperacionBancariaUdt(1), 'Transferencia de dinero', 1, TIME('12:00:00'), DATE('2023-03-01'), 200.00, 'TRANSFERENCIA', CuentaUdt(1)),
(OperacionBancariaUdt(2), 'Retiro en cajero automático', 2, TIME('12:00:00'), DATE('2023-03-02'), 500.00, 'RETIRO', CuentaUdt(2)),
(OperacionBancariaUdt(3), 'Ingreso en cuenta', 3, TIME('12:00:00'), DATE('2023-03-03'), 300.00, 'INGRESO', CuentaUdt(3));


-- TRANSFERENCIAS
INSERT INTO Transferencia VALUES
(TransferenciaUdt(4), 'Transferencia de dinero', 1, TIME('12:00:00'), DATE('2023-03-01'), 200.00, 'TRANSFERENCIA', CuentaUdt(1), CuentaUdt(2));

-- RETIRADAS
INSERT INTO Retirada VALUES
(RetiradaUdt(5), 'Retiro en cajero automático', 2, TIME('12:00:00'), DATE('2023-03-02'), 500.00, 'RETIRO', CuentaUdt(2), SucursalUdt(1));

-- INGRESOS
INSERT INTO Ingreso VALUES
(IngresoUdt(6), 'Ingreso en cuenta', 3, TIME('12:00:00'), DATE('2023-03-03'), 300.00, 'INGRESO', CuentaUdt(3),  SucursalUdt(2));

-- TIENE
INSERT INTO Tiene (id_tiene, DNI, IBAN) VALUES
(TieneUdt(1), ClienteUdt(1), CuentaUdt(1)),
(TieneUdt(2), ClienteUdt(2), CuentaUdt(2)),
(TieneUdt(3), ClienteUdt(3), CuentaUdt(3));

SELECT * FROM Cliente;
SELECT * FROM Sucursal;
SELECT * FROM Cuenta;
SELECT * FROM Operacion_Bancaria;
SELECT * FROM Transferencia;
SELECT * FROM Retirada;
SELECT * FROM Ingreso;
SELECT * FROM CuentaAhorro;
SELECT * FROM CuentaCorriente;
SELECT * FROM Tiene;

EOF
)

# Guardar el script en un archivo dentro del host
echo "$SQL_SCRIPT" > poblado.sql

# Copiar el archivo al contenedor DB2
docker cp poblado.sql $CONTAINER_NAME:$SQL_SCRIPT_PATH

# Ejecutar el script dentro del contenedor
docker exec -i $CONTAINER_NAME bash -c "
    su - $DB_USER -c \"
        db2 connect to $DB_NAME user $DB_USER using '$DB_PASSWORD';
        db2 -tvf $SQL_SCRIPT_PATH;
        db2 terminate;
    \"
"

# Limpiar archivos temporales
rm -f poblado.sql

echo "Inserción de datos completada en DB2 dentro del contenedor $CONTAINER_NAME."
