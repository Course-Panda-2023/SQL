--SELECT QUERIES

--QUESTION 1
-- select product_id, product_name, min_price
-- from oe.product_information 
-- order by product_name asc

--QUESTION 2
-- select (first_name || ' ' || last_name) as FULL_NAME, phone_number, trunc((Sysdate-(HIRE_DATE))/30)/12 YEARS_WORKED_IN_THE_COMPANY
-- from hr.employees

--QUESTION 3
-- select (first_name || ' ' || last_name) as FULL_NAME, salary
-- from hr.employees
-- where EXTRACT(YEAR FROM hire_date) >= 2005
-- order by salary

--QUESTION 4
-- SELECT PRODUCT_NAME, LIST_PRICE, MIN_PRICE
-- FROM OE.Product_Information
-- WHERE (LIST_PRICE - MIN_PRICE) >= 100
-- ORDER BY PRODUCT_NAME ASC

--JOIN TABLES
--QUESTION 1
-- SELECT customers.CUSTOMER_ID, customers.cust_first_name || ' ' || customers.cust_last_name as FULL_NAME, orders.ORDER_ID
-- FROM oe.customers customers, OE.orders orders
-- WHERE EXTRACT(YEAR from orders.ORDER_DATE) = 2007 AND customers.CREDIT_LIMIT BETWEEN 200 AND 700 AND customers.CUSTOMER_ID = orders.CUSTOMER_ID
-- ORDER BY customers.CUSTOMER_ID ASC, FULL_NAME ASC;

--QUESTION 2
-- SELECT product.PRODUCT_NAME, product.LIST_PRICE, categories.CATEGORY_NAME
-- FROM oe.product_information product INNER JOIN oe.CATEGORIES_TAB categories on (product.CATEGORY_ID = categories.CATEGORY_ID)
-- ORDER BY categories.CATEGORY_NAME ASC

--QUESTION 3
-- SELECT customers.cust_first_name || ' ' || customers.cust_last_name as FULL_NAME, product_info.PRODUCT_NAME
-- FROM oe.customers customers INNER JOIN oe.orders ord ON (customers.CUSTOMER_ID = ord.CUSTOMER_ID) 
-- INNER JOIN oe.ORDER_ITEMS ord_item ON (ord.ORDER_ID = ord_item.ORDER_ID)
-- INNER JOIN oe.PRODUCT_INFORMATION product_info ON (ord_item.PRODUCT_ID = product_info.PRODUCT_ID)
-- WHERE EXTRACT(YEAR from ord.ORDER_DATE) = 2008 AND product_info.LIST_PRICE >= 10

--QUESTION 4 (SKIPPED)

--QUESTION 5
-- SELECT EMPLOYEE.FIRST_NAME || ' ' || EMPLOYEE.LAST_NAME as FULL_NAME, MANAGER.FIRST_NAME || ' ' || EMPLOYEE.LAST_NAME as MANAGER_NAME
-- FROM HR.Employees EMPLOYEE JOIN HR.Employees MANAGER ON (MANAGER.MANAGER_ID = EMPLOYEE.EMPLOYEE_ID)


--AGGERATION
--QUESTION 1
-- SELECT ROUND(AVG(EXTRACT(YEAR FROM HIRE_DATE)), 0) AS AVERAGE_SENORITY FROM HR.EMPLOYEES

--QUESTION 2
-- SELECT SUPPLIER_ID, COUNT(SUPPLIER_ID)
-- FROM oe.product_information
-- GROUP BY SUPPLIER_ID

--QUESTION 3
-- SELECT PRODUCT_ID, COUNT(PRODUCT_ID)
-- FROM oe.order_items
-- GROUP BY PRODUCT_ID

--QUESTION 4
-- SELECT EXTRACT(YEAR FROM ORDER_DATE) as year, MIN(ORDER_DATE), MAX(ORDER_DATE), COUNT(ORDER_ID), SUM(ORDER_TOTAL)
-- FROM oe.orders
-- GROUP BY EXTRACT(YEAR FROM ORDER_DATE)
-- ORDER BY year;

--QUESTION 5
-- SELECT TO_CHAR( ORDER_DATE, 'Day' ), COUNT(ORDER_ID), SUM(ORDER_TOTAL)
-- FROM oe.orders
-- GROUP BY TO_CHAR( ORDER_DATE, 'Day' )

--QUESTION 6
-- SELECT FIRST_NAME || ' ' || LAST_NAME as FULL_NAME, SUM(ORDER_TOTAL)
-- FROM oe.orders, hr.employees
-- WHERE SALES_REP_ID = EMPLOYEE_ID and EXTRACT(YEAR FROM ORDER_DATE) = 2007 
-- GROUP BY FIRST_NAME || ' ' || LAST_NAME
-- HAVING  SUM(ORDER_TOTAL) > 20000

--QUESTION 7
-- SELECT customers.cust_first_name || ' ' || customers.cust_last_name as FULL_NAME, (sum(ord.ORDER_TOTAL)/1000) as ORACLE_POINT
-- FROM oe.customers customers INNER JOIN oe.orders ord ON (customers.CUSTOMER_ID = ord.CUSTOMER_ID) 
-- GROUP BY customers.cust_first_name || ' ' || customers.cust_last_name

-- SUB QUERIES
--question 1

