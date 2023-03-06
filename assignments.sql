--SELECT QUERY--

-- select product_id, product_name, LIST_PRICE
-- from oe.product_information 
-- order by product_name asc

-- select (first_name || ' ' || last_name) as FULL_NAME, phone_number, trunc((Sysdate-(HIRE_DATE))/30)/12 YEARS_WORKED_IN_THE_COMPANY
-- from hr.employees

-- select (first_name || ' ' || last_name) as FULL_NAME, salary
-- from hr.employees
-- where EXTRACT(YEAR FROM hire_date) >= 2005
-- order by salary

-- select product_name
-- from oe.product_information
-- where list_price - min_price > 100
-- order by product_name


--JOIN TABLES--

-- select ord.CUSTOMER_ID, cust.CUST_FIRST_NAME || ' ' || cust.CUST_LAST_NAME as CUST_FULL_NAME, ord.ORDER_ID
-- from oe.orders ord, oe.customers cust
-- where ord.CUSTOMER_ID = cust.CUSTOMER_ID and EXTRACT(YEAR FROM ord.ORDER_DATE) = 2007 
-- and cust.CREDIT_LIMIT > 200 and cust.CREDIT_LIMIT < 700
-- order by cust.CUST_FIRST_NAME, ord.ORDER_ID


-- select pro.PRODUCT_NAME, pro.LIST_PRICE, cat.CATEGORY_NAME
-- from oe.product_information pro, oe.categories_tab cat
-- where pro.CATEGORY_ID = cat.CATEGORY_ID
-- order by cat.CATEGORY_NAME


-- select ord.CUSTOMER_ID, cust.CUST_FIRST_NAME || ' ' || cust.CUST_LAST_NAME as CUST_FULL_NAME, pro.PRODUCT_NAME
-- from oe.product_information pro, oe.customers cust, oe.orders ord, oe.order_items orit
-- where ord.CUSTOMER_ID = cust.CUSTOMER_ID and ord.ORDER_ID = orit.ORDER_ID and orit.PRODUCT_ID = pro.PRODUCT_ID
-- and EXTRACT(YEAR FROM ord.ORDER_DATE) = 2008 and orit.UNIT_PRICE > 10


-- select ord.ORDER_ID, pro.PRODUCT_NAME, orit.UNIT_PRICE * count (ord.ORDER_ID) as UNIT_TIMES_ORDERED_QUANTITY_IN_2007
-- from oe.product_information pro, oe.orders ord, oe.order_items orit
-- where ord.ORDER_ID = orit.ORDER_ID and orit.PRODUCT_ID = pro.PRODUCT_ID and EXTRACT(YEAR FROM ord.ORDER_DATE) = 2007
-- group by ord.ORDER_ID, pro.PRODUCT_NAME, orit.UNIT_PRICE


-- select emp1.FIRST_NAME || ' ' || emp1.LAST_NAME as EMPLOYEE_FULL_NAME,
-- emp2.FIRST_NAME || ' ' || emp2.LAST_NAME as MANAGER_FULL_NAME
-- from hr.employees emp1 
-- left join hr.employees emp2
-- on emp1.MANAGER_ID = emp2.EMPLOYEE_ID


--AGGREGATION FUNCTIONS--

-- select avg(trunc((END_DATE - START_DATE)/30)/12) AVERAGE_SENIORITY_OF_COMPANYS_EMPLOYEES
-- from hr.job_history


-- select SUPPLIER_ID, count (SUPPLIER_ID) as AMOUNT_OF_PRODUCTS_SUPP
-- from oe.product_information
-- group by SUPPLIER_ID


-- select PRODUCT_ID, count (PRODUCT_ID) as ITEMS_ORDERED
-- from oe.order_items
-- group by PRODUCT_ID


