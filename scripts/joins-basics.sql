-- NO JOIN
SELECT*
FROM customers;

SELECT*
FROM orders;
-- INNER JOIN
SELECT
    cs.id,
    cs.first_name,
    ord.order_id,
    ord.sales
FROM customers cs
INNER JOIN orders ord
ON cs.id = ord.customer_id;
-- LEFT JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers c
LEFT JOIN orders o
ON c.id=o.customer_id
;
--RIGTH JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id=o.customer_id
;
-- LEFT JOIN TASK
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM orders AS o
LEFT JOIN customers AS c
ON c.id=o.customer_id
;
-- FULL JOIN
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
FULL JOIN orders AS o
ON c.id=o.customer_id
;