// Se define el valor cassandraProperties: un diccionario
// con los datos para conectarse al keyspace laboratorio
// de la máquina cassandra
val cassandraProperties = Map("spark.cassandra.connection.host" -> "cassandra",
                        "spark.cassandra.connection.port" -> "9042",
                        "keyspace" -> "laboratorio")

// cargar la tabla hospital al valor laboratory_table
val laboratory_table =
    spark.read.format("org.apache.spark.sql.cassandra").
    options(cassandraProperties).
    option("table","hospital").
	load()

// muestra las 20 primeras filas de la tabla 
laboratory_table.show()


val pivotDF = laboratory_table.groupBy("person").pivot("std_observable_cd").sum("obs_value_nm")
pivotDF.show()
pivotDF.count