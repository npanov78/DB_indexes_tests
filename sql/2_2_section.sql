drop table if exists section;
create table section(
    id int ,
    name int not null ,
    date timestamp not null ,
    action varchar not null
) partition by range (name);


create table section_part1 partition of section for values from (0) to (256);
create table section_part2 partition of section for values from (256) to (512);
create table section_part3 partition of section for values from (512) to (768);
create table section_part4 partition of section for values from (768) to (1024);
create table section_part5 partition of section for values from (1024) to (1280);
create table section_part6 partition of section for values from (1280) to (1536);
create table section_part7 partition of section for values from (1536) to (1792);
create table section_part8 partition of section for values from (1792) to (2048);

CREATE OR REPLACE FUNCTION insert_data()
RETURNS void AS $$
DECLARE
    current_id INTEGER := 1;
    max_id INTEGER := 1000000;
    table_size BIGINT;
    random_name INTEGER;
    random_action INTEGER;
    partition_number INTEGER;
BEGIN
    WHILE current_id <= max_id LOOP
        -- Генерация случайных значений для name и action
        random_name := floor(random() * 2048);
        random_action := floor(random() * 3);

        -- Определение номера раздела на основе значения name
        partition_number := 1 + floor(random_name / 256);

        -- Вставка данных в соответствующий раздел
        EXECUTE format('INSERT INTO section_part%s(id, name, date, action) VALUES (%s, %s, current_timestamp, %s)', partition_number, current_id, random_name, random_action);

        -- Обновление счетчика
        current_id = current_id + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-- Запустить функцию
SELECT insert_data();


CREATE OR REPLACE FUNCTION test_queries()
RETURNS void AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Запрос к секции 3
    RAISE NOTICE 'Запрос к секции 3...';
    start_time := clock_timestamp();
    PERFORM * FROM section where name = 513;
    end_time := clock_timestamp();
    RAISE NOTICE 'Время 3: %', end_time - start_time;

    -- Запрос к секции 6
    RAISE NOTICE 'Запрос к секции 6...';
    start_time := clock_timestamp();
    PERFORM * FROM section where name = 1282;
    end_time := clock_timestamp();
    RAISE NOTICE 'Время 6: %', end_time - start_time;

    -- Запрос к секциям 3 и 6
    RAISE NOTICE 'Запрос к секции 3 и 6...';
    start_time := clock_timestamp();
    PERFORM * FROM section where name = 513 Or name = 1282;
    end_time := clock_timestamp();
    RAISE NOTICE 'Время 3 и 6: %', end_time - start_time;
END;
$$ LANGUAGE plpgsql;
select test_queries();




