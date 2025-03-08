#!/bin/bash
set +H
# Script: docker_db2_roles.sh
# Objetivo:
#   - Crear cuentas de sistema operativo en el contenedor Db2 para los usuarios
#     my_write_user y my_read_user.
#   - Otorgar privilegios en Db2 para dichas cuentas:
#       * my_write_user: CONNECT y INSERT, UPDATE, DELETE sobre MY_TABLE.
#       * my_read_user: CONNECT y SELECT sobre MY_TABLE.
#   - Probar la inserción y lectura para confirmar los permisos.
#
# Se asume:
#   - El contenedor se llama "db2-server" (ajusta según tu docker-compose).
#   - La base de datos es "testdb".
#   - El usuario de instancia es "db2inst1" con contraseña "admin".
#   - El ejecutable Db2 se encuentra en /opt/ibm/db2/V11.5/bin/db2.
#   - El archivo de perfil se encuentra en /database/config/db2inst1/sqllib/db2profile.
#   - La tabla MY_TABLE ya existe en la base de datos.
#
# IMPORTANTE: Si alguna de estas rutas difiere en tu entorno, actualiza las variables DB2CMD y DB2PROFILE.

CONTAINER="db2-server"   # Ajusta según tu docker-compose
DBNAME="testdb"
INSTUSER="db2inst1"
INSTPASS="admin"

# Nuevos usuarios y contraseñas.
# Nota: Se han removido los signos de exclamación para evitar problemas de expansión.
WRITE_USER="my_write_user"
WRITE_PASS="WriteUser123"
READ_USER="my_read_user"
READ_PASS="ReadUser123"

# Ruta al comando Db2 y al archivo de perfil:
DB2CMD="/opt/ibm/db2/V11.5/bin/db2"
DB2PROFILE="/database/config/db2inst1/sqllib/db2profile"

echo "=== Creando usuarios OS y asignando privilegios en Db2 dentro del contenedor '$CONTAINER' ==="

# 1) Crear usuarios del sistema operativo dentro del contenedor
echo "Creando usuarios del sistema (si no existen) y asignando contraseña..."
docker exec -i "$CONTAINER" bash -c "id $WRITE_USER || useradd $WRITE_USER"
docker exec -i "$CONTAINER" bash -c "echo \"$WRITE_USER:$WRITE_PASS\" | chpasswd"
docker exec -i "$CONTAINER" bash -c "id $READ_USER || useradd $READ_USER"
docker exec -i "$CONTAINER" bash -c "echo \"$READ_USER:$READ_PASS\" | chpasswd"

# 2) Otorgar privilegios en Db2 usando el usuario de instancia (db2inst1)
echo "Otorgando privilegios en Db2 para $WRITE_USER y $READ_USER..."
docker exec -i "$CONTAINER" su - $INSTUSER -c ". $DB2PROFILE; $DB2CMD -tv <<EOF
CONNECT TO $DBNAME USER $INSTUSER USING $INSTPASS;
GRANT CONNECT ON DATABASE TO USER $WRITE_USER;
GRANT CONNECT ON DATABASE TO USER $READ_USER;
GRANT INSERT, UPDATE, DELETE ON MY_TABLE TO USER $WRITE_USER;
GRANT SELECT ON MY_TABLE TO USER $READ_USER;
COMMIT WORK;
EOF"

# 3) Probar inserción con my_write_user usando el entorno de Db2
echo "Insertando registro con el usuario '$WRITE_USER'..."
docker exec -i "$CONTAINER" bash -c "su - $WRITE_USER -c \". $DB2PROFILE; $DB2CMD -tv <<EOF
CONNECT TO $DBNAME USER $WRITE_USER USING $WRITE_PASS;
INSERT INTO MY_TABLE (NAME) VALUES ('Insertado por $WRITE_USER');
COMMIT;
EOF\""

# 4) Probar lectura con my_read_user
echo "Leyendo registro con el usuario '$READ_USER'..."
docker exec -i "$CONTAINER" bash -c "su - $READ_USER -c \". $DB2PROFILE; $DB2CMD -tv <<EOF
CONNECT TO $DBNAME USER $READ_USER USING $READ_PASS;
SELECT ID, NAME, CREATED_AT FROM MY_TABLE WHERE NAME='Insertado por $WRITE_USER';
EOF\""

echo "=== Script docker_db2_roles.sh completado. ==="
