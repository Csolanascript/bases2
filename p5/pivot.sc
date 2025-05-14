import org.apache.spark.sql.functions._

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

// ===================================================================
// ===  PREPARACIÓN: crear la vista temporal 'lab'  ==================
// ===================================================================

// Si ya la tenías creada, basta con asegurarse de que existe;
// en caso contrario, se crea ahora.  Spark SQL operará sobre ella.
laboratory_table.createOrReplaceTempView("lab")

// ===================================================================
// ===  PREGUNTA 12 – Spark SQL para Pregunta 7 y Pregunta 11  =======
// ===================================================================

// 7.1  Media de valores numéricos para la prueba '3255-7'
val media_3255_7_SQL = spark.sql("""
    SELECT AVG(obs_value_nm) AS media_3255_7
    FROM   lab
    WHERE  std_observable_cd = '3255-7'
""")
media_3255_7_SQL.show()

// 7.2  Media de valores numéricos observados para la persona 123498
val media_person_123498_SQL = spark.sql("""
    SELECT AVG(obs_value_nm) AS media_person_123498
    FROM   lab
    WHERE  person = 123498
""")
media_person_123498_SQL.show()

// 7.3  Todas las pruebas con valor observado ≥ 100
val pruebas_ge_100_SQL = spark.sql("""
    SELECT *
    FROM   lab
    WHERE  obs_value_nm >= 100
""")
pruebas_ge_100_SQL.show(10)   // limitamos la salida a 10 filas

// 11.   Media de los valores observados en la prueba '1742-6'
val media_1742_6_SQL = spark.sql("""
    SELECT AVG(obs_value_nm) AS media_1742_6
    FROM   lab
    WHERE  std_observable_cd = '1742-6'
""")
media_1742_6_SQL.show()

// ===================================================================
// ===  PREGUNTA 13 – Dos consultas que NO se pueden hacer en CQL  ===
// ===================================================================

// -------------------------------------------------------------------
// 13.a  Top‑10 personas con mayor nº de pruebas DIFERENTES realizadas
//       (JOIN ni falta hace, pero CQL no permite COUNT(DISTINCT …)
//        sobre un atributo que no sea clave de partición + agrupación).
// -------------------------------------------------------------------
val top10_distinct_tests_per_person = spark.sql("""
    SELECT person,
           COUNT(DISTINCT std_observable_cd) AS num_distinct_tests
    FROM   lab
    GROUP  BY person
    ORDER  BY num_distinct_tests DESC
    LIMIT  10
""")
top10_distinct_tests_per_person.show()

// -------------------------------------------------------------------
// 13.b  Correlación de Pearson entre las medias por persona de dos
//       pruebas (‘3255-7’ y ‘1742-6’).  Necesita:
//         • subconsulta (WITH),
//         • funciones de ventana condicionales (CASE WHEN …),
//         • función estadística corr(…)
//       NINGUNA de ellas existe en CQL.
// -------------------------------------------------------------------
val correlacion_pruebas = spark.sql("""
    WITH medias_persona AS (
        SELECT person,
               AVG(CASE WHEN std_observable_cd = '3255-7'
                        THEN obs_value_nm END) AS avg_3255_7,
               AVG(CASE WHEN std_observable_cd = '1742-6'
                        THEN obs_value_nm END) AS avg_1742_6
        FROM   lab
        GROUP  BY person
    )
    SELECT corr(avg_3255_7, avg_1742_6) AS correlacion_pearson
    FROM   medias_persona
""")
correlacion_pruebas.show()
