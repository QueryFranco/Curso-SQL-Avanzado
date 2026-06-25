--Explore objects inn the Database
select*
from information_schema.tables;
--Explore columns in the Database
select*
from information_schema.columns
WHERE table_name='dim_customers'
order by ordinal_position;