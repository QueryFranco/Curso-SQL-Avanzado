------STAND ALONE (Structure)---------
 ----WITH CTE-Name AS
 ----(SELECT ...
 -----FROM ...  <------- CTE Query
 -----WHERE)
----------------------------------------
-----SELECT ...
-----FROM CTE-Name  <-------- Main Query
-----WHERE ...
----------------------------------------
WITH CTE_Total_Sales AS
    (SELECT
        customerid,
        SUM(sales) AS TotalSales
    FROM sales.orders
    GROUP BY customerid
    ORDER BY TotalSales ASC)
-------Main Query---------
SELECT
c.customerid,
c.Firstname,
c.Lastname,
cts.TotalSales
FROM sales.customers AS c   
LEFT JOIN CTE_Total_Sales cts 
ON cts.customerid = c.customerid
-----------Multiple StandAlone CTEs--------
 ----WITH CTE-Name1 AS
 ----(SELECT ...
 -----FROM ...  <------- CTE Query
 -----WHERE)
  ---, CTE-Name2 AS
 ----(SELECT ...
 -----FROM ...  <------- CTE Query
 -----WHERE)
----------------------------------------
-----SELECT ...
-----FROM CTE-Name1
-----JOIN CTE-Name2  <-------- Main Query
-----WHERE ... 
WITH CTE_Total_Sales AS
    (SELECT
        customerid,
        SUM(sales) AS TotalSales
    FROM sales.orders
    GROUP BY customerid
    ORDER BY TotalSales ASC)
    , CTE_Last_Order AS
    (
        SELECT
        customerid,
        MAX(orderdate) LastOrder
        FROM sales.orders
        GROUP BY customerid
        ORDER BY customerid
    )
-------Main Query---------
SELECT
c.customerid,
c.Firstname,
c.Lastname,
cts.TotalSales,
ctes2.LastOrder
FROM sales.customers AS c   
LEFT JOIN CTE_Total_Sales cts 
ON cts.customerid = c.customerid
LEFT JOIN CTE_Last_Order as ctes2
ON ctes2.customerid=c.customerid;
--------Nested CTE---------------
 ----WITH CTE-Name1 AS
 ----(SELECT ...
 -----FROM ...  <------- Standalone CTE
 -----WHERE)
  ---, CTE-Name2 AS
 ----(SELECT ...
 -----FROM CTE-Name1 ...  <------- NESTED CTE
 -----WHERE)
----------------------------------------
-----SELECT ...
-----FROM CTE-Name2  <-------- Main Query
-----WHERE ... 
-----------------------------------------
WITH CTE_Total_Sales AS
    (SELECT
        customerid,
        SUM(sales) AS TotalSales
    FROM sales.orders
    GROUP BY customerid
    ORDER BY TotalSales ASC)
    , CTE_Last_Order AS
    (
        SELECT
        customerid,
        MAX(orderdate) LastOrder
        FROM sales.orders
        GROUP BY customerid
        ORDER BY customerid
    )
    , CTE_Rank_Sales AS
    (
        SELECT
                customerid,
                COALESCE(TotalSales,0) CleanTotalSales,
                RANK() OVER(ORDER BY TotalSales DESC) Rank 
        FROM CTE_Total_Sales

    )
    , CTE_Segmentation AS
    (SELECT
        customerid,
        CASE
            WHEN TotalSales > 100 THEN 'Highest'
            WHEN TotalSales > 80 THEN 'Medium'
            ELSE 'Lower'
        END Category 
        FROM CTE_Total_Sales
    )
-------Main Query---------
SELECT
c.customerid,
c.Firstname,
c.Lastname,
cts.TotalSales,
ctes2.LastOrder,
cts3.Rank,
cts4.Category
FROM sales.customers AS c   
LEFT JOIN CTE_Total_Sales cts 
ON cts.customerid = c.customerid
LEFT JOIN CTE_Last_Order as ctes2
ON ctes2.customerid=c.customerid
LEFT JOIN CTE_Rank_Sales cts3
ON cts3.customerid=c.customerid
LEFT JOIN CTE_Segmentation cts4
ON cts4.customerid=c.customerid
ORDER BY TotalSales DESC;
------Recursive CTE------------
 ----WITH CTE-Name AS
 ----(SELECT ...
 -----FROM ...     <------------ANCHOR Query (Only Once)
 -----WHERE
 -----UNION ALL---------
 -----SELECT ...  <--------------RECURSIVE Qurery (Loop)
 -----FROM CTE-Name
 -----WHERE [Break condition]
 -----)
 -----SELECT ...
-----FROM CTE-Name  <-------- Main Query
-----WHERE ... 
 ----------------------------------------
--- Generate a Sequence of Numbers from 1 to 20
WITH RECURSIVE CTE_Series AS (

    SELECT 
    1 AS MyNumber
    UNION ALL
    SELECT 
    MyNumber + 1 
    FROM CTE_Series
    WHERE MyNumber < 20
)
SELECT *
FROM CTE_Series;
--- Show the employee hierarchy by displaying each employee´s level within the organization
WITH RECURSIVE CTE_hierarchy AS
(
    SELECT 
        employeeid,
        Firstname,
        managerid,
        1 AS LEVEL 
    FROM sales.employees
    WHERE managerid IS NULL
    UNION ALL
    SELECT 
        e.employeeid,
        e.Firstname,
        e.managerid,
        LEVEL + 1
    FROM sales.employees AS e 
    INNER JOIN CTE_hierarchy AS cte 
    ON cte.employeeid=e.managerid
)
SELECT*
FROM CTE_hierarchy;
-----------------------------------------------
