select *
from bronze.crm_cust_info --> customers information, PK cust_id
limit 15;
--------------------------------------------------------------
select *
from bronze.crm_prd_info --> products information, PK prd_id
limit 15;
--------------------------------------------------------------
select *
from bronze.crm_sales_details --> sales details, PK sales_ord_num, FK cust_id, prd_key
limit 15;
----------------------------------------------------------------
----------------------- ERP ------------------------------------
----------------------------------------------------------------
select*
from bronze.erp_cust_az12 --> addiotional customers informacion, PK cid
limit 15;
--------------------------------------------------------------
select*
from bronze.erp_loc_a101 --> additional customers location information, PK cid
limit 15;
---------------------------------------------------------------
select*
from bronze.erp_px_cat_g1v2 --> additional product category information, PK id
limit 15;

select *
from bronze.crm_prd_info --> products information, PK prd_id
limit 15;