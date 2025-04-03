

-- Eliminar vistas si existen
BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW Titular_Unificado';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaCliente';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaCuenta';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaCuentaCliente';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaCuentaAhorro';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaCuentaCorriente';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaSucursal';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaOperacionBancaria';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaOpefectivo';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW VistaTransferencia';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW CODPOSTAL';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW CODENTIDADES';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

---------------------------------------------------------------------
-- Creación de las vistas
---------------------------------------------------------------------

-- Vista para Titular_Unificado (accediendo vía dblink)
CREATE OR REPLACE VIEW Titular_Unificado AS
SELECT 
    t.DNI,
    t.NOMBRE,
    t.APELLIDO1,
    t.APELLIDO2,
    d.CALLE || ', ' || d.CIUDAD || ', Nº ' || d.NUMERO || ', Piso ' || d.PISO AS DIRECCION_COMPLETA,
    t.TELEFONO,
    t.FECHA_NACIMIENTO
FROM TITULAR@SCHEMA2BD2 t
JOIN DIRECCION@SCHEMA2BD2 d
    ON t.DIRECCION = d.ID_DIRECCION;

-- Vista unificada para la tabla CLIENTE
CREATE VIEW VistaCliente AS
SELECT 
    COALESCE(TO_CHAR(b.dni), TO_CHAR(a.dni)) AS dni,
    COALESCE(b.nombre, a.nombre) AS nombre,
    COALESCE(CAST((2025 - b.edad) AS VARCHAR2(10)), TO_CHAR(a.fecha_nacimiento, 'DD/MM/YYYY')) AS fecha_nacimiento,
    COALESCE(a.APELLIDO1 || ' ' || a.APELLIDO2, b.apellidos) AS APELLIDOS, 
    COALESCE(b.telefono, a.telefono) AS telefono,
    b.email AS email,
    COALESCE(b.direccion, a.DIRECCION_COMPLETA) AS direccion
FROM 
    Titular_Unificado a
    FULL OUTER JOIN Cliente b ON TO_CHAR(a.dni) = TO_CHAR(b.dni);

-- Vista unificada para la tabla CUENTA
CREATE VIEW VistaCuenta AS
SELECT 
    COALESCE(b.iban, a.CCC) AS iban,
    b.numero_cuenta,
    COALESCE(b.saldo, a.saldo) AS saldo,
    COALESCE(b.fecha_creacion, a.FECHACREACION) AS fecha_creacion
FROM 
    Cuenta@SCHEMA2BD2 a
    FULL OUTER JOIN Cuenta b ON a.CCC = b.iban;

-- Vista unificada para la tabla CUENTACLIENTE
CREATE VIEW VistaCuentaCliente AS
SELECT CAST(a.dni AS VARCHAR2(20)) AS dni, CAST(a.iban AS VARCHAR2(50)) AS iban 
FROM CuentaCliente a
UNION
SELECT CAST(b.TITULAR AS VARCHAR2(20)) AS dni, CAST(b.CCC AS VARCHAR2(50)) AS iban 
FROM Cuenta@SCHEMA2BD2 b;

-- Vista unificada para la tabla AHORRO
CREATE VIEW VistaCuentaAhorro AS
SELECT 
    b.CCC AS iban,
    b.TIPOINTERES AS interes
FROM 
    CUENTAAHORRO@SCHEMA2BD2 b
UNION
SELECT 
    a.iban,
    a.interes
FROM 
    Ahorro a;

-- Vista unificada para la tabla CORRIENTE
CREATE VIEW VistaCuentaCorriente AS
SELECT 
    b.CCC  AS iban,
    b.SUCURSAL_CODOFICINA AS codigo_sucursal
FROM 
    CUENTACORRIENTE@SCHEMA2BD2 b
UNION
SELECT 
    a.iban AS iban,
    a.codigo_sucursal AS codigo_sucursal
FROM 
    Corriente a;

