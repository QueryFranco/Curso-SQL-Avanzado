-----CREATE/INSERT-----
-----CREATE TABLE Table-Name AS
-----(
----- ID INT,
----- Name VARCHAR(50)           
------)
----- INSERT INTO Table-Name
----- VALUES (1, 'Frank')
---------------------------------------------
---------CTAS-----------------------
----- CREATE TABLE Name AS 
-----(
----- SELECT ...
----- FROM   ...
----- WHERE  ...
------)
-----------------------------------------------
CREATE OR REPLACE TABLE Sales.Sales_OF_Month AS
    (SELECT
        EXTRACT(Month FROM orderdate) NumberMonth,
        TO_CHAR(orderdate, 'Month') Mes  ,
        SUM(sales) TotalSalesMonth
    FROM sales.orders 
    GROUP BY  EXTRACT(Month FROM orderdate),TO_CHAR(orderdate, 'Month')  
    ORDER BY EXTRACT(Month FROM orderdate) ASC);

SELECT*
FROM sales.Sales_OF_Month;

DROP TABLE sales.Sales_OF_Month;
---------------------------------------------
BEGIN;--
DROP TABLE IF EXISTS sales.Sales_OF_Month;

CREATE TABLE Sales.Sales_OF_Month AS
    (SELECT
        EXTRACT(Month FROM orderdate) NumberMonth,
        TO_CHAR(orderdate, 'Month') Mes  ,
        SUM(sales) TotalSalesMonth,
        COUNT(*) TotalOrders
    FROM sales.orders 
    GROUP BY  EXTRACT(Month FROM orderdate),TO_CHAR(orderdate, 'Month')  
    ORDER BY EXTRACT(Month FROM orderdate) ASC);
COMMIT;
------------Temp Table---------------
CREATE TEMP TABLE Temp_ORDERS_table AS
    (
        SELECT*
        FROM sales.orders
        WHERE orderstatus != 'Delivered'
    );

    SELECT*
    INTO Sales.OrdersTest
    FROM Temp_ORDERS_table;

SELECT *
FROM sales.OrdersTest