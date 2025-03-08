#!/bin/bash
# Script: docker_db2_tables.sh
# Objetivo:
#   - Conectarse al contenedor Db2.
#   - Crear la tabla MY_TABLE en el esquema db2inst1 (si no existe).
#   - Insertar datos de ejemplo (si la tabla está vacía).
#
# Se asume que:
#   - El contenedor se llama "db2-server"
#   - La base de datos es "testdb"
#   - El usuario principal es "db2inst1" con contraseña "admin"

CONTAINER="db2-server"    # Ajusta según tu docker-compose
DBNAME="testdb"           
INSTUSER="db2inst1"       
INSTPASS="admin"          

echo "=== Creación y poblado de MY_TABLE en IBM Db2 dentro del contenedor '$CONTAINER' ==="

# 1) Verificar si la tabla MY_TABLE existe
TABLE_EXISTS=$(docker exec -i "$CONTAINER" su - $INSTUSER -c "db2 -x <<EOF
CONNECT TO $DBNAME USER $INSTUSER USING $INSTPASS;
SELECT COUNT(*) FROM syscat.tables WHERE tabschema = UPPER('$INSTUSER') AND tabname = 'MY_TABLE';
EOF")

# Extraer el valor numérico de la salida
TABLE_EXISTS=$(echo "$TABLE_EXISTS" | grep -Eo '^[0-9]+' | head -n1)
TABLE_EXISTS=${TABLE_EXISTS:-0}

if [ "$TABLE_EXISTS" = "0" ]; then
  echo "La tabla MY_TABLE no existe. Creándola..."
  docker exec -i "$CONTAINER" su - $INSTUSER -c "db2 -tv <<EOF
CONNECT TO $DBNAME USER $INSTUSER USING $INSTPASS;
CREATE TABLE MY_TABLE (
  ID INT GENERATED ALWAYS AS IDENTITY,
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID)
);
COMMIT;
EOF"
else
  echo "La tabla MY_TABLE ya existe."
fi

# 2) Comprobar si la tabla está vacía
ROW_COUNT=$(docker exec -i "$CONTAINER" su - $INSTUSER -c "db2 -x <<EOF
CONNECT TO $DBNAME USER $INSTUSER USING $INSTPASS;
SELECT COUNT(*) FROM MY_TABLE;
EOF")

ROW_COUNT=$(echo "$ROW_COUNT" | grep -Eo '^[0-9]+' | head -n1)
ROW_COUNT=${ROW_COUNT:-0}

if [ "$ROW_COUNT" = "0" ]; then
  echo "Insertando datos de ejemplo en MY_TABLE..."
  docker exec -i "$CONTAINER" su - $INSTUSER -c "db2 -tv <<EOF
CONNECT TO $DBNAME USER $INSTUSER USING $INSTPASS;
INSERT INTO MY_TABLE (NAME) VALUES ('Sample Data');
COMMIT;
EOF"
else
  echo "MY_TABLE ya contiene datos (total filas: $ROW_COUNT)."
fi

echo "=== Script docker_db2_tables.sh completado. ==="
