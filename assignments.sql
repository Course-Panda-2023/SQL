--------------------------------------------------------------------- SELECT


-- Query 1  
SELECT PRODUCT_ID, PRODUCT_NAME, LIST_PRICE, MIN_PRICE
FROM oe.product_information
ORDER BY PRODUCT_NAME DESC


-- Query 2 
SELECT first_name || ' ' || last_name as full_name, phone_number,  FLOOR((SYSDATE - hire_date)/365) as years_worked
FROM hr.employees 


-- Query 3
SELECT first_name || ' ' || last_name as full_name, salary
FROM hr.employees
WHERE  hire_date - date'2005-01-01' >= 0
ORDER BY salary


-- Query 4
SELECT product_name
FROM oe.product_information
WHERE list_price - min_price > 100
ORDER BY product_name


--------------------------------------------------------------------- JOIN

-- product_information: PRODUCT_NAME, LIST_PRICE, CATEGORY_ID
-- categories_tab CATEGORY_NAME, CATEGORY_ID

-- Query 1
SELECT cust.customer_id, cust.cust_first_name || ' ' || cust.cust_last_name as full_name, ord.order_id
from oe.orders ord INNER JOIN oe.customers cust ON ord.customer_id = cust.customer_id
where to_char(order_date, 'yyyy') = 2007 and credit_limit BETWEEN 200 AND 700
ORDER BY cust_first_name, cust_last_name, ord.order_id


-- Query 2
SELECT pi.product_name, pi.list_price, ct.category_name 
FROM oe.product_information pi INNER JOIN oe.categories_tab ct ON pi.category_id = ct.category_id
ORDER BY ct.category_name 


-- Query 3 
SELECT cust.cust_first_name || ' ' || cust.cust_last_name as full_name, pi.product_name 
FROM oe.customers cust INNER JOIN oe.orders ord 
    ON cust.customer_ID = ord.customer INNER JOIN oe.order_items oi 
    ON ord.order_id = oi.order_id INNER JOIN oe.product_information pi 
    ON oi.product_id = pi.product_id 
WHERE to_char(ord.order_date, 'yyyy') = 2008 AND oi.unit_price > 10 

-- Query 4
SELECT ord.order_id, pi.product_name, oi.unit_price * oi.quantity as unit_price 
FROM oe.orders ord INNER JOIN oe.order_items oi 
    ON ord.order_id = oi.order_id INNER JOIN oe.product_information pi 
    ON oi.product_id = pi.product_id 
WHERE to_char(ord.order_date, 'yyyy') = 2007 


-- Query 5
SELECT emp1.first_name || ' ' || emp1.last_name as employee_full_name, 
      emp2.first_name || ' ' || emp2.last_name as manager_full_name 
FROM hr.employees emp1 LEFT JOIN hr.employees emp2 ON emp1.manager_id = emp2.employee_id 



------------------------------ Aggregation

-- Query 1
SELECT FLOOR(AVG(SYSDATE - hire_date)/365) as average_seniority_in_years 
FROM hr.employees 


-- Query 3
SELECT supplier_id, COUNT(*) as number_of_products 
FROM OE.product_information 
GROUP BY supplier_id

-- Query 4
SELECT product_id, SUM(quantity) as total_items  
FROM oe.order_items 
GROUP BY product_id


-- Query 5
SELECT EXTRACT(YEAR FROM order_date) as year_orders, 
  MIN(order_date) as first_order, 
  MAX(order_date) as last_order, 
  COUNT(order_id) as number_of_orders, 
  SUM(order_total) as total_cost 
FROM oe.orders 
GROUP BY EXTRACT(YEAR FROM order_date) 
ORDER BY year_orders 


-- Query 6
SELECT TO_CHAR(order_date, 'DAY') as day_of_orders, 
  COUNT(order_id) as number_of_orders, 
  SUM(order_total) as total_cost 
FROM oe.orders 
GROUP BY TO_CHAR(order_date, 'DAY') 

