----------COALESCE-------------
SELECT
    managerid,
    COALESCE(CAST(managerid AS VARCHAR),'Unknown')
FROM sales.employees
-------Find the avarege score for the customers-----
SELECT
    customerid,
    score,
    COALESCE(score,0),
    AVG(COALESCE(score,0)) OVER() AvgScores
FROM sales.customers;
---------------------------------
SELECT
    firstname,
    lastname,
    COALESCE(firstname || ' ' ||lastname, firstname || ' '|| 'Unknown',  'Unknown'||' '||lastname, 'Unknown') AS FullName,
    COALESCE(score,0) AS Score,
    COALESCE(score,0) + 10 AS NewScore
FROM sales.customers
-------------JOINS-----------------
SELECT
    customerid,
    score
FROM sales.customers
ORDER BY CASE WHEN score IS NULL THEN 1 ELSE 0 END , Score ASC;
----------NULLIF---------
SELECT
    orderid,
    sales,
   -- quantity,
    NULLIF(quantity,0) AS Quantity,
    (sales/NULLIF(quantity,0)) AS Price
FROM sales.orders;
----------IS NULL and IS NOT NULL--------------
SELECT 
    customerid,
    score
FROM sales.customers
WHERE score IS NOT NULL;
------------------------
SELECT
    c.customerid,
    c.firstname,
    c.lastname,
    c.country,
    c.score
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customerid = o.customerid
WHERE o.customerid IS NULL

--------------------------------
SELECT*
FROM sales.orders;

SELECT*
FROM sales.customers