--PARTICIONES EN POSTGRESQL
ALTER TABLE sales.orders RENAME TO orders_old; ---RENOMBRAR
----------------------------------------------
CREATE TABLE sales.orders (LIKE sales.orders_old INCLUDING DEFAULTS INCLUDING CONSTRAINTS)---CREAR NUEVA TABLA CON LA MISMA ESTRUCTURA QUE LA ANTERIOR
PARTITION BY RANGE (orderdate);
-----------------------------------------------
CREATE TABLE sales.orders_2020 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01'); ---Particion para el año 2020
CREATE TABLE sales.orders_2021 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01'); ---Particion para el año 2021
CREATE TABLE sales.orders_2022 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01'); ---Particion para el año 2022
CREATE TABLE sales.orders_2023 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01'); ---Particion para el año 2023
CREATE TABLE sales.orders_2024 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01'); ---Particion para el año 2024 
CREATE TABLE sales.orders_2025 PARTITION OF sales.orders --CREAR PARTICION
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01'); ---Particion para el año 2025 
-----------------------------------------------
ALTER TABLE sales.orders ADD PRIMARY KEY (orderid, orderdate); ---AGREGAR CLAVE PRIMARIA
-------------------------------------------------
INSERT INTO sales.orders
SELECT * FROM sales.orders_old; ---INSERTAR LOS DATOS DE LA TABLA ANTIGUA A LA NUEVA
