#!/bin/bash

CONTAINER_NAME="hbase_db"

# Verificar si el contenedor ya existe
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "El contenedor $CONTAINER_NAME ya existe."
    # Si está detenido, lo iniciamos
    if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
        echo "El contenedor ya está corriendo."
    else
        echo "Iniciando el contenedor $CONTAINER_NAME..."
        docker start $CONTAINER_NAME
        sleep 5  # Esperar un poco para que HBase arranque
    fi
else
    echo "Creando y ejecutando el contenedor $CONTAINER_NAME..."
    docker run -d --name $CONTAINER_NAME harisekhon/hbase
    echo "Esperando a que HBase se inicie..."
    sleep 10
fi
# Ejecutar comandos en la shell de HBase dentro del contenedor
echo "Ejecutando comandos en la shell de HBase..."
docker exec -it hbase_db bash -c "
  echo \"Creando tabla test_table...\";
  echo \"create 'test_table', 'cf1'\" | hbase shell 2>/dev/null;
  echo \"Insertando datos en test_table...\";
  echo \"put 'test_table', 'row1', 'cf1:name', 'Alice'\" | hbase shell 2>/dev/null;
  echo \"put 'test_table', 'row2', 'cf1:name', 'Bob'\" | hbase shell 2>/dev/null;
  echo \"put 'test_table', 'row1', 'cf1:age', '30'\" | hbase shell 2>/dev/null;
  echo \"put 'test_table', 'row2', 'cf1:age', '25'\" | hbase shell 2>/dev/null;
  echo \"Verificando los datos...\";
  echo \"scan 'test_table'\" | hbase shell 2>/dev/null;
  echo \"Consulta de una fila específica...\";
  echo \"get 'test_table', 'row1'\" | hbase shell 2>/dev/null;
  echo \"Eliminando datos de prueba...\";
  echo \"delete 'test_table', 'row1', 'cf1:name'\" | hbase shell 2>/dev/null;
  echo \"deleteall 'test_table', 'row2'\" | hbase shell 2>/dev/null;
  echo \"Deshabilitando y eliminando la tabla...\";
  echo \"disable 'test_table'\" | hbase shell 2>/dev/null;
  echo \"drop 'test_table'\" | hbase shell 2>/dev/null;
"


echo "Proceso completado."
