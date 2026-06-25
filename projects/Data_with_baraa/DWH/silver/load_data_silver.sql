CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time        TIMESTAMP;
    v_global_start      TIMESTAMP;
    v_global_end        TIMESTAMP;
    v_total_failures    INT := 0;
BEGIN
    v_global_start := clock_timestamp();

    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE 'Iniciando Carga de la Capa Silver (Clean Data)';
    RAISE NOTICE '---------------------------------------------------------';

    -- =====================================================================
    -- SECCION: CARGA DE DATOS CRM
    -- =====================================================================

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando crm_cust_info...';
        
-- 1# insert into silver.crm_cust_info
truncate table silver.crm_cust_info;
insert into silver.crm_cust_info
select 
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gnder,
cst_create_date
from (
    select 
    cst_id,
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    case 
        when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
        when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
        else 'n/a'
    end as cst_marital_status,
        case 
        when UPPER(TRIM(cst_gnder)) = 'M' then 'Male'
        when UPPER(TRIM(cst_gnder)) = 'F' then 'Female'
        else 'n/a'
    end as cst_gnder,
    cst_create_date,
    row_number() over(partition by cst_id order by cst_create_date desc) as last_flag
    from bronze.crm_cust_info
)
where last_flag =1 and cst_id is not null;

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO crm_cust_info: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando crm_prd_info...';
        
-- 2# insert into silver.crm_prd_info
truncate table silver.crm_prd_info;
insert into silver.crm_prd_info
select
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from (
    select
    prd_id,
    replace(substring(prd_key,1,5), '-', '_') as cat_id,
    substring(prd_key,7) as prd_key,
    prd_nm,
    coalesce(prd_cost,0) as prd_cost,
    case UPPER(TRIM(prd_line))
    when  'M' then 'Mountain'
    when  'R' then 'Road'
    when  'T' then 'Touring'
    when  'S' then 'other sales'
    else 'n/a'
end as prd_line,
    prd_start_dt,
    lead(prd_start_dt) over (partition by prd_key order by prd_start_dt ASC) - 1 as prd_end_dt
    from bronze.crm_prd_info
);

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO crm_prd_info: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando crm_sales_details...';
        
------------------insert into silver.crm.sales_details----------------------
truncate table silver.crm_sales_details;
insert into silver.crm_sales_details
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_ord_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from(select
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE when sls_ord_dt = 0 or length (sls_ord_dt::varchar) != 8 then NULL
        else cast(cast(sls_ord_dt as VARCHAR) as date)
    END as sls_ord_dt,
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
    from bronze.crm_sales_details);

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO crm_sales_details: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    -- =====================================================================
    -- SECCION: CARGA DE DATOS ERP
    -- =====================================================================

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando erp_cust_az12...';
        
------------------insert into silver.erp_cust_az12----------------------
truncate table silver.erp_cust_az12;
insert into silver.erp_cust_az12 (cid,bdate,gen)
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

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO erp_cust_az12: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando erp_loc_a101...';
        
------------------insert into silver.erp_loc_a101----------------------
truncate table silver.erp_loc_a101;
insert into silver.erp_loc_a101 (cid,cntry)
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

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO erp_loc_a101: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando erp_px_cat_g1v2...';
        
------------------insert into silver.erp_px_cat_g1v2---------------------
truncate table silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
select
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2;

        RAISE NOTICE '   - Exito. Tiempo: %', (clock_timestamp() - v_start_time);
    EXCEPTION
        WHEN OTHERS THEN
            v_total_failures := v_total_failures + 1;
            RAISE WARNING '   - FALLO erp_px_cat_g1v2: % (SQLSTATE %)',
                          SQLERRM, SQLSTATE;
    END;

    v_global_end := clock_timestamp();
    RAISE NOTICE '---------------------------------------------------------';
    IF v_total_failures = 0 THEN
        RAISE NOTICE 'PROCESO FINALIZADO CON EXITO - Tablas cargadas: 6/6';
    ELSE
        RAISE WARNING 'PROCESO FINALIZADO CON ERRORES - Fallos: % de 6',
                      v_total_failures;
    END IF;
    RAISE NOTICE '>> Tiempo Total: %', (v_global_end - v_global_start);
    RAISE NOTICE '---------------------------------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error fatal en load_silver: % (SQLSTATE %)',
                      SQLERRM, SQLSTATE;
