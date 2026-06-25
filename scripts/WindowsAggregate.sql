----------COUNT---------
SELECT
    o.orderid,
    o.orderdate,
    p.product,
    o.customerid,
    COUNT(orderid) OVER() AS CountTotalOrders,
    COUNT(orderid) OVER(PARTITION BY customerid) AS CountOrdersforCustm,
    COUNT(orderid) OVER(PARTITION BY product) AS CountOrderProd
FROM sales.orders AS o
LEFT JOIN sales.products AS p
ON o.productid= p.productid
;
--------------------------------
SELECT*,
    COUNT(customerid) OVER () AS TotalNumberCustomer,
    COUNT(score) OVER() AS ToltalScore
    FROM sales.customers;
-------------------------------------------------
SELECT
    orderid,
    COUNT(*) OVER(PARTITION BY orderid) AS ChekOrder
FROM sales.orders;
----------------------SUBQUERY------------------------
SELECT*
FROM(   SELECT
        orderid,
        COUNT(*) OVER(PARTITION BY orderid)AS CheckPK
        FROM sales.ordersarchive
)t WHERE CheckPK > 1;
----------------------------------------------------
SELECT
    orderid,
    orderdate,
    sales,
    productid,
    SUM(sales) OVER() AS SalesForOrders,
    SUM(sales) OVER(PARTITION BY productid) AS SalesForProducts
FROM sales.orders;
------------------------------------------------------
SELECT
    productid,
    sales,
    SUM(sales) OVER() TotalSales,
    ROUND((sales::numeric/(SUM(sales) OVER()))*100, 2) || '%' AS Contribucion
FROM sales.orders;
-----------------AVG----------------------------------
SELECT
    productid,
    orderdate,
    sales,
    AVG(sales) OVER()::float AvgSales,
    AVG(sales) OVER(PARTITION BY productid)::float AvgSalesProduct
FROM sales.orders;
---------------------------------------------------------
SELECT 
    customerid,
    COALESCE(lastname,'n/a') AS LastName,
    COALESCE(score,0) AS Score,
    AVG(COALESCE(score,0)) OVER()::float AS AvgScore
FROM sales.customers;
---------------------------------------------
SELECT*
 FROM   (SELECT
        orderid,
        sales,
        AVG(sales) OVER()::float AS AvgSales
    FROM sales.orders)t WHERE sales>AvgSales;
---------------MIN an MAX--------------------
SELECT
    orderid,
    orderdate,
    productid,
    sales,
    MAX(sales) OVER() MaxValue,
    MIN(sales) OVER() MinValue,
    MAX(sales) OVER(PARTITION BY productid) MaxValueProduct,
    MIN(sales) OVER(PARTITION BY productid) MINValueProduct
FROM sales.orders;
--------------------------------------------
  SELECT*
  FROM(  SELECT
            employeeid,
            COALESCE(firstname || ' ' || lastname, firstname, lastname, ' ') AS Fullname,
             gender,
             salary,
            MAX(salary) OVER(PARTITION BY gender) AS HighestSalary
    FROM sales.employees)t WHERE salary=HighestSalary;
--------------------------------------------------
SELECT
    orderid,
    productid,
    sales,
    MAX(sales) OVER() HighestSales,
    MIN(sales) OVER() LowestSales,
    (MAX(sales) OVER()) - sales AS HightDeviation,
    (sales-MIN(sales) OVER() ) AS LowDeviation
FROM sales.orders;
---------------------------------------------------
SELECT 
    orderid,
    orderdate,
    productid,
    sales,
    AVG(sales) OVER(PARTITION BY productid)::float AS AvgProduct,
    AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate)::float AS MovingAvg,
    AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate ROWS BETWEEN  CURRENT ROW AND 1 FOLLOWING )::float AS RollingAvg
FROM sales.orders;