--------ROW_NUMBER(), RANK() AND DENSE_RANK()------------
SELECT
    orderid,
    orderdate,
    sales,
    ROW_NUMBER() OVER(ORDER BY sales DESC) RANK,
    RANK() OVER(ORDER BY sales DESC) RANK,
    DENSE_RANK() OVER(ORDER BY sales DESC) RANK
FROM sales.orders;
----------------------------------------------------
      SELECT*
       FROM (SELECT
            orderid,
            orderdate,
            productid,
            sales,
            DENSE_RANK() OVER(PARTITION BY productid ORDER BY sales DESC) RankTOPProducts
        FROM sales.orders)t WHERE RankTOPProducts = 1;
--------------------------------------------------------
   SELECT*
   FROM(SELECT
        customerid,
        SUM(sales),
        RANK() OVER(ORDER BY SUM(sales) ASC)
 FROM sales.orders
    GROUP BY customerid)t WHERE rank IN (1,2);
    ------------------------------------------------
    SELECT
        ROW_NUMBER() OVER(ORDER BY orderid ASC,orderdate ASC) UNIQUEID,
        *
    FROM sales.ordersarchive;
------------------------------------------------------
         SELECT*
         FROM(   SELECT
                ROW_NUMBER() OVER(PARTITION BY orderid ORDER BY creationtime DESC) rn,
                *
            FROM sales.ordersarchive)t
        WHERE rn=1;
--------------NTILE--------------------------------
SELECT
    orderid,
    sales,
    productid,
    NTILE(3) OVER( ORDER BY sales DESC) BucketsSize
FROM sales.orders;
----------------------------------------------------
SELECT*,
CASE
    WHEN LevelSales=1 THEN 'High'
    WHEN LevelSales=2 THEN 'Medium'
    WHEN LevelSales=3 THEN 'Low'
END Category
   FROM( SELECT 
        NTILE(3) OVER(ORDER BY sales DESC) LevelSales,
        sales,
        productid,
        orderid
    FROM sales.orders)t;
----------------------------------------------
SELECT
    NTILE(2) OVER(ORDER BY orderid ASC) AS Buckets,
    *
FROM sales.orders;
-------CUME_DIST() AND PERCENT_RANK()--------------
     SELECT*,
        CONCAT(RankPrices*100,'%') RankPercent
     FROM(   SELECT
            productid,
            CUME_DIST() OVER(ORDER BY price DESC) RankPrices,
            price
        FROM sales.products)t 
    WHERE RankPrices <= 0.4;

    --*CUM_DIST():calcula el porcentaje de filas que están por debajo/encima o igual a la fila actual (va del 0 al 1)
    --*PERCENT_RANK():calcula el porcentaje de filas que están estrictamente por debajo/encima de la fila actual, sin contarse a sí misma (va del 0 al 1)