--LEFT ANTI JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales,
    o.customer_id
FROM customers AS c
LEFT JOIN orders AS o
ON c.id=o.customer_id
WHERE o.customer_id IS NULL
;
-- RIGHT ANTI JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
RIGHT JOIN orders AS o 
ON c.id=o.customer_id
WHERE c.id IS NULL;
-- TASK
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM orders AS o 
LEFT JOIN customers AS c 
ON o.customer_id=c.id
WHERE c.id IS NULL;
--FULL ANTI JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales,
    o.customer_id
FROM orders AS o 
FULL JOIN customers AS c 
ON o.customer_id=c.id
WHERE c.id IS NULL OR o.customer_id IS NULL
;
--CHALLENGE
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c 
LEFT JOIN orders AS o
ON c.id=o.customer_id
WHERE o.order_id IS NOT NULL
;
--CROSS JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c 
CROSS JOIN orders AS o
;
--TASK 
SELECT
    o.orderid,
    o.sales,
    c.firstname AS CustomerFirstName,
    c.lastname AS CustomerLastName,
    p.product AS ProductName,
    p.price,
    e.firstname AS EmployeeFirstName,
    e.lastname AS EmployeeLastName
FROM sales.orders AS o
LEFT JOIN sales.customers AS c
ON   o.customerid = c.customerid
LEFT JOIN sales.products AS p 
ON o.productid = p.productid
LEFT JOIN sales.employees AS e
ON o.salespersonid = e.employeeid
ORDER BY o.orderid ASC
;
----------------------------------
SELECT*
FROM sales.products
;
SELECT*
FROM sales.employees
;
SELECT*
FROM sales.orders;
SELECT*
FROM sales.customers;