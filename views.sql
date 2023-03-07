-- view 1

-- part 1 of the view
CREATE VIEW NUMBER_OF_SALES_BY_YEAR_AND_BEST_SELLER AS
SELECT
  Employees.Employee_Id,
  Employees.First_Name || '-' || Employees.Last_Name AS Name,
  Extract(year from Orders.Order_Date) AS Year,
  Count(*) AS Counts_Of_Orders
FROM
  HR.Employees
  INNER JOIN
  OE.Orders
  ON
  Employees.Employee_Id
  =
  Orders.SALES_REP_ID
WHERE
  Employees.Job_Id = 'SA_REP'
GROUP BY
  Employees.Employee_Id,
  Employees.First_Name || '-' || Employees.Last_Name,
  Extract(year from Orders.Order_Date)
  
-- THE FINAL RESULT
SELECT
  YEAR,
  MAX(Counts_Of_Orders) AS HOW_MANY_ITEMS
FROM
  NUMBER_OF_SALES_BY_YEAR_AND_BEST_SELLER
GROUP BY
  YEAR
  
  
  
-- VIEW 2

CREATE VIEW YEAR_AND_ITS_MAXIMUM_ORDERS_OF_SELLER AS
SELECT
  YEAR,
  MAX(Counts_Of_Orders) AS HOW_MANY_ITEMS
FROM
  NUMBER_OF_SALES_BY_YEAR_AND_BEST_SELLER
GROUP BY
  YEAR
  
  
SELECT * FROM NUMBER_OF_SALES_BY_YEAR_AND_BEST_SELLER;
SELECT * FROM YEAR_AND_ITS_MAXIMUM_ORDERS_OF_SELLER;

-- THE RESULT

SELECT
  T1.NAME,
  T1.EMPLOYEE_ID,
  T1.YEAR,
  T1.COUNTS_OF_ORDERS
FROM
  NUMBER_OF_SALES_BY_YEAR_AND_BEST_SELLER T1
  INNER JOIN
  YEAR_AND_ITS_MAXIMUM_ORDERS_OF_SELLER T2
  ON
  T1.YEAR = T2.YEAR
  AND
  T2.HOW_MANY_ITEMS = T1.COUNTS_OF_ORDERS;


-- VIEW 3
/*
--- OLD VERSION

CREATE VIEW PRODUCTS_AND_THE_NUMBER_THEY_BEEN_ORDERED AS
SELECT
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  COUNT(*) AS NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED
FROM
  OE.ORDERS
  INNER JOIN
  OE.ORDER_ITEMS
  ON
  Orders.ORDER_ID
  =
  Order_Items.ORDER_ID
  INNER JOIN
  OE.PRODUCT_INFORMATION
  ON
  Order_Items.PRODUCT_ID
  =
  Product_Information.PRODUCT_ID
GROUP BY
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID
  
 -- RESULT 
 SELECT
  PRODUCT_NAME,
  PRODUCT_ID
FROM
  PRODUCTS_AND_THE_NUMBER_THEY_BEEN_ORDERED
WHERE
  NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED 
  =
  (
    SELECT
      MAX(NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED)
    FROM
      PRODUCTS_AND_THE_NUMBER_THEY_BEEN_ORDERED
  )
  */
  
 CREATE VIEW PRODUCTS_AND_THE_NUMBER_THEY_HAVE_BEEN_ORDERED AS
SELECT
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  COUNT(*) AS NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED,
  ORDER_ITEMS.QUANTITY
FROM
  OE.ORDERS
  INNER JOIN
  OE.ORDER_ITEMS
  ON
  Orders.ORDER_ID
  =
  Order_Items.ORDER_ID
  INNER JOIN
  OE.PRODUCT_INFORMATION
  ON
  Order_Items.PRODUCT_ID
  =
  Product_Information.PRODUCT_ID
GROUP BY
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  ORDER_ITEMS.QUANTITY

CREATE VIEW PRODUCTS_AND_TIMES_THEY_HAVE_BEEN_ORDERED AS
SELECT
  PRODUCT_NAME,
  PRODUCT_ID,
  SUM(QUANTITY * NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED) AS TIMES_OF_HAS_BEEN_ORDERED
FROM
  PRODUCTS_AND_THE_NUMBER_THEY_HAVE_BEEN_ORDERED
GROUP BY
  PRODUCT_NAME,
  PRODUCT_ID