-- select EXTRACT(YEAR FROM ord.ORDER_DATE), min(ORDER_DATE) as FIRST_ORDER, max(ORDER_DATE) as LAST_ORDER,
-- count (ORDER_ID) as AMOUNT_OF_ORDERS, sum(ORDER_TOTAL) as TOTAL_YEARLY_COST
-- from oe.orders ord
-- group by EXTRACT(YEAR FROM ord.ORDER_DATE)


-- select to_char(ORDER_DATE, 'DAY') as ORDER_DAY, count (ORDER_ID) as NUMBER_OF_ORDERS_MADE, 
-- sum(ORDER_TOTAL) as TOTAL_DAILY_COST
-- from oe.orders
-- group by to_char(ORDER_DATE, 'DAY')


-- select emp.FIRST_NAME || ' ' || emp.LAST_NAME as FULL_NAME , sum(ord.ORDER_TOTAL) as SUM_ORDER_TOTAL
-- from hr.employees emp, oe.orders ord 
-- where emp.EMPLOYEE_ID = ord.SALES_REP_ID and EXTRACT(YEAR FROM ord.ORDER_DATE) = 2007
-- group by emp.FIRST_NAME, emp.LAST_NAME
-- HAVING sum(ord.ORDER_TOTAL) > 20000


-- select cust.CUST_FIRST_NAME || ' ' || cust.CUST_LAST_NAME as FULL_NAME, sum(ORDER_TOTAL)/1000 as ORACLE_POINTS
-- from oe.customers cust, oe.orders ord
-- where cust.CUSTOMER_ID = ord.CUSTOMER_ID
-- group by cust.CUST_FIRST_NAME, cust.CUST_LAST_NAME


--SUB QUERIES--

-- select PRODUCT_NAME
-- from oe.product_information
-- where (select max(LIST_PRICE) from oe.product_information) = LIST_PRICE


-- select PRODUCT_NAME
-- from oe.product_information
-- where (select max(LIST_PRICE) from oe.product_information pro, oe.order_items ord 
-- where ord.PRODUCT_ID = pro.PRODUCT_ID) = LIST_PRICE


-- select PRODUCT_NAME from oe.product_information
-- where LIST_PRICE > (select avg(LIST_PRICE)
-- from oe.product_information)


-- select PRODUCT_NAME
-- from oe.product_information pro, oe.order_items orit, oe.orders ord
-- where pro.PRODUCT_ID = orit.PRODUCT_ID and orit.ORDER_ID = ord.ORDER_ID and ord.SALES_REP_ID = (select EMPLOYEE_ID
-- from hr.employees
-- where (select max(trunc((Sysdate-(HIRE_DATE))/30)/12) from hr.employees
--   where JOB_ID = 'SA_REP') = trunc((Sysdate-(HIRE_DATE))/30)/12
--   and JOB_ID = 'SA_REP')


-- select PRODUCT_NAME from oe.product_information
-- where PRODUCT_ID in (select PRODUCT_ID 
-- from oe.order_items
-- where ORDER_ID in (select ORDER_ID 
-- from oe.order_items
-- where PRODUCT_ID = (select PRODUCT_ID
-- from oe.product_information
-- where (select max(LIST_PRICE) from oe.product_information pro, oe.order_items ord 
-- where ord.PRODUCT_ID = pro.PRODUCT_ID) = LIST_PRICE)))


--ANALYTIC FUNCTIONS--

-- SELECT PRODUCT_NAME, CATEGORY_ID, LIST_PRICE
-- FROM
-- (
--   SELECT
--     PRODUCT_NAME, CATEGORY_ID, LIST_PRICE,
--     ROW_NUMBER() OVER (PARTITION BY CATEGORY_ID ORDER BY LIST_PRICE desc) rn
--     FROM oe.product_information
--     where LIST_PRICE is not null
-- )
-- WHERE rn <= 3
-- ORDER BY CATEGORY_ID, LIST_PRICE DESC, PRODUCT_NAME;


