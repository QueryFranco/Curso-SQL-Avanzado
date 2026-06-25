--Find the total sales
SELECT
sum(sales_amount) as total_sales
from gold.fact_sales;
--Find how many items are sold
SELECT
sum(quantity) as total_items_sold
from gold.fact_sales;
--Find the avarege selling price
SELECT
round(avg(price),2) as avg_price
from gold.fact_sales;
--Find the total numbers of 'orders,products,customers'
select 
count( distinct order_number) as total_orders,
count(distinct product_key) as total_products,
count(distinct customer_key) as total_customers
from gold.fact_sales;
--find the total number of the customers that has place an order
select 
count(distinct customer_key)
from gold.fact_sales;
--Generate Reporte that shows all key metrics of the business
select 'Total_sales' as measure_name, sum(sales_amount) as measure_value
from gold.fact_sales
UNION ALL
select 'Total_items_sold' as measure_name, sum(quantity) as measure_value
from gold.fact_sales
union all
select 'avg_price' as measure_name, round(avg(price),2) as measure_value
from gold.fact_sales
union all 
select 'total_orders' as measure_name, count( distinct order_number) as measure_value
from gold.fact_sales
union all
select 'total_products' as measure_name, count(distinct product_key) as measure_value
from gold.fact_sales
union all
select 'total_customers' as measure_name, count(distinct customer_key) as measure_value
from gold.fact_sales;

