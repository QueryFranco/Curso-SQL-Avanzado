/*
===============================================================================
Procedimiento de Carga de Datos en la Capa Bronze (Carga Inicial)
===============================================================================
Objetivo:
    Este script define el procedimiento almacenado 'bronze.load_bronze', el cual
    se encarga de truncar e importar los datos crudos desde archivos CSV hacia
    las tablas del esquema 'bronze'.

Modificaciones Realizadas:
    1. ROLLBACK inicial: limpia cualquier transaccion abortada (25P02) en la
       sesion actual antes de empezar a crear objetos.
    2. Cada COPY corre dentro de su propio bloque BEGIN/EXCEPTION/END
       (savepoint) para que un fallo en una tabla NO aborte la carga
       completa ni envenene la transaccion externa.
    3. Los fallos individuales se reportan con RAISE WARNING (visible en la
       pestana Messages de VSCode, a diferencia de NOTICE).
    4. CALL final: el archivo ahora es ejecutable de un solo click (crea el
       procedimiento y lo invoca inmediatamente).
===============================================================================
*/

-- 0. Recuperar la sesion si quedo envenenada por un error previo (25P02)
ROLLBACK;

-- 1. Crear / reemplazar el procedimiento
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Iniciando Carga de la Capa Bronze (Raw Data)';
    RAISE NOTICE '---------------------------------------------------------';

    -- =====================================================================
    -- SECCION: CARGA DE DATOS CRM
    -- =====================================================================

    v_start_time := clock_timestamp();
    BEGIN
        RAISE NOTICE '>> Cargando crm_cust_info...';
        TRUNCATE TABLE bronze.crm_cust_info;
        COPY bronze.crm_cust_info
        FROM '/tmp/datasets/source_crm/cust_info.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        TRUNCATE TABLE bronze.crm_prd_info;
        COPY bronze.crm_prd_info
        FROM '/tmp/datasets/source_crm/prd_info.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        TRUNCATE TABLE bronze.crm_sales_details;
        COPY bronze.crm_sales_details
        FROM '/tmp/datasets/source_crm/sales_details.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        TRUNCATE TABLE bronze.erp_cust_az12;
        COPY bronze.erp_cust_az12
        FROM '/tmp/datasets/source_erp/CUST_AZ12.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        TRUNCATE TABLE bronze.erp_loc_a101;
        COPY bronze.erp_loc_a101
        FROM '/tmp/datasets/source_erp/LOC_A101.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        COPY bronze.erp_px_cat_g1v2
        FROM '/tmp/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (FORMAT CSV, HEADER true, DELIMITER ',');
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
        -- Red de seguridad: si algo truena fuera de los BEGIN/EXCEPTION
        -- internos (declaraciones, NOTICEs, etc.) se reporta aqui.
        RAISE WARNING 'Error fatal en load_bronze: % (SQLSTATE %)',
                      SQLERRM, SQLSTATE;
END;
$$;

-- 2. Ejecutar el procedimiento inmediatamente
CALL bronze.load_bronze();