-- SELECT EXTRACT(YEAR FROM ORDER_DATE) as YEAR, sum(ORDER_TOTAL) as TOTAL_COST_OF_ALL_ORDERS, 
--   sum(ORDER_TOTAL) - LAG(sum(ORDER_TOTAL)) OVER (
-- 		ORDER BY EXTRACT(YEAR FROM ORDER_DATE)
-- 	) LAST_YEARS_TOTAL_COST
-- FROM oe.orders
-- GROUP BY EXTRACT(YEAR FROM ORDER_DATE)
-- ORDER BY EXTRACT(YEAR FROM ORDER_DATE);


-- SELECT YEAR, MONTH, MONTH_TOTAL,
--   SUM(MONTH_TOTAL) OVER (
--   PARTITION BY YEAR
--   ORDER BY MONTH ASC) as RUNNING_TOTAL_COST
-- FROM 
-- (
--   select EXTRACT(YEAR FROM ORDER_DATE) as YEAR, EXTRACT(MONTH FROM ORDER_DATE) AS MONTH, sum(ORDER_TOTAL) as MONTH_TOTAL
--   from oe.orders
--   group by EXTRACT(MONTH FROM ORDER_DATE), EXTRACT(YEAR FROM ORDER_DATE)
--   order by EXTRACT(YEAR FROM ORDER_DATE), EXTRACT(MONTH FROM ORDER_DATE)
-- )
-- ORDER BY YEAR, MONTH;


--VIEWS--

-- CREATE VIEW EMPLOYEE_QUANTITY_BY_YEAR as
--   SELECT EXTRACT(YEAR FROM ord.ORDER_DATE) as YEAR, emp.EMPLOYEE_ID employee, SUM(orit.QUANTITY) as QUANT
--     FROM oe.orders ord, hr.employees emp, oe.order_items orit
--     WHERE emp.EMPLOYEE_ID = ord.SALES_REP_ID AND ord.ORDER_ID = orit.ORDER_ID
--     group by EXTRACT(YEAR FROM ord.ORDER_DATE), emp.EMPLOYEE_ID
--     order by EXTRACT(YEAR FROM ord.ORDER_DATE)


-- CREATE VIEW MAX_SALES_BY_EMP_PER_YEAR AS
--   select YEAR, max(QUANT) as QUANTITY
--     from EMPLOYEE_QUANTITY_BY_YEAR
--     GROUP BY YEAR
--     order by YEAR


-- CREATE VIEW BEST_SALES_REP_OF_THE_YEAR as
--   SELECT YEAR, employee
--   FROM (
--     select YEAR, employee, QUANT as QUANTITY, row_number() over (partition by YEAR order by QUANT desc) rn
--     from EMPLOYEE_QUANTITY_BY_YEAR
--   GROUP BY YEAR, employee, QUANT
--   )
--   WHERE rn = 1
--   order by YEAR, QUANTITY desc


-- CREATE VIEW INFO_PER_PRODUCT as
--   SELECT PRODUCT_ID, SUM(QUANTITY) as QUANTITY, SUM(UNIT_PRICE * QUANTITY) as PRICE
--     FROM oe.order_items
--     GROUP BY PRODUCT_ID


-- CREATE VIEW MOST_ORDERED_PRODUCT as
-- SELECT PRODUCT_ID, QUANTITY
--   FROM(
--     SELECT PRODUCT_ID, QUANTITY, row_number() over (order by QUANTITY desc) rn
--     from INFO_PER_PRODUCT
--   )
--   WHERE rn = 1
--   order by QUANTITY desc


-- CREATE VIEW MAX_INCOME_PRODUCT as
--   SELECT PRODUCT_ID, PRICE
--     FROM(
--       SELECT PRODUCT_ID, PRICE, row_number() over (order by PRICE desc) rn
--       from INFO_PER_PRODUCT
--     )
--     WHERE rn = 1
--     order by PRICE desc