END;
$$;
call silver.load_silver();
--------------------------------------------------------
------ Validation Queries (Run manually after SP) ------
--------------------------------------------------------

-- ==========================================
-- silver.crm_cust_info Validations
-- ==========================================
-- check the inserted data
-- expect result = 0 rows
select 
    cst_id,
    count(*) check_unique_pk
from silver.crm_cust_info
group by cst_id
having count(*) > 1;

--check for unwanted spaces
--expect result = 0 rows
select cst_firstname, cst_lastname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname) or cst_lastname != trim(cst_lastname);

--check data standardization & consistency
select distinct cst_gnder, cst_marital_status
from silver.crm_cust_info;

-- check duplicates
--expect result = 0 rows
select*
from (
        select 
        cst_id,
        cst_create_date,
        row_number() over(partition by cst_id order by cst_create_date desc) as last_flag
        from silver.crm_cust_info)
where last_flag != 1;

-- ==========================================
-- silver.crm_prd_info Validations
-- ==========================================
-- check the inserted data
-- duplicates check
--expect result = 0 rows
select prd_id, count(*) check_unique_pk
from silver.crm_prd_info
group by prd_id
having count(*) > 1;

--check for unwanted spaces
--expect result = 0 rows
select 
cat_id, prd_key, prd_nm, prd_line
from silver.crm_prd_info
where cat_id != trim(cat_id) or prd_key != trim(prd_key) or prd_nm != trim(prd_nm) or prd_line != trim(prd_line);

--check for nulls or negative numbers
-- expect result = 0 rows
select prd_cost
from silver.crm_prd_info
where prd_cost is null or prd_cost < 0;

--check data standardization & consistency
select distinct prd_line
from silver.crm_prd_info;

--check for invalid date orders
--expect result = 0 rows
select prd_key, prd_start_dt, prd_end_dt
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;

-- ==========================================
-- silver.crm_sales_details Validations
-- ==========================================
--unwated spaces
--expect result = 0 rows
select 
sls_ord_num,
sls_prd_key,
sls_cust_id
from silver.crm_sales_details
where sls_ord_num::varchar != trim(sls_ord_num::varchar) 
    or sls_prd_key::varchar != trim(sls_prd_key::varchar) 
    or sls_cust_id::varchar != trim(sls_cust_id::varchar);

--consistency in dates
--expect result = 0 rows
select 
sls_ord_dt,
sls_ship_dt,
sls_due_dt
from silver.crm_sales_details
where sls_ord_dt > sls_ship_dt or sls_ord_dt > sls_due_dt;

--businees rules
--sales = quantity * price
--negative, nulls and  sales != quantity * price values not allowed
--expect result = 0 rows
select
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales is null or sls_quantity is null or sls_price is NULL
        or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
        or sls_sales != sls_quantity*sls_price;

-- ==========================================
-- silver.erp_cust_az12 Validations
-- ==========================================
---consistency cid with cst_key from crm_cust_info
--expect result = 0 rows
select cid
from silver.erp_cust_az12
where cid not in (select cst_key from silver.crm_cust_info);

--consistency dates
--expect result = 0 rows
select bdate
from silver.erp_cust_az12
where bdate > "now"();

--data standaritazion and consistency from gen
select distinct gen
from silver.erp_cust_az12;

--all table
select*
from silver.erp_cust_az12;

-- ==========================================
-- silver.erp_loc_a101 Validations
-- ==========================================
---consistency cid with cst_key from crm_cust_info
--expect result = 0 rows
select
cid
from silver.erp_loc_a101
where cid not in (select cst_key from silver.crm_cust_info);

--data standaritazion and consistency from cntry
select distinct
cntry
from silver.erp_loc_a101;

-- ==========================================
-- silver.erp_px_cat_g1v2 Validations
-- ==========================================
select*
from silver.erp_px_cat_g1v2;
