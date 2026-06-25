--#1: Select Only What Needed
-- Bad practice: Selecting all columns with *
SELECT * FROM employees;
-- Good practice: Selecting only necessary columns
SELECT employee_id, first_name, last_name FROM employees;
--------------------------------------------------------
--#2:Avoid unnecessary DISTINCT & ORDER BY
-- Bad practice: Using DISTINCT when not needed
SELECT DISTINCT department_id FROM employees;
-- Good practice: Only use DISTINCT when necessary
SELECT department_id FROM employees GROUP BY department_id;

-- Bad practice: Using ORDER BY when not needed
SELECT employee_id, first_name FROM employees ORDER BY employee_id;
-- Good practice: Only use ORDER BY when necessary
SELECT employee_id, first_name FROM employees;
--------------------------------------------------------
--#3: For Exploration Purpose, Limit Rows!
-- Bad practice: Retrieving all rows for exploration
SELECT 
    OrderID,
    Sales 
FROM sales.orders;
-- Good practice: Limiting rows for exploration
SELECT TOP 10
    OrderID,
    Sales
FROM sales.orders;
--------------------------------------------------------
--#4: Create nonclusteres Index on feequently used Columns in Where Clause
SELECT *
FROM sales.orders_old 
WHERE orderstatus = 'Delivered';
-- Create nonclustered index on orderstatus column
CREATE INDEX idx_orderstatus_old ON sales.orders_old (orderstatus);
----------------------------------------------
--#5: Avoid using Functions on Columns in Where Clause
--Why?: Functions on columns can prevent the use of indexes, leading to slower query performance.
--Bad Practice
SELECT * FROM sales.orders 
WHERE YEAR(orderdate) = 2023;
--Good Practice
SELECT * FROM sales.orders
WHERE orderdate >= '2023-01-01' AND orderdate < '2024-01-01';
--#6: Avoid leading wildcars as they prevent index usage
--Bad Practice
SELECT * FROM sales.customers
WHERE lastname LIKE '%Gold%'
--Good Practice
SELECT * FROM sales.customers
WHERE lastname LIKE 'Gold%'
--# 7: USE IN instead of Multiple OR
SELECT *
FROM Sales.orders
WHERE customerid =1 OR customerid = 2 OR customerid = 3;
-- Good Practice
SELECT *
FROM Sales.orders
WHERE customerid IN (1, 2, 3);
-------------------------------------------------
--#8: Undestand The Speed of Joins & Use INNER JOIN when possible
--Best Performance: INNER JOIN
SELECT c.firstame, o.orderid FROM sales.customers c INNER JOIN sales.orders o ON c.customerid = o.customerid;
--Slightly Slower Performance
SELECT c.firstame, o.orderid FROM sales.customers c LEFT JOIN sales.orders o ON c.customerid = o.customerid;
SELECT c.firstame, o.orderid FROM sales.customers c RIGHT JOIN sales.orders o ON c.customerid = o.customerid;
--Worst Performance
SELECT c.firstame, o.orderid FROM sales.customers c FULL OUTER JOIN sales.orders o ON c.customerid = o.customerid;
--------------------------------------------------
--#9: Use Explicit Join (ANSI Join) Instead of Implicit Join (non-ANSI Join)
--Bad Practice 
SELECT o.orderid, c.firstname
FROM sales.orders o, sales.customers c
WHERE o.customerid = c.customerid;
--Good Practice
SELECT o.orderid, c.firstname
FROM sales.orders o
JOIN sales.customers c ON o.customerid = c.customerid;
--------------------------------------------------
--#10: Make sure to Index the columns used in the ON clause of Joins
SELECT c.firstname, o.orderid
FROM sales.orders o
INNER JOIN sales.customers c ON o.customerid = c.customerid;
-- Create index on customerid column in orders table
CREATE INDEX idx_customerid_orders ON sales.orders (customerid);
CREATE INDEX idx_customerid_customers ON sales.customers (customerid);
---------------------------------------------------
--#11: Filter Before Joining (Big Tables)
--Filter After Join (WHERE)
SELECT c.firstname, o.orderid
FROM sales.customers c
INNER JOIN sales.orders o ON c.customerid = o.customerid
WHERE c.country = 'USA';
--Filter During Join (ON)
SELECT c.firstname, o.orderid
FROM sales.customers c
INNER JOIN sales.orders o ON c.customerid = o.customerid AND c.country = 'USA';
--Filter Before Join (Subquery)
SELECT c.firstname, o.orderid
FROM sales.orders o
INNER JOIN (SELECT firstname, customerid FROM sales.customers WHERE country = 'USA') c 
ON o.customerid = c.customerid;
--Use CTE to Filter Before Join
WITH CTE_USA_Customers AS
    (SELECT customerid, firstname FROM sales.customers WHERE country = 'USA')
