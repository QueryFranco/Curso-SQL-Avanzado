SELECT
    orderid,
    sales,
    SUM(sales) OVER() AS TotalSales
FROM sales.orders
ORDER BY sales ASC;
-----------------------------------------------
SELECT
    p.productid,
    p.product,
    p.category,
    p.price,
    COALESCE(o.quantity,0) AS "Clean Quantity",
    COALESCE(o.sales,0) AS "Clean Sales",
    SUM(COALESCE(o.sales,0)) OVER (PARTITION BY product)AS TotalSalesForProd,
    COUNT(COALESCE(o.sales,0)) OVER (PARTITION BY product) AS "Total Count"
FROM sales.products AS p
LEFT JOIN sales.orders AS o 
ON p.productid = o.productid
 ORDER BY p.productid ASC;
-----------PARTITION BY--------------------
SELECT 
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER() AS TotalSalesOrders
FROM sales.orders ;
------------------------------------------
SELECT 
    productid,
    orderid,
    orderdate,
    SUM(sales) OVER() AS TotalSales,
    SUM(sales) OVER(PARTITION BY productid ) AS TotalSalesProduct
FROM sales.orders 
ORDER BY productid ASC;
---------------------------------------------
SELECT
    productid,
    orderstatus,
    sales,
    SUM(sales) OVER(PARTITION BY productid, orderstatus) AS SalesByProductsAndStatus
FROM sales.orders;
----------------------------------------------
SELECT
    orderid,
    orderdate,
    sales,
    RANK() OVER(ORDER BY sales DESC) AS RankSales
FROM sales.orders;
-------------------------------------------------
SELECT
    orderid,
    orderdate,
    orderstatus,
    sales,
    SUM(sales) OVER(PARTITION BY orderstatus ORDER BY orderdate
    ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS TotalSales,
    SUM(sales) OVER(PARTITION BY orderstatus ORDER BY orderdate
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS TotalSales2
FROM sales.orders;
--------------------------------------------------
SELECT
    productid,
    orderstatus,
    SUM(sales) OVER(PARTITION BY orderstatus ) AS TotalSales
FROM sales.orders
WHERE productid IN(101,102);
-------------------------------------------------
SELECT
    customerid,
    SUM(sales) AS TotalSales,
    RANK() OVER(ORDER BY  SUM(sales) DESC ) AS RankSales
FROM sales.orders
GROUP BY customerid;
