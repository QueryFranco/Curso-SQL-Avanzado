SELECT*
INTO Sales.DBCustomers
FROM Sales.Customers;

SELECT *
FROM Sales.DBCustomers;

CREATE INDEX IX_DBCustomers_CustomerID
ON Sales.DBCustomers (CustomerID);

CLUSTER Sales.DBCustomers USING IX_DBCustomers_CustomerID;

CREATE INDEX IX_DBCustomers_FirstName
ON Sales.DBCustomers (FirstName);

CLUSTER Sales.DBCustomers USING IX_DBCustomers_FirstName; 

SELECT FirstName, LastName
FROM Sales.DBCustomers
WHERE FirstName = 'Anna';

CREATE INDEX IX_DBCustomers_FirstName_LastName1 
ON Sales.DBCustomers (FirstName, LastName);

SELECT *
FROM Sales.DBCustomers
WHERE country = 'USA' AND score > 500;

CREATE INDEX IX_DBCustomers_Country_Score
ON Sales.DBCustomers (Country, Score);

------SINTAXIS ROWSTORE INDEX
--- CREATE INDEX name_index
--- ON name_table (name_column);
--- CLUSTER name_table USING name_index;
------SINTAXIS NON-CLUSTERED COLUMNSTORE INDEX
--- CREATE COLUMNSTORE INDEX name_index 
--- ON name_table (name_column)
--- SINTAXIS CLUSTERED COLUMNSTORE INDEX
--- CREATE CLUSTERED COLUMNSTORE INDEX name_index
--- ON name_table 

--- SINTAXIS UNIQUE INDEX
--- CREATE UNIQUE INDEX name_index
--- ON name_table (name_column);

--FILTERED INDEX SINTAXIS
--- CREATE [UNIQUE] [NONCLUSTERED] INDEX name_index
--- ON name_table (name_column)
--- WHERE filter_condition;
--rules for filtered index
--- 1. You cannot create a filtered index on a clustered index.
--- 2. you cannot create a filtered index on a columstore index.
SELECT*
FROM sales.customers
WHERE country = 'USA' AND score > 500;

CREATE INDEX IX_salesCustomers_Country_Score_Filtered
ON sales.customers (Country, Score)
WHERE country = 'USA' AND score > 500;
--------------MONITOR INDEX USAGE--------
--CONCEPTOS:
--1. pg_class: Es el registro maestro de "objetos". Contiene los nombres de tablas, índices y vistas. Si tiene filas o columnas, está aquí.
--2. pg_index: Es el archivo técnico de los índices. No guarda nombres, guarda propiedades: ¿es único?, ¿a qué tabla pertenece?, ¿qué columnas usa (por número de posición)?
--3. pg_attribute: Es el diccionario de columnas. Guarda el nombre de cada columna, su tipo de dato y a qué tabla pertenece.
--4. pg_am: (Access Methods). Define el tipo de motor del índice. En SQL Server casi todo es B-Tree, pero en Postgres aquí verás si es btree, hash, gist o gin.
--5. pg_namespace: Es el registro de esquemas. En Postgres, las tablas viven dentro de esquemas (como public, sales o inventory). Esta tabla evita que te confundas si hay dos tablas llamadas igual en diferentes esquemas.
------------ INDICES TABLE CUSTOMERS
SELECT 
    i.relname AS indice_nombre,
    a.attname AS columna,
    ix.indisunique AS es_unico,
    ix.indisprimary AS es_pk
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
WHERE t.relname = 'customers';

-- Query para ver índices y su uso
SELECT
    tbl.relname AS table_name,
    idx.relname AS index_name,
    am.amname AS index_type,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary,
    s.idx_scan AS scans,
    s.idx_tup_read AS tuples_read,
    s.idx_tup_fetch AS tuples_fetched,
    pg_size_pretty(pg_relation_size(idx.oid)) AS index_size
FROM pg_stat_user_indexes s
JOIN pg_index ix ON s.indexrelid = ix.indexrelid
JOIN pg_class idx ON s.indexrelid = idx.oid
JOIN pg_class tbl ON s.relid = tbl.oid
JOIN pg_am am ON idx.relam = am.oid
ORDER BY scans DESC, table_name, index_name;

