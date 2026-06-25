---------------------------------------------------------------------
------------------- CRM_CUST_INFO -----------------------------------
---------------------------------------------------------------------
--Detectec replicated and null PK table in bronze.crm_cust_info
select *
from (
    select 
    cst_id,
    row_number() over(partition by cst_id order by cst_create_date desc) as last_flag,
    cst_create_date
    from bronze.crm_cust_info
)
where last_flag != 1;
--table with cust_id no replicated and null values
select *
from (
    select 
    cst_id,
    row_number() over(partition by cst_id order by cst_create_date desc) as last_flag,
    cst_create_date
    from bronze.crm_cust_info
)
where last_flag =1;
-------- check for unwanted spaces
select cst_firstname, cst_lastname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname) or cst_lastname != trim(cst_lastname);

------ cleaning unwated spaces
select
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
cst_marital_status,
cst_gnder,
cst_create_date
from bronze.crm_cust_info;
----- replace the abreviation terms.
select 
cst_gnder,
cst_marital_status,
case 
    when UPPER(TRIM(cst_gnder)) = 'M' then 'Male'
    when UPPER(TRIM(cst_gnder)) = 'F' then 'Female'
    else 'n/a'
end as cst_gnder,
case 
    when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
    when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
    else 'n/a'
end as cst_marital_status
from bronze.crm_cust_info;
------------------------------------------------------------------------
------------------------- CRM_PRD_INFO ---------------------------------
------------------------------------------------------------------------
--#1: check duplicates PK
--expect result = 0 rows
select 
    prd_id,
    count(*) check_unique_pk
from bronze.crm_prd_info
group by prd_id
having count(*) > 1;
--#2: substring 
-- filters out unmatched data after applying transformation
select distinct
    prd_key,
    replace(substring(prd_key,1,5), '-', '_') as cat_id,
    substring(prd_key,7) as prd_key
from bronze.crm_prd_info
where substring(prd_key,7) not in (select distinct sls_prd_key from bronze.crm_sales_details);
--#3: check for unwanted spaces
--expect result = 0 rows
select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm); 
--#4: check for nulls or negative numbers
-- expect result = 0 rows
select coalesce(prd_cost ,0) as prd_cost
from bronze.crm_prd_info
where prd_cost is null or prd_cost < 0;
--#5: replace the abreviation terms.
select distinct 
prd_nm,
case UPPER(TRIM(prd_line))
    when  'M' then 'Mountain'
    when  'R' then 'Road'
    when  'T' then 'Touring'
    when  'S' then 'other sales'
    else 'n/a'
end
from bronze.crm_prd_info;
--check for invalid date orders
--expect result = 0 rows
    select *
  from(  select 
        prd_key, 
        prd_start_dt, 
        lead(prd_start_dt) over (partition by prd_key order by prd_start_dt ASC) - 1 as prd_end_dt
    from bronze.crm_prd_info
  )
  where prd_end_dt < prd_start_dt;
------------------------------------------------------------------------
------------------------- CRM_sales_details ----------------------------
------------------------------------------------------------------------
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE when sls_ord_dt = 0 or length (sls_ord_dt::varchar) != 8 then NULL
    else cast(cast(sls_ord_dt as VARCHAR) as date)
END as sls_order_dt,
CASE when sls_ship_dt = 0 or length (sls_ship_dt::varchar) != 8 then NULL
    else cast(cast(sls_ship_dt as VARCHAR) as date)
END as sls_ship_dt,
CASE when sls_due_dt = 0 or length (sls_due_dt::varchar) != 8 then NULL
    else cast(cast(sls_due_dt as VARCHAR) as date)
END as sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_ord_dt <= 0 or length(sls_ord_dt::varchar) != 8
where sls_cust_id not in (select cst_id from silver.crm_cust_info);
--check for invalid dates
select 
nullif (sls_ord_dt,0) as sls_order_dt
from bronze.crm_sales_details
where sls_ord_dt <= 0 
or length(sls_ord_dt::varchar) != 8
or sls_ord_dt > 20500101
or sls_ord_dt < 19000101;
select 
nullif (sls_ship_dt,0) as sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0 
or length(sls_ship_dt::varchar) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101;
select 
nullif (sls_due_dt,0) as sls_due_dt
from bronze.crm_sales_details
where sls_due_dt <= 0 
or length(sls_due_dt::varchar) != 8
or sls_due_dt > 20500101
or sls_due_dt < 19000101
-- order date must always be earlier than the shipping date or due date
--expect result = 0  rows
select 
sls_ord_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where sls_ord_dt > sls_ship_dt or sls_ord_dt > sls_due_dt
--unwated spaces
--expect result = 0 rows
select 
sls_ord_num,
sls_prd_key
from bronze.crm_sales_details
where sls_ord_num != trim(sls_ord_num) or sls_prd_key != trim(sls_prd_key)
--business rules
--sales = quantity * price
--negative, nulls and  sales != quantity * price values not allowed
select 
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity*abs(sls_price) 
    then sls_quantity*abs(sls_price)
    else sls_sales
end sls_sales,
sls_quantity,
case when sls_price is null or sls_price <= 0 then sls_sales/nullif(sls_quantity,0)
    else sls_price
