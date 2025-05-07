CREATE KEYSPACE IF NOT EXISTS laboratorio WITH REPLICATION =
{ 'class': 'SimpleStrategy',
'replication_factor': '1'
};

CREATE TABLE laboratorio.hospital (
    std_observable_cd text,
    person int,
    std_observable_st text,
    obs_value_nm float,
    PRIMARY KEY ((std_observable_cd), person)
) WITH CLUSTERING ORDER BY (person ASC);


// carga de datos con COPY