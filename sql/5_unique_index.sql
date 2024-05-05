drop table if exists logs;
create table logs(
    num int,
    time_select double precision,
    time_insert double precision,
    time_update double precision
);

drop table if exists indexes;
create table indexes(
    id int ,
    name int not null ,
    date timestamp not null ,
    action varchar not null
);

CREATE OR REPLACE FUNCTION measure_operations()
RETURNS void AS $$
DECLARE
    i INT := 1;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    total_insert_time INTERVAL := '00:00:00';
    total_select_time INTERVAL := '00:00:00';
    total_update_time INTERVAL := '00:00:00';
    avg_insert_time INTERVAL;
    avg_select_time INTERVAL;
    avg_update_time INTERVAL;
BEGIN
    CREATE UNIQUE INDEX unique_index ON indexes(name, id);


    WHILE i <= 1000000 LOOP
        -- Генерация случайных значений для name и action
        PERFORM setseed(random());

        -- Вставка данных
        start_time := clock_timestamp();
        FOR j IN 1..1000 LOOP
            EXECUTE format('INSERT INTO indexes(id, name, date, action) VALUES (%s, floor(random()*1000000)+1, current_timestamp, floor(random()*3)+1)', i);
            i := i + 1;
        END LOOP;
        end_time := clock_timestamp();
        -- Замер времени вставки
        total_insert_time := end_time - start_time;


        -- Среднее время вставки
        avg_insert_time := total_insert_time / 10;

        -- 3 SELECT
        start_time := clock_timestamp();
        EXECUTE format('SELECT name FROM indexes WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        EXECUTE format('SELECT name FROM indexes WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        EXECUTE format('SELECT name FROM indexes WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        end_time := clock_timestamp();
        -- Замер времени SELECT
        total_select_time := end_time - start_time;

        -- 3 UPDATE
        start_time := clock_timestamp();
        EXECUTE format('UPDATE indexes SET action = floor(random()*3)+1 WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        EXECUTE format('UPDATE indexes SET action = floor(random()*3)+1 WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        EXECUTE format('UPDATE indexes SET action = floor(random()*3)+1 WHERE name = %s AND id = %s', floor(random()*1000000)+1, i);
        end_time := clock_timestamp();
        -- Замер времени UPDATE
        total_update_time := end_time - start_time;

        -- Среднее время SELECT и UPDATE
        avg_select_time := total_select_time / 3;
        avg_update_time := total_update_time / 3;

        -- Занесение времени SELECT и UPDATE в таблицу logs
        INSERT INTO logs(num, time_select, time_insert, time_update) VALUES (i, date_part('epoch', avg_select_time), date_part('epoch', avg_insert_time), date_part('epoch', avg_update_time));

    END LOOP;
END;
$$ LANGUAGE plpgsql;



select measure_operations()
