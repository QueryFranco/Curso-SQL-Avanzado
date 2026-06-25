-------LEAD AND LAG----------
SELECT*,
    ROUND(COALESCE(((CurrentSales::numeric-PreviusSales)/PreviusSales)*100,0),2)||'%' AS PercentageChange
    FROM(    SELECT
            EXTRACT(MONTH FROM orderdate) AS Month,
            LAG(SUM(sales)) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)ASC)PreviusSales,
            SUM(sales) CurrentSales
        FROM sales.orders
        GROUP BY EXTRACT(MONTH FROM orderdate) )t;
----------------------------------
       SELECT
        customerid,
       ROUND( COALESCE(AVG(GapDays),9999),1) AS AvgGap,
        RANK() OVER(ORDER BY COALESCE(AVG(GapDays),9999) ASC) Rank
     FROM(   SELECT
            orderid,
            customerid,
            orderdate AS CurrentOrder,
            LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate ASC) AS NextOrder,
            LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate ASC)-orderdate AS GapDays
        FROM sales.orders)t 
    GROUP BY customerid;
------------------------------------------
   SELECT
        productid,
        HighetsValue,
        LowestValueS
   FROM(    SELECT
            productid,
            sales,
            FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales DESC) HighetsValue,
            LAST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) LowestValue
        FROM sales.orders)t 
        GROUP BY productid, HighetsValue, LowestValue;
      


    