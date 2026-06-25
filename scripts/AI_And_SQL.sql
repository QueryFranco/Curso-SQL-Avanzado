 SELECT * FROM sales.orders
 WHERE order_date >= '2024-01-01' AND order_date < '2024-02-01';

 -- Select Top 3 Customers based on Score
  SELECT c.*, 
    cs.total_sales
    FROM sales.customers c
    JOIN (SELECT customerid, SUM(sales) AS total_sales FROM sales.orders GROUP BY customerid) cs ON c.customerid = cs.customerid
    ORDER BY c.score DESC
    LIMIT 3;
 -- Rank Customers based on their total orders sales
   SELECT *,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank 
    FROM (
        SELECT customerid, SUM(sales) AS total_sales
        FROM sales.orders
        GROUP BY customerid
    ) AS customer_sales;

--Calculate the avarage sales for customers
 SELECT customerid, 
    CAST(AVG(sales) AS DECIMAL(10,2)) AS avg_sales
    FROM sales.orders
    GROUP BY customerid;
-- join customers with orders
SELECT c.customerid, c.lastname, o.orderid, o.sales
FROM sales.customers c
JOIN sales.orders o ON c.customerid = o.customerid;
