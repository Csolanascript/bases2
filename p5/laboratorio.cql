/* 1. Keyspace ─────────────── */
CREATE KEYSPACE IF NOT EXISTS laboratorio
WITH REPLICATION = { 'class':'SimpleStrategy', 'replication_factor':1 };

/* 2. Cambiar al keyspace ──── */
USE laboratorio;

/* 3. Tabla ────────────────── */
CREATE TABLE IF NOT EXISTS hospital (
    std_observable_cd text,
    person            int,
    std_observable_st text,
    obs_value_nm      float,
    PRIMARY KEY ((std_observable_cd), person)
) WITH CLUSTERING ORDER BY (person ASC);

/* 4. Carga masiva ───────────
 *    Ajusta la ruta si tu CSV está en otro sitio.
 */

 /*
COPY hospital (
        person,                /* ← mismo orden que el fichero */
        std_observable_cd,
        std_observable_st,
        obs_value_nm
)
FROM '/data/dataset.csv'
WITH DELIMITER = ';'           /* ← punto y coma */
 AND HEADER    = TRUE
 AND QUOTE     = '"'           /* gestiona valores con comas o saltos de línea */
 AND NULL      = ''
 AND ENCODING  = 'UTF8';
*/

USE laboratorio;

SELECT  
    std_observable_cd  AS codigo_prueba,
    std_observable_st  AS nombre_prueba
FROM hospital
PER PARTITION LIMIT 1;

SELECT DISTINCT
    std_observable_cd  AS codigo_prueba
FROM hospital;


// Consultas pregunta 7

/*
SELECT AVG(obs_value_nm) FROM hospital WHERE std_observable_cd = '3255-7';
*/

/*
SELECT AVG(obs_value_nm)
FROM hospital
WHERE person = 123498
ALLOW FILTERING;
*/

/*
SELECT * FROM hospital
WHERE std_observable_cd = '3255-7'
  AND obs_value_nm >= 100 // Es muy pequeño asi que va a devolver miles de filas (153.130 en concreto)
ALLOW FILTERING;

*/