-- Vista unificada para la tabla SUCURSAL
CREATE VIEW VistaSucursal AS
SELECT 
    b.CODOFICINA,
    b.dir,
    NULL AS tfno
FROM 
    Sucursal@SCHEMA2BD2 b
UNION
SELECT 
    a.codigo_sucursal,
    a.direccion,
    a.telefono
FROM 
    Sucursal a;

-- Vista unificada para la tabla OPERACIONBANCARIA
CREATE VIEW VistaOperacionBancaria AS
SELECT 
    numop AS codigo_numerico,
    CCC AS iban,
    cantidadop AS cantidad,
    fechaop AS fecha,
    horaop AS hora,
    descripcionOP AS descripcionOP
FROM OPERACION@SCHEMA2BD2
UNION
SELECT 
    codigo_numerico,
    iban,
    cantidad,
    fecha,
    TO_CHAR(hora, 'HH24:MI:SS') AS hora,
    NULL AS descripcionOP
FROM OperacionBancaria;

-- Vista unificada para la tabla OPefectivo (Retirada e Ingreso)
CREATE VIEW VistaOpefectivo AS
SELECT 
    a.codigo_numerico AS codigo_numerico,
    a.iban AS iban,
    a.codigo_sucursal AS codigo_sucursal,
    'retirada' AS tipoopefectivo
FROM 
    Retirada a
UNION
SELECT 
    a.codigo_numerico AS codigo_numerico,
    a.iban AS iban,
    a.codigo_sucursal AS codigo_sucursal,
    'ingreso' AS tipoopefectivo
FROM 
    Ingreso a
UNION
SELECT 
    b.NUMOP AS codigo_numerico,  
    b.CCC AS iban,                    
    b.SUCURSAL_CODOFICINA AS codigo_sucursal,       
    b.TIPOOPEFECTIVO AS tipoopefectivo
FROM 
    OPEFECTIVO@SCHEMA2BD2 b;

-- Vista unificada para la tabla TRANSFERENCIA
CREATE VIEW VistaTransferencia AS
SELECT 
    b.NUMOP AS codigo_numerico,
    b.CCC AS iban_emisor,
    b.CUENTADESTINO AS iban_receptor
FROM 
    OPTRANSFERENCIA@SCHEMA2BD2 b
UNION
SELECT 
    a.codigo_numerico AS codigo_numerico,
    a.iban_emisor AS iban_emisor,
    a.iban_receptor AS iban_receptor
FROM 
    Transferencia a;

-- Vistas para CODPOSTAL y CODENTIDADES (acceso remoto)
CREATE VIEW CODPOSTAL AS 
SELECT * FROM CODPOSTAL@SCHEMA2BD2;

CREATE VIEW CODENTIDADES AS 
SELECT * FROM CODENTIDADES@SCHEMA2BD2;

---------------------------------------------------------------------
-- Sentencias SELECT para verificar el contenido de cada vista
---------------------------------------------------------------------

-- Verificar Titular_Unificado
SELECT * FROM Titular_Unificado;

-- Verificar VistaCliente
SELECT * FROM VistaCliente;

-- Verificar VistaCuenta
SELECT * FROM VistaCuenta;

-- Verificar VistaCuentaCliente
SELECT * FROM VistaCuentaCliente;

-- Verificar VistaCuentaAhorro
SELECT * FROM VistaCuentaAhorro;

-- Verificar VistaCuentaCorriente
SELECT * FROM VistaCuentaCorriente;

-- Verificar VistaSucursal
SELECT * FROM VistaSucursal;

-- Verificar VistaOperacionBancaria
SELECT * FROM VistaOperacionBancaria;

-- Verificar VistaOpefectivo
SELECT * FROM VistaOpefectivo;

-- Verificar VistaTransferencia
SELECT * FROM VistaTransferencia;

-- Verificar CODPOSTAL
SELECT * FROM CODPOSTAL;

-- Verificar CODENTIDADES
SELECT * FROM CODENTIDADES;
