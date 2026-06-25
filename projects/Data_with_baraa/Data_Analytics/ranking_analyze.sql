--Which 5 products generate the highest revenue
select
p.product_name,
sum(f.sales_amount) as revenue_by_category,
rank() over(order by sum(f.sales_amount) DESC)
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
group by p.product_name
limit 5;
--What are the 5 woest performing products in terms of sales?
select
p.product_name,
sum(f.sales_amount) as revenue_by_category,
rank() over(order by sum(f.sales_amount) ASC)
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
group by p.product_name
limit 5;
--Find the top 10 customers who have generated the highest revenue
select
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenues,
row_number() over(order by sum(f.sales_amount) DESC) as rank
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key,c.first_name,c.last_name
limit 10;
--The 3 customers with the fewest orders placed
select
c.customer_key,
c.first_name,
c.last_name,
count(f.order_number) as total_orders,
row_number() over(order by count(f.order_number) ASC) as rank
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key,c.first_name,c.last_name
limit 3;
