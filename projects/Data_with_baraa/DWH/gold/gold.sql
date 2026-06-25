-------------------------------------------------------------
------------------- CUSTOMERS -------------------------------
-------------------------------------------------------------
CREATE VIEW gold.dim_customers AS
SELECT
    row_number() over(order by ci.cst_id) as customer_key, --> surrogate key
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name, ---> CRM master table
    ci.cst_lastname as last_name,
    la.cntry as country,            ---> ERP second source
    ci.cst_marital_status as marital_status,
    case when ci.cst_gnder != 'n/a' then ci.cst_gnder
     else coalesce(ca.gen,'n/a') 
    end as gender,
    ca.bdate as birthdate,
    ci.cst_create_date as create_date
    from silver.crm_cust_info as ci  ---> data integration
    left join silver.erp_cust_az12 as ca
    on ci.cst_key = ca.cid
    LEFT join silver.erp_loc_a101 as la
    on ci.cst_key = la.cid;
    select *
--data integration
SELECT DISTINCT
ci.cst_gnder,
ca.gen,
case when ci.cst_gnder != 'n/a' then ci.cst_gnder
     else coalesce(ca.gen,'n/a') 
end as new_gender
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ci.cst_key = ca.cid
LEFT join silver.erp_loc_a101 as la
on ci.cst_key = la.cid;
--check the view create
select *
from gold.dim_customers;
--check the consistency and standaritazion
select distinct gender
from gold.dim_customers;
-------------------------------------------------------------
------------------- PRODUCTS --------------------------------
-------------------------------------------------------------
    create or replace VIEW gold.dim_products AS
    with cte_product_info AS
    (select 
        prd_id,
        prd_key,
        prd_nm,  
        cat_id,       --------> CRM Master Table
        prd_cost,
        prd_line,
        prd_start_dt
        from silver.crm_prd_info 
        where prd_end_dt is NULL)
    select 
           row_number() over(order by pn.prd_start_dt,pn.prd_key) as product_key,
           pn.prd_id as product_id,
           pn.prd_key as product_number,
           pn.prd_nm as product_name, --------> CRM Master Table
           pn.cat_id as category_id,
           pc.cat as category,
           pc.subcat as subcategory, ----> ERP seconds sources
           pc.maintenance,
           pn.prd_line as product_line,
           pn.prd_cost as cost,
           pn.prd_start_dt as start_date
    from cte_product_info as pn
    left join silver.erp_px_cat_g1v2 pc
    on pn.cat_id = pc.id;
--check the view create
select*
from gold.dim_products;
-------------------------------------------------------------
------------------- SALES -----------------------------------
-------------------------------------------------------------
create view gold.fact_sales AS
SELECT
s.sls_ord_num as order_number,
p.product_key ,
c.customer_key,
s.sls_ord_dt as order_date,
s.sls_ship_dt as shipping_date,
s.sls_due_dt as due_date,
s.sls_sales as sales_amount,
s.sls_quantity as quantity,
s.sls_price as price
FROM silver.crm_sales_details as s
left JOIN gold.dim_customers as c 
ON s.sls_cust_id = c.customer_id
left join gold.dim_products as p
ON s.sls_prd_key = p.product_number;
--check the view create
select*
from gold.fact_sales;
--Check if all dimension tables can successfully join to the fact table
SELECT*
from gold.fact_sales s
left join gold.dim_customers c
ON s.customer_key = c.customer_key
left join gold.dim_products p
ON s.product_key = p.product_key
where s.customer_key is null or s.product_key is null;