-----------DYNAMIC MANAGEMENT VIEWS - REAL-TIME DATABASE PERFORMANCE & SYSTEM HEALTH--------

-- 1. Table Size and Space Usage
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 2. Table Activity and Performance
SELECT
    schemaname,
    relname AS tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
ORDER BY seq_scan + idx_scan DESC;

-- 3. Cache Hit Ratio (Memory Performance)
SELECT
    schemaname,
    relname AS tablename,
    CASE WHEN (heap_blks_read + heap_blks_hit) = 0 THEN 0
         ELSE ROUND((heap_blks_hit::numeric / (heap_blks_hit + heap_blks_read)::numeric) * 100, 2)
    END AS heap_cache_hit_ratio,
    CASE WHEN (idx_blks_read + idx_blks_hit) = 0 THEN 0
         ELSE ROUND((idx_blks_hit::numeric / (idx_blks_hit + idx_blks_read)::numeric) * 100, 2)
    END AS index_cache_hit_ratio
FROM pg_statio_user_tables
ORDER BY schemaname, relname;

-- 4. Connection and Session Health
SELECT
    datname,
    usename,
    state,
    COUNT(*) AS session_count,
    MAX(query_start) AS last_query_start,
    MAX(state_change) AS last_state_change
FROM pg_stat_activity
WHERE datname IS NOT NULL
GROUP BY datname, usename, state
ORDER BY session_count DESC;

-- 5. Long Running Queries
SELECT
    pid,
    usename,
    datname,
    query,
    state,
    query_start,
    EXTRACT(EPOCH FROM (NOW() - query_start))::INT AS duration_seconds
FROM pg_stat_activity
WHERE state != 'idle'
    AND query_start < NOW() - INTERVAL '5 minutes'
ORDER BY query_start;

-- 6. Index Bloat and Maintenance
SELECT
    s.schemaname,
    s.relname AS tablename,
    s.indexrelname AS indexname,
    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch,
    pg_size_pretty(pg_relation_size(idx.oid)) AS index_size,
    CASE WHEN s.idx_scan = 0 THEN 'UNUSED' ELSE 'ACTIVE' END AS status
FROM pg_stat_user_indexes s
JOIN pg_class idx ON s.indexrelid = idx.oid
ORDER BY s.idx_scan ASC;
---------MONITOR INDEXES DUPLICATES------

-- 7. Duplicate Indexes
SELECT 
    t.relname AS TableName,      -- 1. Nombre de la tabla (desde pg_class t)
    a.attname AS IndexColumn,    -- 2. Nombre de la columna (desde pg_attribute a)
    i.relname AS IndexName,      -- 3. Nombre del índice (desde pg_class i)
    am.amname AS IndexType,      -- 4. Tipo de índice (btree, gin, etc.)
    COUNT(*) OVER(PARTITION BY t.relname, a.attname) AS DuplicateCount -- 5. Contamos cuántas veces se repite esta combinación de tabla+columna
FROM pg_index ix                 -- 5. Empezamos en la tabla técnica de índices
JOIN pg_class t ON t.oid = ix.indrelid  -- 6. Unimos para saber a qué TABLA pertenece
JOIN pg_class i ON i.oid = ix.indexrelid -- 7. Unimos para saber cómo se llama el ÍNDICE
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey) -- 8. Traducimos posición a nombre de COLUMNA
JOIN pg_am am ON i.relam = am.oid        -- 9. Obtenemos el método de acceso (Tipo)
JOIN pg_namespace n ON n.oid = t.relnamespace -- 10. Traemos el esquema para filtrar
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') -- 11. Ignoramos lo que es de Postgres
ORDER BY DuplicateCount DESC

--------UPDATE STATISTICS-----------

SELECT 
    schemaname AS schemaname,
    relname AS tablename,
    'auto_stats' AS statisticname, -- En Postgres las estadísticas son automáticas
    last_analyze AS lastupdate,
    ROUND(EXTRACT(DAY FROM (NOW() - last_analyze))) AS lastupdateday,
    n_live_tup AS rows,
    n_mod_since_analyze AS modificationssincelastupdate
