 SELECT orderdate,
    NOW() Today
 FROM sales.orders;
------DATEPART and EXTRACT----------
SELECT 
    creationtime,
    --DATENAME(month,creationtime)AS "Month",
    --DATE_PART('year', creationtime) AS "Year",
    EXTRACT(YEAR FROM creationtime) AS Year2,
    EXTRACT(MONTH FROM creationtime)AS month,
    EXTRACT(DAY FROM creationtime)AS Day,
    EXTRACT(HOUR FROM creationtime)AS Hour,
    EXTRACT(QUARTER FROM creationtime)AS Quarter,
    EXTRACT(WEEK FROM creationtime)AS WEEK
FROM sales.orders; 
------TO_CHAR---------
SELECT 
    orderid,
    creationtime,
    TO_CHAR(creationtime, 'month')AS "Month",
    TO_CHAR(creationtime, 'day')AS "Weekday",
    TO_CHAR(creationtime, 'YYYY') AS "Year"
FROM sales.orders;
-------DATE TRUNC----------
SELECT
    orderid,
    creationtime, 
    DATE_TRUNC('minute',creationtime)AS Minute_dt,
    DATE_TRUNC('hour',creationtime)AS hour_dt,
    DATE_TRUNC('day',creationtime)AS day_dt,
    DATE_TRUNC('year',creationtime)AS year_dt
FROM sales.orders;

SELECT
    DATE_TRUNC('month',creationtime),
    COUNT(DATE_TRUNC('month',creationtime))
FROM sales.orders
GROUP BY DATE_TRUNC('month',creationtime)
ORDER BY DATE_TRUNC('month',creationtime) ASC
;
------EOMONTH PostgreSQL-----
SELECT
    creationtime,
   ( DATE_TRUNC('month',creationtime) + INTERVAL '1 month - 1 day')::date AS last_day_month
FROM sales.orders;
-------DATE AGREGATIONS------
SELECT
  ( DATE_TRUNC('year',creationtime))::Date AS Year,
   COUNT(*) AS orders_for_Year
FROM sales.orders
GROUP BY  DATE_TRUNC('year',creationtime);
----------------------------------------------------
SELECT
  ( DATE_TRUNC('month',creationtime))::Date AS Month,
  TO_CHAR(creationtime, 'month')AS "Month",
   COUNT(*) AS orders_for_Year
FROM sales.orders
GROUP BY  DATE_TRUNC('month',creationtime),TO_CHAR(creationtime, 'month');
--------------------------------------------------------------
SELECT
    ( DATE_TRUNC('month',creationtime))::Date AS Month,
    TO_CHAR(creationtime, 'month')AS "Month",
   COUNT(*) AS orders_for_Month
FROM sales.orders
WHERE EXTRACT(MONTH FROM creationtime)=2
GROUP BY  DATE_TRUNC('month',creationtime),TO_CHAR(creationtime, 'month');
