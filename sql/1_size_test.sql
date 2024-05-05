
drop database if exists testdb;
create database testdb;
select pg_database_size('testdb');

drop table if exists test;
create table test(
    id int primary key ,
    name varchar not null ,
    date timestamp not null ,
    action varchar not null
);
select pg_relation_size('indexes'), pg_database_size('testdb');

CREATE OR REPLACE FUNCTION insert_data()
RETURNS void AS $$
DECLARE
    current_id INTEGER := 2356;
    max_id INTEGER := 3000;
    table_size BIGINT;
BEGIN
    WHILE current_id <= max_id LOOP
        INSERT INTO test(id, name, date, action) VALUES (current_id, 1, current_timestamp, 1);
        GET DIAGNOSTICS table_size = ROW_COUNT;

        IF pg_relation_size('test') > 131072 THEN
            EXIT;
        END IF;

        current_id = current_id + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-- Запустить функцию
SELECT insert_data();


