

SELECT cons.constraint_name, cons.table_name, cols.column_name
FROM user_constraints@SCHEMA2BD2 cons
JOIN user_cons_columns@SCHEMA2BD2 cols
  ON cons.constraint_name = cols.constraint_name
WHERE cons.constraint_type = 'P'
ORDER BY cons.table_name, cons.constraint_name;

SELECT cons.constraint_name, cons.table_name, cols.column_name, rcons.table_nam$
FROM user_constraints@SCHEMA2BD2 cons
JOIN user_cons_columns@SCHEMA2BD2 cols
  ON cons.constraint_name = cols.constraint_name
JOIN user_constraints@SCHEMA2BD2 rcons
  ON cons.r_constraint_name = rcons.constraint_name
JOIN user_cons_columns@SCHEMA2BD2 rcols
  ON rcons.constraint_name = rcols.constraint_name
WHERE cons.constraint_type = 'R'
ORDER BY cons.table_name, cons.constraint_name;


SELECT cons.constraint_name, cons.table_name, cons.search_condition
FROM user_constraints@SCHEMA2BD2 cons
WHERE cons.constraint_type = 'C'
ORDER BY cons.table_name, cons.constraint_name;