end as sls_price
from bronze.crm_sales_details
where
    (sls_sales != sls_quantity * sls_price
    or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
    or sls_sales is null or sls_quantity is null or sls_price is null)
--all table
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE when sls_ord_dt = 0 or length (sls_ord_dt::varchar) != 8 then NULL
    else cast(cast(sls_ord_dt as VARCHAR) as date)
END as sls_order_dt,
CASE when sls_ship_dt = 0 or length (sls_ship_dt::varchar) != 8 then NULL
    else cast(cast(sls_ship_dt as VARCHAR) as date)
END as sls_ship_dt,
CASE when sls_due_dt = 0 or length (sls_due_dt::varchar) != 8 then NULL
    else cast(cast(sls_due_dt as VARCHAR) as date)
END as sls_due_dt,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity*abs(sls_price) 
    then sls_quantity*abs(sls_price)
    else sls_sales
end sls_sales,
sls_quantity,
case when sls_price is null or sls_price <= 0 then sls_sales/nullif(sls_quantity,0)
    else sls_price
end as sls_price
from bronze.crm_sales_details;
------------------------------------------------------------------------
------------------------- ERP_cust_az12 --------------------------------
------------------------------------------------------------------------
---consistency cid with cst_key from crm_cust_info
--expect result = 0 rows
SELECT
case when cid like '%NAS%' then substring(cid,4) 
    else cid
end as cid,
bdate,
gen
from bronze.erp_cust_az12
where case when cid like '%NAS%' then substring(cid,4) 
    else cid 
end not in (select distinct cst_key from silver.crm_cust_info);
--consistency dates
select 
bdate,
case when bdate < '1926-01-01' or bdate > "now"() then null
    else bdate
end as bdate
from bronze.erp_cust_az12
where bdate < '1926-01-01' or bdate > "now"();
--data standaritazion and consistency from gen
select distinct 
gen,
case 
    when UPPER(TRIM(gen)) in ('M','MALE') then 'Male'
    when UPPER(TRIM(gen)) in ('F', 'FEMALE') then 'Female'
    else 'n/a'
end as gen
from bronze.erp_cust_az12;
--all table transformation
select
case when cid like '%NAS%' then substring(cid,4) 
    else cid
end as cid,
case when bdate > "now"() then null
    else bdate
end as bdate,
case 
    when UPPER(TRIM(gen)) in ('M','MALE') then 'Male'
    when UPPER(TRIM(gen)) in ('F', 'FEMALE') then 'Female'
    else 'n/a'
end as gen
from bronze.erp_cust_az12;
------------------------------------------------------------------------
------------------------- ERP_loc_a101 ---------------------------------
------------------------------------------------------------------------
---consistency cid with cst_key from crm_cust_info
select
replace(cid,'-','') as cid,
cntry
from bronze.erp_loc_a101
where replace(cid,'-','') not in (select cst_key from silver.crm_cust_info);
--data standaritazion and consistency from cntry
select distinct
case 
    when UPPER(TRIM(cntry)) in ('AU', 'AUSTRALIA') then 'Australia'
    when UPPER(TRIM(cntry)) in ('US', 'USA' ,'UNITEDSTATES') then 'United States'
    when UPPER(TRIM(cntry)) in ('DE', 'GERMANY') then 'Germany'
    when UPPER(TRIM(cntry)) in ('CA', 'CANADA') then 'Canada'
    when UPPER(TRIM(cntry)) in ('FR','FRA','FRANCE') then 'France'
    when UPPER(TRIM(cntry)) in ('GB','UNITED KINGDOM') then 'United Kingdom'
    when UPPER(TRIM(cntry))= '' or cntry is null then 'n/a'
    else cntry
end as cntry
from bronze.erp_loc_a101
--all table
select
replace(cid,'-','') as cid,
case 
    when UPPER(TRIM(cntry)) in ('AU', 'AUSTRALIA') then 'Australia'
    when UPPER(TRIM(cntry)) in ('US', 'USA' ,'UNITEDSTATES') then 'United States'
    when UPPER(TRIM(cntry)) in ('DE', 'GERMANY') then 'Germany'
    when UPPER(TRIM(cntry)) in ('CA', 'CANADA') then 'Canada'
    when UPPER(TRIM(cntry)) in ('FR','FRA','FRANCE') then 'France'
    when UPPER(TRIM(cntry)) in ('GB','UNITED KINGDOM') then 'United Kingdom'
    when UPPER(TRIM(cntry))= '' or cntry is null then 'n/a'
    else cntry
end as cntry
from bronze.erp_loc_a101;
------------------------------------------------------------------------
------------------------- ERP_px_cat_g1v2 ------------------------------
------------------------------------------------------------------------
--check unwated spaces
select cat
from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);
--data standaritazion and consistency from cat, subcat and maintenance
select DISTINCT cat
from bronze.erp_px_cat_g1v2;
select DISTINCT subcat
from bronze.erp_px_cat_g1v2;
select DISTINCT maintenance
from bronze.erp_px_cat_g1v2;
---consistency id with prd_key from crm_prd_info
select 
id
from bronze.erp_px_cat_g1v2
where id not in (select distinct cat_id from silver.crm_prd_info);