-- Query 7
SELECT emp.employee_id, SUM(ord.order_total) as total_sales 
FROM oe.orders ord INNER JOIN hr.employees emp ON ord.sales_rep_id = emp.employee_id 
WHERE EXTRACT(YEAR FROM ord.order_date) = 2007 
GROUP BY emp.employee_id 
HAVING SUM(ord.order_total) > 20000


-- Query 8
SELECT cust.customer_id, FLOOR(SUM(order_total)/1000) as oracle_points 
FROM oe.customers cust INNER JOIN oe.orders ord ON cust.customer_id = ord.customer_id 
GROUP BY cust.customer_id


------------------------------ Aggregation

-- Query 1
SELECT product_name, list_price 
FROM oe.product_information 
WHERE list_price in (SELECT MAX(list_price) 
                      FROM oe.product_information)


-- Query 2
SELECT product_name, list_price 
FROM oe.product_information 
WHERE list_price in (SELECT MAX(pi.list_price) 
                      FROM oe.product_information pi INNER JOIN oe.order_items oi ON pi.product_id = oi.product_id) 
 

-- Query 3
SELECT product_name, list_price 
FROM oe.product_information 
WHERE list_price > (SELECT AVG(list_price) 
                      FROM oe.product_information) 
ORDER BY list_price 
 

-- Query 4
SELECT product_id 
FROM oe.orders ord INNER JOIN oe.order_items oi ON ord.order_id = oi.order_id  
WHERE ord.sales_rep_id in (SELECT employee_id 
                        FROM hr.employees 
                        WHERE hire_date in(SELECT MIN(emp.hire_date) 
                                            FROM oe.orders ord INNER JOIN hr.employees emp ON ord.sales_rep_id = emp.employee_id 
                                            ) 
                      ) 


-- Query 5
SELECT UNIQUE(product_id) as wanted_products 
FROM oe.order_items  
WHERE order_id in (SELECT oi.order_id 
                    FROM oe.product_information pi INNER JOIN oe.order_items oi ON pi.product_id = oi.product_id 
                    WHERE pi.list_price in (SELECT MAX(pi.list_price) 
                                            FROM oe.product_information pi INNER JOIN oe.order_items oi ON pi.product_id = oi.product_id 
                                            ) 
                  ) 
ORDER BY wanted_products 
  

-------------------------------- Analytics

-- Query 1

SELECT category_id, product_id
FROM (
  SELECT category_id,
  product_id,
  row_number() OVER (PARTITION BY category_id ORDER BY list_price DESC) rn
FROM oe.product_information pi
)
WHERE rn <= 3;


-- Query 2

SELECT SUM(order_total) as orders_total,
  EXTRACT(YEAR FROM order_date) as years,
  SUM(order_total)-lead(SUM(order_total), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date) DESC) diff
FROM oe.orders
GROUP BY EXTRACT(YEAR FROM order_date)


-- Query 3

SELECT orders_total,
  year,
  month,
  SUM(orders_total) OVER (PARTITION BY year ORDER BY month) cumulative
FROM (SELECT SUM(order_total) as orders_total,
              TO_CHAR(order_date, 'yyyy') as year,
              TO_CHAR(order_date, 'MM') as month
      FROM oe.orders
      GROUP BY TO_CHAR(order_date, 'yyyy'), TO_CHAR(order_date, 'MM')
      )


---------------------- Views

-- Query 1

CREATE VIEW REP_SALES_YEARLY AS
SELECT 
  EXTRACT(YEAR FROM ord.order_date) as years,
  ord.sales_rep_id,
  SUM(oi.quantity) as sum
FROM oe.order_items oi 
  INNER JOIN oe.orders ord 
  ON oi.order_id = ord.order_id
WHERE ord.sales_rep_id IS NOT null
GROUP BY EXTRACT(YEAR FROM ord.order_date), ord.sales_rep_id


CREATE VIEW MAX_REP_SALES_YEARLY AS
SELECT
  years,
  MAX(sum) as max_rep_sales
FROM REP_SALES_YEARLY
GROUP BY years
ORDER BY years


-- Query 2

CREATE VIEW REP_WITH_MAX_SALES_YEARLY AS
SELECT mrsy.years,
  sales_rep_id,
  MAX_REP_SALES
