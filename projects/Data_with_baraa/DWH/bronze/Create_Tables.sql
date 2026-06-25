DROP TABLE IF EXISTS bronze.crm_cust_info CASCADE;
CREATE TABLE bronze.crm_cust_info (
        cst_id INT ,
        cst_key VARCHAR(50),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_marital_status VARCHAR(20),
        cst_gnder VARCHAR(10),
        cst_create_date DATE
);
DROP TABLE IF EXISTS bronze.crm_prd_info CASCADE;
CREATE TABLE bronze.crm_prd_info(
    prd_id INT PRIMARY KEY,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE
);
DROP TABLE IF EXISTS bronze.crm_sales_details CASCADE;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_ord_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
DROP TABLE IF EXISTS bronze.erp_cust_az12 CASCADE;
CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(20)
);

-- Tabla para LOC_A101.csv
DROP TABLE IF EXISTS bronze.erp_loc_a101 CASCADE;
CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(100)
);

-- Tabla para PX_CAT_G1V2.csv
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2 CASCADE;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(100),
    subcat VARCHAR(100),
    maintenance VARCHAR(10)
);