SELECT
  PRODUCT_NAME,
  PRODUCT_ID,
  TIMES_OF_HAS_BEEN_ORDERED AS TIMES_OF_HAS_BEEN_ACTUALLY_ORDERED
FROM
  PRODUCTS_AND_TIMES_THEY_HAVE_BEEN_ORDERED
WHERE
  TIMES_OF_HAS_BEEN_ORDERED
  =
  (
    SELECT 
      MAX(TIMES_OF_HAS_BEEN_ORDERED)
    FROM 
      PRODUCTS_AND_TIMES_THEY_HAVE_BEEN_ORDERED
  ); 
  
  
-- VIEW 4

/*
OLD VERSION

CREATE VIEW PRODUCTS_AND_THE_INCOME AS
SELECT
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  COUNT(*) AS NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED,
  (LIST_PRICE - MIN_PRICE) AS INCOME
FROM
  OE.ORDERS
  INNER JOIN
  OE.ORDER_ITEMS
  ON
  Orders.ORDER_ID
  =
  Order_Items.ORDER_ID
  INNER JOIN
  OE.PRODUCT_INFORMATION
  ON
  Order_Items.PRODUCT_ID
  =
  Product_Information.PRODUCT_ID
GROUP BY
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  (LIST_PRICE - MIN_PRICE)

SELECT * FROM PRODUCTS_AND_THE_INCOME;

SELECT
  PRODUCT_NAME,
  PRODUCT_ID,
  NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED * INCOME AS INCOME_MULT_BY_ODERS_TIME
FROM
  PRODUCTS_AND_THE_INCOME
WHERE
  NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED * INCOME
  =
  (
    SELECT 
      MAX(NUMBER_OF_TIME_THIS_PRODUCT_HAS_BEEN_ORDERED * INCOME)
    FROM
      PRODUCTS_AND_THE_INCOME
  );
  */
  
CREATE VIEW PRODUCTS_AND_HOW_MUCH_THEY_HAVE_ACTUALLY_ORDERED AS  
SELECT
  PRODUCT_NAME,
  PRODUCT_ID,
  TIMES_OF_HAS_BEEN_ORDERED AS TIMES_OF_HAS_BEEN_ACTUALLY_ORDERED
FROM
  PRODUCTS_AND_TIMES_THEY_HAVE_BEEN_ORDERED
WHERE
  TIMES_OF_HAS_BEEN_ORDERED
  =
  (
    SELECT 
      MAX(TIMES_OF_HAS_BEEN_ORDERED)
    FROM 
      PRODUCTS_AND_TIMES_THEY_HAVE_BEEN_ORDERED
  ); 
  
 CREATE VIEW PRODUCTS_AND_THE_INCOME AS
SELECT
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  (LIST_PRICE - MIN_PRICE) AS INCOME
FROM
  OE.ORDERS
  INNER JOIN
  OE.ORDER_ITEMS
  ON
  Orders.ORDER_ID
  =
  Order_Items.ORDER_ID
  INNER JOIN
  OE.PRODUCT_INFORMATION
  ON
  Order_Items.PRODUCT_ID
  =
  Product_Information.PRODUCT_ID
GROUP BY
  PRODUCT_INFORMATION.PRODUCT_NAME,
  PRODUCT_INFORMATION.PRODUCT_ID,
  (LIST_PRICE - MIN_PRICE);
  
CREATE VIEW INNER_JOINED_TABLE_OF_LASTS AS
SELECT 
  T1.PRODUCT_ID,
  T1.PRODUCT_NAME,
  T2.INCOME * T1.TIMES_OF_HAS_BEEN_ACTUALLY_ORDERED AS PURE_INCOME
FROM
  PRODUCTS_AND_HOW_MUCH_THEY_HAVE_ACTUALLY_ORDERED T1
  INNER JOIN
  PRODUCTS_AND_THE_INCOME T2
  ON
  T1.PRODUCT_ID
  =
  T2.PRODUCT_ID
  AND
  T1.PRODUCT_NAME
  =
  T2.PRODUCT_NAME

-- RESULT

SELECT
  PRODUCT_ID,
  PRODUCT_NAME,
  PURE_INCOME
FROM
  INNER_JOINED_TABLE_OF_LASTS
WHERE
  PURE_INCOME
  =
  (
    SELECT 
      MAX(PURE_INCOME)
    FROM
      INNER_JOINED_TABLE_OF_LASTS
  );