SELECT 
    COUNT(customers) AS TotalCustomers
FROM sales.customers;
-----------------------------------------
 SELECT
    SUM(sales)AS "Total Sales"
    FROM sales.orders;
-------------------------------------------
SELECT
    orderid,
    sales,
    AVG(sales) OVER() AS AvgSales
FROM sales.orders;  
-------------------------------------------
SELECT
    customerid,
    score,
    MAX(score) OVER() AS HighestScore,
    MIN(score) OVER() AS LowestScore
FROM sales.customers;
----------------------------------------------
SELECT
    COUNT(id) AS "Total Clients",
    ROUND(AVG(score)) AS "Avg Score",
    MAX(score) AS "Highets Score",
    MIN(score) AS "Lowst Score"
FROM customers;