FROM pg_stat_user_tables
WHERE last_analyze IS NOT NULL
ORDER BY n_mod_since_analyze DESC;


ANALYZE sales.customers;
ANALYZE sales.dbcustomers; 
VACUUM ANALYZE;

----FRAGMENTATION------
VACUUM FULL --Solution

---------EXCECUTION PLAN------
EXPLAIN SELECT* --prediccióm del plan de ejecución
FROM sales.customers
WHERE country = 'USA' AND score > 500;
EXPLAIN ANALYZE SELECT* --ejecución real del plan de ejecución
FROM sales.customers
WHERE country = 'USA' AND score > 500;

CREATE INDEX idx_customers_country_score ON sales.customers (country, score);

SET enable_seqscan = off; --obligar al motor a usar índices
EXPLAIN ANALYZE SELECT * FROM sales.customers WHERE score > 500 AND country = 'USA';

---NESTED LOOPS:
SET enable_seqscan = off;
SET enable_hashjoin = off;
SET enable_mergejoin = off;
EXPLAIN ANALYZE
SELECT d.customerid, c.firstname, d.score
FROM sales.dbcustomers d
JOIN sales.customers c ON c.customerid = d.customerid;

--MERGE JOIN:
SET enable_hashjoin = off;
EXPLAIN ANALYZE
SELECT c.customerid, c.firstname, d.score
FROM sales.dbcustomers d
JOIN sales.customers c ON c.customerid = d.customerid;

--HASH JOIN:
EXPLAIN ANALYZE
SELECT c.customerid, c.firstname, d.score
FROM sales.dbcustomers d
JOIN sales.customers c ON c.customerid = d.customerid;

------SQL HINTS------
SET enable_seqscan = off;
SET enable_hashjoin = off;
SET enable_mergejoin = off;
SET LOCAL enable_memoize = off;
EXPLAIN ANALYZE
SELECT
    o.sales,
    c.country
FROM sales.orders o
LEFT JOIN sales.customers c ON o.customerid = c.customerid;

------FRAGMENTACIÓN------
SELECT
    s.schemaname AS esquema,
    s.relname AS tabla,
    s.indexrelname AS indice,
    ROUND(100 * (1 - (sub.estimated_pages::float / COALESCE(NULLIF(pg_relation_size(i.indexrelid) / 8192, 0), 1)))::numeric, 2) AS bloat_ratio_percent,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch,
    CASE 
        WHEN ROUND(100 * (1 - (sub.estimated_pages::float / COALESCE(NULLIF(pg_relation_size(i.indexrelid) / 8192, 0), 1)))::numeric, 2) > 30 THEN 'HIGH BLOAT - REINDEX'
        WHEN ROUND(100 * (1 - (sub.estimated_pages::float / COALESCE(NULLIF(pg_relation_size(i.indexrelid) / 8192, 0), 1)))::numeric, 2) > 15 THEN 'MODERATE BLOAT'
        ELSE 'HEALTHY'
    END AS bloat_status
FROM pg_index i
JOIN pg_stat_user_indexes s ON i.indexrelid = s.indexrelid
JOIN (
    -- Subconsulta corregida usando la vista oficial pg_stats
    SELECT 
        c.oid AS indrelid,
        CEIL((c.reltuples * (SUM(st.avg_width) + 4) + 24) / 8192) AS estimated_pages
    FROM pg_class c
    JOIN pg_stats st ON c.relname = st.tablename AND c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = st.schemaname)
    WHERE c.relkind = 'r'
    GROUP BY c.oid, c.reltuples
) sub ON sub.indrelid = i.indrelid
WHERE 
    ROUND(100 * (1 - (sub.estimated_pages::float / COALESCE(NULLIF(pg_relation_size(i.indexrelid) / 8192, 0), 1)))::numeric, 2) BETWEEN 0 AND 100
    -- FILTRO EXPERTO: Ignora índices minúsculos que midan menos de 5 bloques (40 KB)
    AND pg_relation_size(i.indexrelid) > 40960 
ORDER BY bloat_ratio_percent DESC;