#!/bin/bash
# Script: docker_oracle_roles.sh
# Objetivo:
#   - Crear un usuario con permisos de escritura y otro con permisos de solo lectura en Oracle.
#   - Verificar que se puede interactuar con la tabla admin.my_table mediante estos usuarios.
# Se asume que se ejecuta en el contenedor "p1-oracle-1" y que sqlplus está disponible.

CONTAINER_NAME="p1-oracle-1"
# Usamos las credenciales definidas en docker-compose
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
# Connect string para conectarse a Oracle XE (verifica que sea el correcto)
CONNECT_STRING="localhost:1521/XEPDB1"

# Datos de usuarios (ajustar según políticas de seguridad)
WRITE_USER="MY_WRITE_USER"
WRITE_USER_PASSWORD="StrongWriteUserOracle123!"

READ_USER="MY_READ_USER"
READ_USER_PASSWORD="StrongReadUserOracle123!"

echo "Ejecutando script en el contenedor '$CONTAINER_NAME' para crear usuarios de escritura y solo lectura en Oracle (con admin/admin)..."

# Crear usuarios y otorgar privilegios sobre admin.my_table
docker exec -it $CONTAINER_NAME bash -c "sqlplus -S ${ADMIN_USER}/${ADMIN_PASSWORD}@${CONNECT_STRING} <<EOF
SET SERVEROUTPUT ON

-- Crear usuario de escritura si no existe, y otorgar privilegios sobre admin.my_table
DECLARE
   v_count NUMBER;
BEGIN
   -- Usuario de escritura
   SELECT COUNT(*) INTO v_count FROM all_users WHERE username = UPPER('$WRITE_USER');
   IF v_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Creando usuario de escritura $WRITE_USER...');
      EXECUTE IMMEDIATE 'CREATE USER $WRITE_USER IDENTIFIED BY \"$WRITE_USER_PASSWORD\"';
      EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO $WRITE_USER';
      DBMS_OUTPUT.PUT_LINE('Usuario de escritura $WRITE_USER creado.');
   ELSE
      DBMS_OUTPUT.PUT_LINE('El usuario de escritura $WRITE_USER ya existe.');
   END IF;

   -- Asignar privilegios a MY_WRITE_USER sobre la tabla admin.my_table
   DBMS_OUTPUT.PUT_LINE('Otorgando privilegios de INSERT, UPDATE, DELETE a $WRITE_USER sobre admin.my_table...');
   EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON admin.my_table TO $WRITE_USER';
END;
/
-- Crear usuario de solo lectura si no existe, y otorgar privilegios sobre admin.my_table
DECLARE
   v_count NUMBER;
BEGIN
   -- Usuario de solo lectura
   SELECT COUNT(*) INTO v_count FROM all_users WHERE username = UPPER('$READ_USER');
   IF v_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Creando usuario de solo lectura $READ_USER...');
      EXECUTE IMMEDIATE 'CREATE USER $READ_USER IDENTIFIED BY \"$READ_USER_PASSWORD\"';
      EXECUTE IMMEDIATE 'GRANT CONNECT TO $READ_USER';
      DBMS_OUTPUT.PUT_LINE('Usuario de solo lectura $READ_USER creado.');
   ELSE
      DBMS_OUTPUT.PUT_LINE('El usuario de solo lectura $READ_USER ya existe.');
   END IF;

   -- Asignar privilegios a MY_READ_USER sobre la tabla admin.my_table
   DBMS_OUTPUT.PUT_LINE('Otorgando privilegios de SELECT a $READ_USER sobre admin.my_table...');
   EXECUTE IMMEDIATE 'GRANT SELECT ON admin.my_table TO $READ_USER';
END;
/
EXIT;
EOF"

# Bloque de prueba de interacción con la tabla admin.my_table
TEST_VALUE="Test insert by write user"
echo "Insertando registro de prueba con el usuario '$WRITE_USER' en admin.my_table..."
docker exec -it $CONTAINER_NAME bash -c "sqlplus -S ${WRITE_USER}/${WRITE_USER_PASSWORD}@${CONNECT_STRING} <<EOF
SET SERVEROUTPUT ON
BEGIN
  -- Usamos el esquema explícito admin.my_table
  EXECUTE IMMEDIATE 'INSERT INTO admin.my_table (NAME) VALUES (''$TEST_VALUE'')';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Inserción exitosa por $WRITE_USER en admin.my_table.');
END;
/
EXIT;
EOF"

echo "Leyendo registro con el usuario '$READ_USER' desde admin.my_table..."
docker exec -it $CONTAINER_NAME bash -c "sqlplus -S ${READ_USER}/${READ_USER_PASSWORD}@${CONNECT_STRING} <<EOF
SET SERVEROUTPUT ON
DECLARE
   CURSOR c IS SELECT ID, NAME, CREATED_AT FROM admin.my_table WHERE NAME = '$TEST_VALUE';
   rec c%ROWTYPE;
BEGIN
   OPEN c;
   LOOP
      FETCH c INTO rec;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Fila: ' || rec.ID || ', ' || rec.NAME || ', ' || rec.CREATED_AT);
   END LOOP;
   CLOSE c;
END;
/
EXIT;
EOF"

echo "Prueba de interacción completada en Oracle."
echo "Script docker_oracle_roles.sh finalizado."