-- SELECT PRODUCT_NAME, LIST_PRICE
-- FROM oe.product_information
-- WHERE (select max(list_price) from oe.product_information) = LIST_PRICE

--question 2
-- SELECT product_info.PRODUCT_NAME, UNIT_PRICE
-- FROM oe.order_items order_item, oe.product_information product_info
-- WHERE (
--   select unit_price from oe.order_items
--   order by unit_price desc
--   fetch first 1 row only
-- ) = UNIT_PRICE
-- fetch first 1 row only

-- SELECT product_id
-- FROM oe.product_information
-- WHERE list_price > (SELECT AVG(list_price) FROM oe.product_information);

  -- question 4
  
-- SELECT product_name
-- FROM oe.order_items ord_item INNER JOIN oe.product_information product_info ON(ord_item.product_id = product_info.product_id), oe.orders
-- WHERE orders.order_id = ord_item.order_id AND orders.SALES_REP_ID = (
--   SELECT employee_id
--   FROM hr.employees
--   WHERE HIRE_DATE is not null AND JOB_ID = 'SA_REP'
--   order by HIRE_DATE asc
--   fetch first 1 rows only
-- ); 
-- OFFSET 100 rows

-- question 5:

-- SELECT DISTINCT *
-- FROM OE.PRODUCT_INFORMATION PROD_INFO
-- INNER JOIN (
--   SELECT DISTINCT product_id
--   from oe.order_items 
--   where oe.order_items.order_id in (
--     SELECT ord.order_id
--     FROM oe.orders ord INNER JOIN oe.order_items ord_item on (ord.order_id = ord_item.order_id)
--     WHERE unit_price = (
--       SELECT unit_price
--       FROM oe.order_items
--       ORDER BY unit_price DESC
--       fetch first 1 row only
--     )
--   )
-- ) FILTERED_PRODUCT_ID
-- ON PROD_INFO.PRODUCT_ID = FILTERED_PRODUCT_ID.PRODUCT_ID

-- ANALYTIC FUNCTIONS
-- QUESTION 1

-- SELECT PRODUCT_NAME, LIST_PRICE, CATEGORY_ID
-- FROM (
--   SELECT PRODUCT_NAME, LIST_PRICE, CATEGORY_ID,
--   ROW_NUMBER() OVER (PARTITION BY CATEGORY_ID ORDER BY LIST_PRICE DESC) AS PRICE_RANK
--   FROM oe.product_information
--   WHERE LIST_PRICE is not null
-- ) 
-- WHERE PRICE_RANK <= 3;

-- QUESTION 2

-- SELECT yearly_total.*, year_total - LAG(year_total) OVER (ORDER BY year ASC) AS diff
-- FROM (
--   SELECT EXTRACT(YEAR FROM order_date) AS year, SUM(order_total) as year_total
--   FROM oe.orders
--   GROUP BY EXTRACT(YEAR FROM order_date)
-- ) yearly_total

-- question 3

-- SELECT EXTRACT(YEAR FROM ORDER_DATE) AS year, EXTRACT(MONTH FROM ORDER_DATE) AS month, SUM(ORDER_TOTAL) AS monthly_total, 
--   SUM(SUM(ORDER_TOTAL)) OVER (ORDER BY EXTRACT(YEAR FROM ORDER_DATE), EXTRACT(MONTH FROM ORDER_DATE)) AS running_sum
-- FROM oe.orders
-- GROUP BY EXTRACT(YEAR FROM ORDER_DATE), EXTRACT(MONTH FROM ORDER_DATE)
-- ORDER BY EXTRACT(YEAR FROM ORDER_DATE), EXTRACT(MONTH FROM ORDER_DATE) ASC;

--VIEW

--QUESTION 1 & 2

CREATE VIEW best_salesman_with_count AS
SELECT year, sales_rep_id, quantity_sold
FROM 
(
  SELECT year, sales_rep_id, quantity_sold, ROW_NUMBER() OVER (PARTITION BY year ORDER BY quantity_sold DESC) AS yearly_rank
  FROM 
  (
    SELECT 
      EXTRACT(YEAR FROM order_date) AS year,
      sales_rep_id,
      sum(quantity) AS quantity_sold
    FROM 
    (
      SELECT * 
      FROM oe.orders ord
      INNER JOIN oe.order_items ord_item
      ON ord.order_id = ord_item.order_id
    )
    WHERE sales_rep_id IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date), sales_rep_id
  )
)
WHERE yearly_rank = 1

-- question 3

SELECT product_id, quantity_sold
FROM (
  SELECT product_id, sum(quantity) as quantity_sold
  FROM (
    SELECT ord_item.product_id, ord_item.quantity
    FROM oe.order_items ord_item
    INNER JOIN oe.product_information product_info
    ON ord_item.product_id = product_info.product_id
  )
  GROUP BY product_id
)
ORDER BY quantity_sold DESC
FETCH FIRST 1 ROWS ONLY


-- question 4

SELECT product_id, highest_price
FROM (
  SELECT product_id, sum(unit_price) as highest_price
  FROM (
    SELECT ord_item.product_id, ord_item.unit_price
    FROM oe.order_items ord_item
    INNER JOIN oe.product_information product_info
    ON ord_item.product_id = product_info.product_id
  )
  GROUP BY product_id
)
ORDER BY highest_price DESC
FETCH FIRST 1 ROWS ONLY