FROM MAX_REP_SALES_YEARLY mrsy INNER JOIN REP_SALES_YEARLY rsy ON mrsy.years = rsy.years AND mrsy.MAX_REP_SALES = rsy.sum 
ORDER BY years DESC


-- Query 3

CREATE VIEW TOP_ORDERED_PRODUCT AS
SELECT
  product_id,
  SUM(quantity) as number_ordered
FROM oe.order_items
GROUP BY product_id
ORDER BY number_ordered DESC
FETCH FIRST 1 ROW only

-- Query 4

CREATE VIEW TOP_INCOME_PRODUCT AS
SELECT
  product_id,
  SUM(quantity*unit_price) as income_made
FROM oe.order_items
GROUP BY product_id
ORDER BY income_made DESC
FETCH FIRST 1 ROW only





----- PLSQL


-- Question 1

declare
  full_name varchar2(20); 
begin
  full_name := 'Shahar Hillel';
  dbms_output.put_line(full_name);
end;


-- Question 2 + 3 + 4

declare
  TYPE namearray IS VARRAY(3) OF VARCHAR2(200);
  TYPE numberarray IS VARRAY(4) OF NUMBER; 
  names namearray;
  numbers numberarray;
begin
  names := namearray('Shahar', 'Ilan', 'Raz');
  numbers := numberarray(1, 2, 3, 4);  
  
  -- Q2-1
  dbms_output.put_line('Q2-1');
  dbms_output.put_line(numbers(1) || ' ' || names(1));
  -- Q2-2
  dbms_output.put_line('Q2-2');
  dbms_output.put_line(numbers(numbers.LAST) || ' ' || names(names.LAST));

  -- Q3-1
  dbms_output.put_line('Q3-1');
  IF LENGTH(names(1)) = 4 THEN
    dbms_output.put_line('THERE ARE FOUR CHARACTERS');
  ELSE
    dbms_output.put_line('THERE ARE NOT FOUR CHARACTERS');
  END IF;

  -- Q3-2
  dbms_output.put_line('Q3-2');
  CASE numbers(numbers.LAST)
    WHEN 2 THEN dbms_output.put_line('number is two');
    WHEN 3 THEN dbms_output.put_line('number is three');
    WHEN 4 THEN dbms_output.put_line('number is four');
    ELSE dbms_output.put_line('bad number');
  END CASE;

  -- Q4-1
  dbms_output.put_line('Q4-1');
  FOR counter IN 1..names.COUNT LOOP
    dbms_output.put_line(names(counter));
  END LOOP;

  -- Q4-2
  dbms_output.put_line('Q4-2');
  FOR counter IN 1..names.COUNT LOOP
    dbms_output.put_line(SUBSTR(names(counter), 1, counter));
  END LOOP;
end;


-- Question 5v1
declare
  full_name VARCHAR2(200);
  l_fname oe.customers.CUST_FIRST_NAME%type;
  CURSOR cust_names IS SELECT CUST_FIRST_NAME || ' ' || CUST_LAST_NAME FROM oe.customers;
begin
  OPEN cust_names;
  LOOP
    FETCH cust_names INTO l_fname;
    EXIT WHEN cust_names%notfound;
      dbms_output.put_line('Full customer name: ' || l_fname);
  END LOOP;
  CLOSE cust_names;
end;

-- Question 5v2
declare
  full_name VARCHAR2(200);
begin
  FOR cust IN (SELECT CUST_FIRST_NAME, CUST_LAST_NAME FROM oe.customers) LOOP
    full_name := cust.CUST_FIRST_NAME || ' ' || cust.CUST_LAST_NAME;
    dbms_output.put_line('Full customer name: ' || full_name);
  END LOOP;
end;


-- Question 6
begin
  FOR cust IN (SELECT CUST_FIRST_NAME || ' ' || CUST_LAST_NAME AS full_name
              FROM oe.customers
              WHERE LENGTH(CUST_FIRST_NAME) = LENGTH(CUST_LAST_NAME)) LOOP
    dbms_output.put_line('Full customer name: ' || cust.full_name);
  END LOOP;
end;

