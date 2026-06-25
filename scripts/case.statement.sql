 SELECT 
    CASE 
    WHEN sales>50 THEN 'High'
    WHEN sales>20 THEN 'Medium'
    ELSE 'Low'
 END AS Category,
    SUM(sales) AS TotalSales,
    COUNT(sales) AS Quantitysales
 FROM sales.orders
 GROUP BY   (CASE 
    WHEN sales>50 THEN 'High'
    WHEN sales>20 THEN 'Medium'
    ELSE 'Low'
 END) 
 ORDER BY SUM(sales) DESC;
 -------------------------------------------
 SELECT 
    employeeid,
    firstname,
    lastname,
    gender,
    CASE
        WHEN gender = 'M' THEN 'MALE'
        WHEN gender = 'F' THEN 'FEMALE'
    END AS Gender
 FROM sales.employees;
 ---------------------------------------------
 SELECT
    customerid,
    COALESCE(firstname || ' ' ||lastname, firstname || ' '|| 'Unknown',  'Unknown'||' '||lastname, 'Unknown') AS FullName,
    CASE
        WHEN country = 'USA' THEN 'US'
        WHEN country = 'Germany' THEN 'DE'
        ELSE 'n/a'
    END AS CountryAbbreviatedText,
    CASE country
        WHEN  'USA' THEN 'US'
        WHEN 'Germany' THEN 'DE'
        ELSE 'n/a'
    END AS CountryAbbreviatedText2,
    score
 FROM sales.customers;
 ----------------------------------------------
  SELECT
    customerid,
    COALESCE(firstname || ' ' ||lastname, firstname || ' '|| 'Unknown',  'Unknown'||' '||lastname, 'Unknown') AS FullName,
    country,
    COALESCE(score,0) AS Score,
    AVG(COALESCE(score,0)) OVER() AS AvgScore
  FROM sales.customers;

   SELECT
    customerid,
    COALESCE(firstname || ' ' ||lastname, firstname || ' '|| 'Unknown',  'Unknown'||' '||lastname, 'Unknown') AS FullName,
    country,
    score,
    CASE
        WHEN score IS NULL THEN 0
        ELSE score
    END ScoreClean,
    AVG(CASE
        WHEN score IS NULL THEN 0
        ELSE score
    END) OVER() AS AvgScore
  FROM sales.customers;
  ---------------------------------------------
  SELECT
    customerid,
    SUM(CASE
        WHEN sales>30 THEN 1
        ELSE 0
    END )AS CountSalesHigh,
    COUNT(sales) AS TotalSales
  FROM sales.orders
  GROUP BY customerid
order by customerid
; 