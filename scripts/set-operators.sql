SELECT 
    firstname,
    lastname
    FROM sales.customers
UNION
    SELECT 
    firstname,
    lastname
    FROM sales.employees;
    ----TASK----
    SELECT --customerid,
        firstname,
        lastname
    FROM sales.customers
UNION
    SELECT --employeeid,
    firstname,
    lastname
    FROM sales.employees 
ORDER BY firstname ASC;
----UNION ALL------
SELECT 
    firstname,
    lastname
FROM sales.employees
UNION ALL
SELECT 
    firstname,
    lastname
FROM sales.customers
ORDER BY firstname ASC
;
----EXCEPT----
SELECT 
    firstname,
    lastname
FROM sales.customers
EXCEPT
SELECT 
    firstname,
    lastname
FROM sales.employees
ORDER BY firstname ASC;
----INTERSECT------
SELECT 
    firstname,
    lastname
FROM sales.customers
INTERSECT
SELECT 
    firstname,
    lastname
FROM sales.employees
ORDER BY firstname ASC;
------COMBINE INFORMATION----
SELECT
    'Orders' AS SourceTable,
    "orderid", 
    "productid", 
    "customerid", 
    "salespersonid", 
    "orderdate", 
    "shipdate", 
    "orderstatus", 
    "shipaddress", 
    "billaddress", 
    "quantity", 
    "sales", 
    "creationtime"
FROM sales.ordersarchive
UNION
SELECT
    'OrdersArchive' AS SourceTable,
    "orderid", 
    "productid", 
    "customerid", 
    "salespersonid", 
    "orderdate", 
    "shipdate", 
    "orderstatus", 
    "shipaddress", 
    "billaddress", 
    "quantity", 
    "sales", 
    "creationtime"
FROM sales.orders
ORDER BY orderid ASC;