SELECT c.firstname, o.orderid
FROM CTE_USA_Customers c
INNER JOIN sales.orders o ON c.customerid = o.customerid;
--Try to isolate the pereparation step in a CTE or Subquery.
---------------------------------------------------------
--#12: Aggregate Before Joining (Big Tables)
--Grouping and Joining 
SELECT c.customerid, c.firstname, SUM(o.sales) AS TotalSales
FROM sales.customers c
INNER JOIN sales.orders o ON c.customerid = o.customerid
GROUP BY c.customerid, c.firstname;
--Pre-aggregated Subquery
SELECT c.customerid, c.firstname, o.TotalSales
FROM sales.customers c
INNER JOIN (SELECT customerid, SUM(sales) AS TotalSales FROM sales.orders GROUP BY customerid) o
ON c.customerid = o.customerid;
--Correlated Subquery (The Worst Performance
SELECT c.customerid, c.firstname,
(SELECT SUM(sales) FROM sales.orders o WHERE o.customerid = c.customerid) AS TotalSales
FROM sales.customers c;
----------------------------------------------
--#13: Use Union Instead of OR While Joining Multiple Tables 
--Bad Practice
SELECT o.orderid, c.firstname
FROM sales.customers c
INNER JOIN sales.orders o 
ON c.customerid = o.customerid
OR c.customerid = o.salespersonid;
--Good Practice
SELECT o.orderid, c.firstname
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customerid = o.customerid
UNION
SELECT o.orderid, c.firstname
FROM sales.customers c
INNER JOIN sales.orders o
ON c.customerid = o.salespersonid;
--------------------------------------------------
--#14: Check for Nested Loops AND USE SQL HINTS when necessary 
--------------------------------------------------
--#15: Use UNION ALL instead of UNION if duplicate are acceptable
--Bad Practice
SELECT customerid FROM sales.orders
UNION
SELECT customerid FROM sales.ordersarchive;
--Good Practice
SELECT customerid FROM sales.orders
UNION ALL
SELECT customerid FROM sales.ordersarchive;
---------------------------------------------------
--#16: Use UNION ALL + Distinct instead of using UNION if duplicates are not acceptable
--Bad Practice
SELECT customerid FROM sales.orders
UNION
SELECT customerid FROM sales.ordersarchive;
--Good Practice
SELECT DISTINCT customerid FROM (
    SELECT customerid FROM sales.orders
    UNION ALL
    SELECT customerid FROM sales.ordersarchive
) AS combined_customers;
---------------------------------------------------
--#17: Use Columstore Index for aggregations on Large Table
SELECT customerid, SUM(sales) AS TotalSales
FROM sales.orders
GROUP BY customerid;
-- Create columnstore index on sales.orders table (Server SQL and Azure SQL Database)
CREATE COLUMNSTORE INDEX idx_columnstore_orders ON sales.orders;
--#18: Pre-Aggregate Data and Store in a new table for reporting 
SELECT customerid, SUM(sales) AS TotalSales, EXTRACT(MONTH FROM orderdate) AS SalesMonth
INTO sales.monthly_sales
FROM sales.orders
GROUP BY customerid, EXTRACT(MONTH FROM orderdate);
-- Reporting Query
SELECT customerid, TotalSales, SalesMonth
FROM sales.monthly_sales;
--------------------------------------------------
--#19: 
--Best practice JOIN (If the performance equal to EXISTS)
SELECT o.orderid, o.sales
FROM sales.orders o
INNER JOIN sales.customers c ON o.customerid = c.customerid
WHERE c.country = 'USA';
--Best practice EXISTS (USE it for large tables)
SELECT o.orderid, o.sales
FROM sales.orders o
WHERE EXISTS (SELECT 1 FROM sales.customers c WHERE c.customerid = o.customerid AND c.country = 'USA');
--Worst practice IN (Avoid it for large tables)
SELECT o.orderid, o.sales
FROM sales.orders o
WHERE o.customerid IN (SELECT customerid FROM sales.customers WHERE country = 'USA');
--------------------------------------------------
--#20: Avoid redundantr Logic in your Query
--Bad Practice
SELECT employeeid, firstname, salary, 'Above average' AS status
FROM sales.employees
WHERE salary > (SELECT AVG(salary) FROM sales.employees)
UNION ALL
SELECT employeeid, firstname, salary, 'Below average' AS status
FROM sales.employees
WHERE salary < (SELECT AVG(salary) FROM sales.employees);
--Good Practice
SELECT employeeid, firstname, salary,
CASE 
    WHEN salary > (SELECT AVG(salary) FROM sales.employees) THEN 'Above average'
    WHEN salary < (SELECT AVG(salary) FROM sales.employees) THEN 'Below average'
    ELSE 'Average'
END AS status
FROM sales.employees
ORDER BY salary DESC;
---------------------------------------------------
-------------DDL Performance Tips------------------
--#21: Avoid Data types VARCHAR & TEXT and Using MAX
--*  TEXT is Worst than VARCHAR
-- Bad Practice
CREATE TABLE CustomerInfo (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(MAX),
    LastName TEXT,
    Country VARCHAR(100),
    Score VARCHAR(50),
    BirthDate VARCHAR(20),
    EmployeeID INT,
    CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES sales.Employees(EmployeeID)
);
-- Good Practice
ALTER TABLE CustomerInfo
    ALTER COLUMN FirstName TYPE VARCHAR(100),
    ALTER COLUMN LastName TYPE VARCHAR(100),
    ALTER COLUMN Score TYPE INT USING (NULLIF(Score, '')::INTEGER),
    ALTER COLUMN BirthDate TYPE DATE USING (NULLIF(BirthDate, '')::DATE);
--------------------------------------------------
--#22: USE the NOT NULL contraints where applicable
-- Bad Practice
CREATE TABLE ProductInfo (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2),
    Stock INT
);
-- Good Practice
ALTER TABLE ProductInfo
    ALTER COLUMN ProductName SET NOT NULL,
    ALTER COLUMN Price SET NOT NULL,
    ALTER COLUMN Stock SET NOT NULL;
--------------------------------------------------
--#23 Ensure your all tables have a Primary Key
-- Bad Practice
CREATE TABLE SalesData (
    SaleID INT,
    ProductID INT,
    CustomerID INT,
    SaleDate DATE,
    Amount DECIMAL(10, 2)
);
-- Good Practice
ALTER TABLE SalesData
    ADD CONSTRAINT PK_SalesData PRIMARY KEY (SaleID);
--------------------------------------------------
--#24: Created a non-clustered for Foreign Key that are used frequently 
-- Bad Practice
CREATE TABLE CustomerInfo (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(MAX),
    LastName TEXT,
    Country VARCHAR(100),
    Score VARCHAR(50),
    BirthDate VARCHAR(20),
    EmployeeID INT,
    CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES sales.Employees(EmployeeID)
);
-- Good Practice
CREATE INDEX idx_employeeid ON CustomerInfo (EmployeeID);
---------------------------------------------------
-----------INDEXING Performance Tips---------------
--#25: Avoid Over-Indexing
--#26: Drop unused Indexes
--#27: Update Statistics Weekly
--#28: Reorganize and Rebuild Indexes Weekly
--#29: Partitions Large tables (Facts) to improve performance, next apply columnstore index on the partitioned table.