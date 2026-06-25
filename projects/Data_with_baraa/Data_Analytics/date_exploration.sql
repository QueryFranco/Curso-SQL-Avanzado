--Find the date of the first and last order
select 
min(order_date) as first_order,
max(order_date) as last_order
from gold.fact_sales;
--Timespan of the order_date
select 
extract(year from max(order_date))-extract(year from min(order_date)) as timespan
from gold.fact_sales;
--Customer must younger and older
SELECT
extract(year from now())-extract(year from max(birthdate)) as customer_younger,
extract(year from now())-extract(year from min(birthdate)) as customer_older
from gold.dim_customers;