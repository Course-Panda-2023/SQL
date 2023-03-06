--YOUR CODE HERE

--SELECT
--1
SELECT PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE 
FROM CO.PRODUCTS 
order by PRODUCT_NAME 
-- 2
SELECT first_name, last_name, phone_number, CURRENT_DATE-EXTRACT(YEAR from hire_date) as year 
from HR.employees 
-- 3
SELECT first_name, last_name, salary
from HR.employees
where EXTRACT(YEAR from hire_date) > 2005
order by salary
-- 4
SELECT product_name
from oe.product_information
where list_price - min_price > 100
order by product_name

--JOIN TABLES
--3
SELECT cust.cust_first_name || ' ' || cust.cust_last_name AS full_name, prod_info.product_name
FROM oe.customers cust
INNER JOIN oe.orders ord ON cust.customer_id = ord.customer_id
INNER JOIN oe.order_items ord_items ON ord.order_id = ord_items.order_id
INNER JOIN oe.product_information prod_info ON ord_items.product_id = prod_info.product_id
WHERE extract(year from ord.order_date) = 2008 and ord_items.unit_price > 10
--4
SELECT cust.cust_first_name || ' ' || cust.cust_last_name AS full_name, prod_info.product_name
FROM oe.customers cust
INNER JOIN oe.orders ord ON cust.customer_id = ord.customer_id
INNER JOIN oe.order_items ord_items ON ord.order_id = ord_items.order_id
INNER JOIN oe.product_information prod_info ON ord_items.product_id = prod_info.product_id
WHERE extract(year from ord.order_date) = 2008 and ord_items.unit_price > 10

--5
select empl.first_name || ' ' || empl.last_name AS full_name, boss_empl.first_name || ' ' || boss_empl.last_name as boss_full_name
from hr.EMPLOYEES empl inner join hr.EMPLOYEES boss_empl on empl.manager_id = boss_empl.employee_id

--Aggregation 
--1
SELECT AVG(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM empl.hire_date)) AS avg_years_of_service
FROM hr.employees empl;

--3
SELECT Count(prod_info.product_id) as products_amount
from oe.product_information prod_info 
group by prod_info.supplier_id

--4
select sum(ord_items.QUANTITY)
from oe.order_items ord_items --inner join 
group by ord_items.PRODUCT_ID

--6
select TO_CHAR( order_date, 'D' ), count(ord.order_id) as ORDERS_NUM, sum(order_total) as ORDERS_TOTAL
from oe.orders ord
group by TO_CHAR( order_date, 'D' )
--7
SELECT empl.first_name || ' ' || empl.last_name AS full_name
FROM oe.orders ord 
INNER JOIN hr.employees AS empl ON ord.sales_rep_id = empl.employee_id
WHERE extract(year FROM ord.order_date) > 2007
GROUP BY empl.employee_id, empl.first_name, empl.last_name
HAVING count(ord.order_id) > 20000;

--Sub Quieries
--1
select prod_info.product_name
from oe.product_information prod_info
where prod_info.list_price = (
  select max(prod_info.list_price)
  from oe.product_information prod_info
)

--Analytic Functions
--1
select product_name, list_price, ROW_NUMBER, category_id
from (
  select product_name, list_price, category_id,
         row_number() over (partition by category_id
         order by list_price desc) as ROW_NUMBER
         from oe.product_information 
  )
--2  
select sum(order_total), extract(year from order_date), 
  sum(order_total) - LAG(sum(order_total)) over (order by extract(year from order_date)) as TOTAL_PRICE_DIFF
from oe.orders
group by extract(year from order_date)
order by extract(year from order_date) desc
--3
select  extract(month from order_date) as MONTH, extract(year from order_date) as YEAR, sum(order_total),
  sum(order_total) + LAG(sum(order_total)) over (order by extract(year from order_date), extract(month from order_date)) as RUNNING_PRICE 
    
from oe.orders
group by extract(year from order_date), extract(month from order_date)
order by extract(year from order_date), extract(month from order_date)
--Views
--1+2
CREATE OR REPLACE view first_view as
    select max(items_quantity) as MAX_NUM_SALES, sales_year
    from (
        select sum(QUANTITY) items_quantity, EXTRACT(YEAR FROM ord.order_date) AS sales_year, sales_rep_id
        from 
          oe.order_items ord_items inner join oe.orders ord on ord_items.order_id = ord.order_id 
          inner join hr.employees empl on ord.sales_rep_id = empl.employee_id 
        group by 
          EXTRACT(YEAR FROM ord.order_date), sales_rep_id
        order by
          EXTRACT(YEAR FROM ord.order_date)
    )
    group by
    sales_year
    order by
    sales_year;

select * 
from first_view

--PLSQL
--1 
DECLARE
  type varchar_varray is varray(3) of VARCHAR2(6);
  type number_varray is varray(4) of number;
  names varchar_varray := varchar_varray('may', 'june', 'july');
  numbers number_varray := number_varray(1,2,3,4);
BEGIN
  dbms_output.put_line('Hello, World!');
  IF LENGTH(names(1)) = 4 THEN
    dbms_output.put_line('THERE ARE FOUR CHARACTERS'); 
  ELSE 
    dbms_output.put_line('THERE IS NO FOUR CHARACTERS WORD');  
  END IF;  
  CASE numbers(numbers.COUNT) 
    WHEN 2 THEN
      dbms_output.put_line('the num is two');  
    WHEN 3 THEN
      dbms_output.put_line('the num is three'); 
    WHEN 4 THEN
      dbms_output.put_line('the num is four'); 
  END CASE;      
END;






