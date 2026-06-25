----------FROM CLAUSE------------
    
SELECT*
  FROM(  SELECT
        productid,
        price,
        avg(price) OVER ()::FLOAT AS AvgPrice
    FROM sales.products)t 
    WHERE price>AvgPrice;
-------------------------------------
   SELECT
    customerid,
    AmountSales,
    RANK() OVER (ORDER BY AmountSales DESC)
   FROM( SELECT
            productid,
            customerid,
            sales,
            NULLIF(quantity,0) AS Quantity,
           SUM(sales*NULLIF(quantity,0)) OVER(PARTITION BY customerid)  AS AmountSales
        FROM sales.orders)
    GROUP BY customerid, AmountSales;
------------------SELECT CLAUSE (Only Scalar)----------------
 SELECT 
    productid,
    product,
    price,
    (SELECT 
        COUNT(orderid) AS TotalOrders
        FROM sales.orders)
FROM sales.products;
------------------JOIN CLAUSE------------------
SELECT c.* ,
        o.OrdersForCustomers
FROM sales.customers AS c 
LEFT JOIN
        (SELECT 
    customerid,
    COUNT(*) AS OrdersForCustomers
FROM sales.orders
GROUP BY customerid) AS o 
ON c.customerid=o.customerid;
--------------WHERE CLAUSE----------
SELECT
    productid,
    product,
    price,
    (SELECT
    AVG(price)
  FROM sales.products)::Float AS AvgPrice
FROM sales.products
WHERE price > (SELECT
                    AVG(price)
                    FROM sales.products);
----------------------------------------
SELECT*
FROM sales.orders 
WHERE customerid IN(SELECT 
                        customerid
                    FROM sales.customers  
                    WHERE country != 'Germany');
----------------ANY | ALL --------------------------
SELECT 
    employeeid,
    COALESCE(firstname || ' '|| lastname, firstname ||' ' || 'n/a' ) AS FullName,
    gender,
    salary
FROM sales.Employees
WHERE gender ='F' AND salary > ANY (SELECT salary 
                    FROM sales.Employees 
                    WHERE gender = 'M'  );
-------------------CORRALATED SUBQUERY----------------------------
SELECT c.*,
    o.TotalOrdersEachCustomer
FROM sales.customers AS c
LEFT JOIN (SELECT 
            customerid,
            COUNT(*) TotalOrdersEachCustomer
            FROM sales.orders
            GROUP BY customerid) AS o
ON c.customerid = o.customerid;

SELECT*,
    (SELECT COUNT(*) 
        FROM sales.orders AS o
        WHERE o.customerid=c.customerid )
FROM sales.customers AS c;
---------------EXISTS-------------------------
SELECT*
FROM sales.orders AS o 
WHERE EXISTS (SELECT 1
                FROM sales.customers AS c 
                WHERE c.customerid=o.customerid and country='Germany');
 
