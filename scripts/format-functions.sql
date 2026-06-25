--------------FORMAT------------
SELECT 
    orderid,
(creationtime)::Date AS TimeDate,
    EXTRACT(YEAR FROM creationtime )AS Year,
    TO_CHAR(creationtime,'yyyy-Mon-dd')AS Year,
    TO_CHAR(creationtime,'dd-mm-yyyy')AS Year,
    EXTRACT(DAY FROM creationtime) AS dd,
    TO_CHAR(creationtime, 'dd') AS dd,
    TO_CHAR(creationtime, 'FMDY') AS dd,
    TO_CHAR(creationtime, 'FMday') AS dd,
    EXTRACT(MONTH FROM creationtime) AS Month,
    TO_CHAR(creationtime, 'mm') AS mm,
    TO_CHAR(creationtime, 'Mon') AS Month,
    TO_CHAR(creationtime, 'FMMONTH') AS Month
    FROM sales.orders;
    ----------TASK----------------
    SELECT
    orderid,
    creationtime,
    'Day '|| TO_CHAR(creationtime, 'Dy Mon') || ' Q' || EXTRACT(QUARTER FROM creationtime) || ' '||
    TO_CHAR(creationtime, 'yyyy HH12:MI:SS AM' ) AS CustomeFormat
FROM sales.orders;
--------------------------------------
SELECT 
    TO_CHAR(orderdate, 'Mon yy') AS OrderDate,
    COUNT(*)
FROM sales.orders
GROUP BY TO_CHAR(orderdate, 'Mon yy');
----------CONVERT--------
SELECT
    CAST('123' AS INT) AS "String to int CONVERT",
    '123'::INT AS "String to int CONVERT",
    '123',
    CAST('2025-08-20' AS DATE) AS "String to Date CONVERT",
    '2025-08-20'::DATE AS "String to Date CONVERT",
    CAST(creationtime AS DATE) AS "Datetime to Date CONVERT",
    creationtime::DATE AS "Datetime to Date CONVERT"
    FROM sales.orders;
------------------------------------------------
SELECT
    creationtime,
    CAST(creationtime AS TIMESTAMP) AS "Datetiem To Date Convert",
    CAST(creationtime AS TIMESTAMPTZ) AS "Datetiem To Date Convert",
    TO_CHAR(creationtime, 'dd-mm-yyyy')::VARCHAR
FROM sales.orders;
--------------DATEADD--------------------
SELECT
    orderid,
    orderdate,
    (orderdate + INTERVAL '2 years')::Date AS "Two Years ADD",
    (orderdate + INTERVAL '3 months')::Date AS "Three Months ADD",
    (orderdate + INTERVAL '-10 days')::Date AS "Ten Days Before"
    FROM sales.orders;
    ----------------------------------------------------
SELECT
    employeeid,
    birthdate,
    (EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM birthdate)) AS AGE
FROM sales.employees;
------------------------------------------------------------
SELECT
    orderid,
    orderdate,
    shipdate
    FROM sales.orders;

SELECT 
    EXTRACT(MONTH FROM orderdate) AS orderdate,
    (EXTRACT(DAY FROM shipdate) - EXTRACT(DAY FROM OrderDate)) AS "Shipping Duration"
FROM sales.orders;


SELECT 
    EXTRACT(MONTH FROM orderdate) AS orderdate,
    AVG(EXTRACT(DAY FROM shipdate) - EXTRACT(DAY FROM OrderDate)) AS AVGShip
FROM sales.orders
GROUP BY EXTRACT(MONTH FROM orderdate);
------------------------------------------------------
SELECT
    orderid,
    orderdate CurrentOrderDate,
    LAG(orderdate) OVER(ORDER BY orderdate) PreviusorderDate,
     orderdate- LAG(orderdate) OVER(ORDER BY orderdate) NRofDays
 FROM sales.orders; 
 ------------ISDATE-------------
 SELECT ISDATE('123')