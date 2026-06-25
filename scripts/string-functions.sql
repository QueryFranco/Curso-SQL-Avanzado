------CONCAT---------
SELECT 
    firstname,
    country,
CONCAT(firstname,' ', country) AS name_country
FROM sales.customers
;
---- UPPER and LOWER------
SELECT firstname,
LOWER(firstname)
FROM sales.employees;

SELECT 
    firstname,
    lastname,
UPPER(CONCAT(firstname, ' ', lastname)) AS FullName
FROM sales.customers;
------TRIM-----------
SELECT first_name,
    LENGTH(first_name)AS Length_name,
    LENGTH(TRIM(first_name)) AS Length_name_nospaces,
    LENGTH(first_name) - LENGTH(TRIM(first_name)) AS Spaces
FROM customers
WHERE first_name != TRIM(first_name)
;
-----LENGTH------------
 SELECT
    first_name,
    LENGTH(first_name)AS Length_Name
FROM customers;
---------LEFT and RIGTH--------
SELECT first_name,
    LEFT(TRIM(first_name),2)AS First_Two_Characters,
    RIGHT(TRIM(first_name),2) AS Last_2_charac
FROM customers;
---------SUBSTRING--------------
SELECT 
    first_name,
    SUBSTRING(TRIM(first_name),3,LENGTH(first_name)) AS sub_name
FROM customers;
