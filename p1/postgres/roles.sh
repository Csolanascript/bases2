#!/bin/bash
# Script: docker_postgres_roles.sh
# Objetivo:
#   - Crear un superusuario, un usuario con permisos de escritura y otro con permisos de solo lectura.
#   - Verificar que se puede interactuar con la tabla "my_table" mediante estos usuarios.
# Se asume que se ejecuta en el contenedor "p1-postgres-1".

CONTAINER_NAME="p1-postgres-1"
DATABASE="postgres"
ADMIN_USER="postgres"

# Credenciales y nombres de usuarios (ajustar según políticas de seguridad)
NEW_SUPERUSER="my_superuser"
NEW_SUPERUSER_PASSWORD="StrongSuperUserPassword123!"

WRITE_USER="my_write_user"
WRITE_USER_PASSWORD="StrongWriteUserPassword123!"

READ_USER="my_read_user"
READ_USER_PASSWORD="StrongReadUserPassword123!"

echo "Ejecutando script dentro del contenedor '$CONTAINER_NAME' para crear roles y usuarios en PostgreSQL..."

# Crear superusuario si no existe
echo "Creando superusuario '$NEW_SUPERUSER' (si no existe)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$NEW_SUPERUSER') THEN
      CREATE ROLE $NEW_SUPERUSER WITH LOGIN SUPERUSER PASSWORD '$NEW_SUPERUSER_PASSWORD';
   END IF;
END
\$\$;"
echo "Superusuario '$NEW_SUPERUSER' creado (o ya existía)."

# Verificar conexión con el nuevo superusuario
echo "Verificando conexión con superusuario '$NEW_SUPERUSER'..."
docker exec -it $CONTAINER_NAME psql -U $NEW_SUPERUSER -d $DATABASE -c "\conninfo"
echo "Conexión verificada."

# Crear usuario con permisos de escritura si no existe
echo "Creando usuario de escritura '$WRITE_USER' (si no existe)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$WRITE_USER') THEN
      CREATE ROLE $WRITE_USER WITH LOGIN PASSWORD '$WRITE_USER_PASSWORD';
      GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $WRITE_USER;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, UPDATE, DELETE ON TABLES TO $WRITE_USER;
   END IF;
END
\$\$;"
echo "Usuario de escritura '$WRITE_USER' creado (o ya existía)."

# Otorgar permisos sobre la secuencia asociada a la columna serial
echo "Otorgando permisos sobre la secuencia 'my_table_id_seq' al usuario '$WRITE_USER'..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "GRANT USAGE, SELECT ON SEQUENCE my_table_id_seq TO $WRITE_USER;"
echo "Permisos sobre la secuencia otorgados."

# Crear usuario de solo lectura si no existe
echo "Creando usuario de solo lectura '$READ_USER' (si no existe)..."
docker exec -it $CONTAINER_NAME psql -U $ADMIN_USER -d $DATABASE -c "DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$READ_USER') THEN
      CREATE ROLE $READ_USER WITH LOGIN PASSWORD '$READ_USER_PASSWORD';
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO $READ_USER;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $READ_USER;
   END IF;
END
\$\$;"
echo "Usuario de solo lectura '$READ_USER' creado (o ya existía)."

# ----- Bloque de prueba de interacción con la tabla -----
TEST_VALUE="Test insert by write user"
echo "Probando interacción con la tabla 'my_table'..."
echo "Insertando registro de prueba con usuario '$WRITE_USER'..."
docker exec -it $CONTAINER_NAME psql -U $WRITE_USER -d $DATABASE -c "INSERT INTO my_table (name) VALUES ('$TEST_VALUE');"
echo "Registro insertado."

echo "Leyendo registro con usuario '$READ_USER'..."
docker exec -it $CONTAINER_NAME psql -U $READ_USER -d $DATABASE -c "SELECT * FROM my_table WHERE name='$TEST_VALUE';"
echo "Prueba de interacción completada."
echo "Script docker_postgres_roles.sh finalizado."
