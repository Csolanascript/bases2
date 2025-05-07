import org.apache.spark.sql.functions._

// Se define el valor cassandraProperties: un diccionario
// con los datos para conectarse al keyspace laboratorio
// de la máquina cassandra
val cassandraProperties = Map("spark.cassandra.connection.host" -> "cassandra",
                        "spark.cassandra.connection.port" -> "9042",
                        "keyspace" -> "laboratorio")

/*
// cargar la tabla hospital al valor laboratory_table
val laboratory_table =
    spark.read.format("org.apache.spark.sql.cassandra").
    options(cassandraProperties).
    option("table","hospital").
	load()

// muestra las 20 primeras filas de la tabla 
laboratory_table.show()
*/

val pivotDF = laboratory_table.groupBy("person").pivot("std_observable_cd").sum("obs_value_nm")
pivotDF.show()
pivotDF.count

// Pregunta 11
val media1742 = pivotDF.select(avg("1742-6"))
media1742.show()

// 1. Media de valores numéricos para la prueba con código '3255-7'
laboratory_table
  .filter($"std_observable_cd" === "3255-7")
  .select(avg("obs_value_nm"))
  .show()

// 2. Media de valores numéricos observados para la persona con ID 123498
laboratory_table
  .filter($"person" === 123498)
  .select(avg("obs_value_nm"))
  .show()

// 3. Todas las pruebas con valor observado mayor o igual a 100
laboratory_table
  .filter($"obs_value_nm" >= 100)
  .show(10)  // Solo mostramos 10 resultados para evitar excesivo output
