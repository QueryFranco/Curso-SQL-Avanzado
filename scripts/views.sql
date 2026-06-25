---CREATE VIEW VIEW-NAME AS
--(
---SELECT ...
---FROM ...
---WHERE ...
---)
WITH TotalSalesMonth AS --CTE STRUCTURE--
 (SELECT
    EXTRACT(MONTH FROM orderdate) AS NumberMonth, 
    TO_CHAR(orderdate, 'Month') AS Month ,
    SUM(sales) TotalSales
 FROM sales.orders
 GROUP BY TO_CHAR(orderdate, 'Month'),  EXTRACT(Month FROM orderdate))
 SELECT
    NumberMonth,
    Month,
    TotalSales,
    SUM(TotalSales) OVER(ORDER BY NumberMonth ASC )
FROM TotalSalesMonth
---------- VIEW --------------
CREATE OR REPLACE VIEW Sales.RunningTotalSales AS
    (
        WITH TotalSalesMonth AS --CTE STRUCTURE--
 (SELECT
    EXTRACT(MONTH FROM orderdate) AS NumberMonth, 
    TO_CHAR(orderdate, 'Month') AS Month ,
    SUM(sales) TotalSales,
    COUNT(orderid) TotalOrders,
    SUM(quantity) TotalQuantity
 FROM sales.orders
 GROUP BY TO_CHAR(orderdate, 'Month'),  EXTRACT(Month FROM orderdate) )
 SELECT
    NumberMonth,
    Month,
    TotalSales,
    SUM(TotalSales) OVER(ORDER BY NumberMonth ASC ),
    TotalOrders,
    TotalQuantity
FROM TotalSalesMonth
    );
------------------------------------------
SELECT *
FROM Sales.RunningTotalSales
--------------------------------------------
CREATE OR REPLACE VIEW Sales.V_Orders_Details AS
(SELECT 
    o.orderid,
    p.product,
    p.category,
    p.price,
    COALESCE(c.firstname,' ') || ' '|| COALESCE(c.lastname, ' ') NamesCustomers,
    c.country CountryCustomers,
    c.score,
    COALESCE(e.firstname,' ') || ' ' || COALESCE(e.lastname, ' ') NamesEmployees,
    e.department,
    e.salary,
    e.managerid,
    o.orderdate,
    o.orderstatus,
    o.sales,
    o.quantity
FROM sales.orders o 
LEFT JOIN sales.products p 
ON o.productid=p.productid
LEFT JOIN sales.customers c 
ON o.customerid=c.customerid
LEFT JOIN sales.employees e 
ON o.salespersonid=e.employeeid);
-------------------------------------------
CREATE OR REPLACE VIEW sales.V_EU_TEAM_SALES AS
    (SELECT*
    FROM Sales.V_Orders_Details
    WHERE CountryCustomers != 'USA')
--------------------------------------------
SELECT*
FROM sales.V_EU_TEAM_SALES
 