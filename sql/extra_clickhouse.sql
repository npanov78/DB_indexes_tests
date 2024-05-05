drop table if exists indexes;
create table indexes (
    id UInt64,
    name UInt32,
    date datetime,
    action UInt8
) engine = MergeTree()
order by id;

insert into indexes (id, name, date, action)
select
    number AS id,
    rand64() % 1000000 + 1 AS name,
    now() AS date,
    rand64() % 3 + 1 AS action
from numbers(1000000);


select name from indexes where name = rand64() % 1000000 + 1 and action == rand64() % 3 + 1