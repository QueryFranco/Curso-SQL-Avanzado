 --Explore all countries our customers come from
 select distinct country
 FROM gold.dim_customers;
 --Explore all Product Categories 'The Major Divisions'
 select distinct category,subcategory, product_name
 from gold.dim_products
 order by category; 