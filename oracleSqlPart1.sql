-- email: ezvmpxnshfhnjqmmik@tcwlm.com pass: Aa123456@
--SELECT QUERIES
--question 1
select PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE
from co.products
order by PRODUCT_NAME

--question 2
select 
  CONCAT(FIRST_NAME, LAST_NAME) AS FULL_NAME, 
  PHONE_NUMBER,
  EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM HIRE_DATE ) as Experiance_Years
from hr.employees

--question 3
SELECT 
  FIRST_NAME, 
  DEPARTMENT_ID,
  SALARY
FROM hr.employees
ORDER BY SALARY

--question 4
select 
  PRODUCT_NAME
from oe.product_information
where (LIST_PRICE - MIN_PRICE) > 100
order by PRODUCT_NAME

-- JOIN TABLES
--QUESTION 1
select 
  ords.CUSTOMER_ID,
  cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME as CUSTOMER_NAME,
  ords.ORDER_ID
from oe.orders ords
INNER JOIN oe.customers cust on cust.CUSTOMER_ID = ords.CUSTOMER_ID
WHERE EXTRACT(YEAR FROM ords.ORDER_DATE)  = 2007 and cust.CREDIT_LIMIT BETWEEN 200 and 700
ORDER by cust.CUST_FIRST_NAME, ords.ORDER_ID

--questions 2
select 
  prd.PRODUCT_NAME,
  prd.LIST_PRICE,
  cat.CATEGORY_NAME
from oe.product_information prd
INNER JOIN oe.categories_tab cat on cat.CATEGORY_ID = prd.CATEGORY_ID
order by cat.CATEGORY_NAME

--question 3
SELECT
  cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME as CUSTOMER_NAME,
  prd.PRODUCT_NAME
from oe.customers cust
INNER JOIN oe.ORDERS ords ON ords.CUSTOMER_ID = cust.CUSTOMER_ID
INNER JOIN oe.ORDER_ITEMS orditm ON orditm.order_id = ords.order_id
INNER JOIN oe.PRODUCT_INFORMATION prd ON prd.PRODUCT_ID = orditm.PRODUCT_ID
WHERE prd.LIST_PRICE > 10

--question 4
SELECT 
	ordsitm.UNIT_PRICE * ordsitm.QUANTITY as TOTAL_PRICE,
	prd.PRODUCT_NAME
from oe.ORDER_ITEMS ordsitm
INNER JOIN oe.PRODUCT_INFORMATION prd on prd.PRODUCT_ID = ordsitm.PRODUCT_ID
INNER JOIN oe.ORDERS ords on ords.ORDER_ID = ordsitm.ORDER_ID
WHERE extract(year from ords.ORDER_DATE) > 2007

--question 5
SELECT 
  emp.FIRST_NAME ||' '|| emp.LAST_NAME as EMPLOYEE_NAME,
  man.FIRST_NAME ||' '|| man.LAST_NAME as MANAGER_NAME
FROM hr.EMPLOYEES emp INNER JOIN hr.EMPLOYEES man on emp.MANAGER_ID = man.EMPLOYEE_ID

--Aggregation Functions
--Question 1
select ROUND(EXTRACT(YEAR FROM CURRENT_DATE) - AVG(EXTRACT(year from emp.HIRE_DATE)))
  as SENIORITY_YEARS_AVG
from hr.employees emp

--question 2
---------------------------------------

--question 3
SELECT prd.SUPPLIER_ID, 
	count(prd.PRODUCT_ID) AS NUMBER_OF_PRODUCTS
from oe.PRODUCT_INFORMATION prd
GROUP by prd.SUPPLIER_ID

--QUESTION 4
SELECT ordsitm.PRODUCT_ID,
	SUM(ordsitm.quantity) as total_quantity_ordered
from oe.ORDER_ITEMS ordsitm
GROUP BY ordsitm.PRODUCT_ID

--question 5
SELECT 
    EXTRACT(YEAR FROM ORDER_DATE) AS YEAR,
	MIN(ords.ORDER_DATE) AS FIRST_ORDER,
	MAX(ords.ORDER_DATE) AS LAST_ORDER,
	SUM(ords.ORDER_ID) AS NUMBER_OF_ORDERS,
    SUM(ords.ORDER_TOTAL) AS TOTAL_REVENUE
FROM OE.ORDERS ords
GROUP BY EXTRACT(YEAR FROM ORDER_DATE)

--Question 6
select 
  TO_CHAR(ords.ORDER_DATE, 'DAY') as WEEKDAY,
  count(ords.order_id) as number_of_orders,
  sum(ords.order_total) as total_order_sum
FROM OE.ORDERS ords
GROUP BY TO_CHAR(ords.ORDER_DATE, 'DAY')

--question 7
SELECT
  emp.FIRST_NAME ||' '|| emp.LAST_NAME as EMPLOYEE_NAME
from hr.EMPLOYEES emp
inner join oe.orders ords on ords.sales_rep_id = emp.employee_id
where  EXTRACT(YEAR FROM ORDER_DATE) = 2007
GROUP BY emp.FIRST_NAME ||' '|| emp.LAST_NAME
having sum(ords.order_total)>20000

--question 8
SELECT
	cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME as CUSTOMER_NAME,
	SUM(ords.order_total)/1000 as Oracle_points
from oe.customers cust
inner join oe.ORDERS ords on ords.customer_id = cust.customer_id
group by cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME

--SUB QUERIES
--Question 1
SELECT prd.PRODUCT_NAME
from oe.product_information prd
WHERE prd.list_price = (SELECT max(prd.list_price)
FROM oe.product_information prd)

--question 2
SELECT prd.PRODUCT_NAME
from oe.product_information prd
WHERE prd.list_price = (SELECT max(prd.list_price)
FROM oe.product_information prd
inner join oe.order_items orditm ON orditm.product_id = prd.product_id
inner join oe.orders ords on ords.order_id = orditm.order_id)

--question 3
SELECT prd.product_name
FROM oe.product_information prd
WHERE prd.list_price > (SELECT round(AVG(prd.list_price))
						from oe.product_information prd)
						
--question 4
select orditm.product_id
from OE.orders ord
inner join oe.ORDER_ITEMS orditm on orditm.order_id = ord.order_id
where ord.sales_rep_id = (select emp.employee_id 
from hr.employees emp
where emp.hire_date = (SELECT min(emp.hire_date)
from hr.employees emp
WHERE emp.job_id ='SA_REP'))

--Question 5
SELECT distinct orditm.product_id
from oe.order_items orditm
WHERE  orditm.order_id IN (SELECT orditm.order_id
							from oe.order_items orditm
							WHERE orditm.product_id = (SELECT prd.product_id
													from oe.product_information prd
													WHERE prd.list_price = (SELECT max(prd.list_price)
																			FROM oe.product_information prd
																			inner join oe.order_items orditm ON orditm.product_id = prd.product_id
																			inner join oe.orders ords on ords.order_id = orditm.order_id)))
																			
---ANALITICS
--question 1
select PRODUCT_NAME, LIST_PRICE, CATEGORY_ID, PRICE_RANK
from 
  (select prd.PRODUCT_NAME, prd.LIST_PRICE, prd.CATEGORY_ID,
  RANK() over (partition by prd.category_ID
  ORDER BY prd.LIST_PRICE DESC) AS PRICE_RANK
  FROM oe.product_information prd
  where prd.LIST_PRICE IS NOT NULL)
where PRICE_RANK <= 3

--Question 2
SELECT 
	extract(year from ords.order_date) as year, 
    SUM(ords.order_total) AS CURR_YEAR_SUM,
	SUM(ords.order_total) - LAG(SUM(ords.order_total)) over (ORDER BY extract(year from ords.order_date)) as TOTAL_ORDERS_YEAR_DIFF
from oe.orders ords
group by extract(year from ords.order_date)

--question 3
SELECT distinct 
  sum(ords.order_total) over
  (partition by extract(year from ords.ORDER_DATE)
  order by extract(month from ords.ORDER_DATE)) as YEARLY_RUNNING_TOTAL,
  monttl.order_total as montly_total,
  TO_CHAR(ords.ORDER_DATE, 'MONTH') as month_name,
  extract(month from ords.ORDER_DATE) as months,
  extract(year from ords.ORDER_DATE) as years
from oe.orders ords
inner join (SELECT distinct
  extract(year from ords.ORDER_DATE) as years,
  extract(month from ords.ORDER_DATE) as months,
  SUM(ords.order_total) as order_total
from oe.orders ords
group by extract(year from ords.ORDER_DATE), extract(month from ords.ORDER_DATE)
order by extract(year from ords.ORDER_DATE), extract(month from ords.ORDER_DATE)) monttl
  on (monttl.months||monttl.years=extract(month from ords.ORDER_DATE)||extract(year from ords.ORDER_DATE))
order by extract(year from ords.ORDER_DATE)

--VIEWS
--QUESTION 1
CREATE VIEW SALESMAN_SALES AS
select extract(year from ord.order_date) as year
  ,ord.sales_rep_id as salesman_id,
  count(ord.order_id) as orders_sold
from oe.orders ord
where ord.sales_rep_id is not null
group by ord.sales_rep_id, extract(year from ord.order_date)

CREATE VIEW MOST_SALES AS
SELECT MAX(SAL.orders_sold) as MOST_SALES, SAL.year
FROM SALESMAN_SALES SAL
GROUP BY SAL.year
order by SAL.year

select SAL.YEAR, SAL.SALESMAN_ID, SAL.ORDERS_SOLD
from SALESMAN_SALES SAL
inner join MOST_SALES MSTSAL on MSTSAL.MOST_SALES = SAL.orders_sold 
  AND SAL.year = MSTSAL.year

--question 2
select SAL.YEAR, SAL.SALESMAN_ID, SAL.ORDERS_SOLD
from SALESMAN_SALES SAL
inner join MOST_SALES MSTSAL on MSTSAL.MOST_SALES = SAL.orders_sold 
  AND SAL.year = MSTSAL.year
  
--Question 3
CREATE VIEW PRODUCT_SALES AS
SELECT sum(orditm.quantity) as amount_bought,
  orditm.product_id
from oe.order_items orditm
group by orditm.product_id

select PRODUCT_SALES.product_id
from PRODUCT_SALES
where PRODUCT_SALES.amount_bought = (select max(prdsal.amount_bought)
                                      from PRODUCT_SALES prdsal)
									  
--question 4
CREATE VIEW PRODUCT_INCOMES AS
SELECT prdsal.amount_bought * orditm.unit_price as total_income,
		prdsal.product_id
FROM PRODUCT_SALES prdsal, oe.order_items orditm
WHERE prdsal.product_id = orditm.product_id

SELECT distinct prdinc.product_id
FROM PRODUCT_INCOMES prdinc
where prdinc.total_income = (select max(PRODUCT_INCOMES.total_income)
							from PRODUCT_INCOMES);

--pgsql
--question 1
declare
full_name varchar2(10) := 'razbroc';
begin
  dbms_output.put_line(full_name);
end;
/

--question 2
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  dbms_output.put_line(names_array(1));
  dbms_output.put_line(numbers_array(1));
  dbms_output.put_line(names_array(names_array.last));
  dbms_output.put_line(numbers_array(numbers_array.last));
  names_array.EXTEND(2);
  names_array(names_array.last) := 'kfir';
  dbms_output.put_line(names_array(names_array.last));
end;
/

--question 3
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  dbms_output.put_line(names_array(1));
  dbms_output.put_line(numbers_array(1));
  dbms_output.put_line(names_array(names_array.last));
  dbms_output.put_line(numbers_array(numbers_array.last));

  if (LENGTH(names_array(1)) = 4) then
    dbms_output.put_line('there are four chars');
  else
    dbms_output.put_line('not four letters');
  end if;

end;
/

--question 4
--version 1
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  dbms_output.put_line(names_array(1));
  dbms_output.put_line(numbers_array(1));
  dbms_output.put_line(names_array(names_array.last));
  dbms_output.put_line(numbers_array(numbers_array.last));

  if (numbers_array(numbers_array.last) = 2) then
    dbms_output.put_line('number is 2');
elseif (numbers_array(numbers_array.last) = 3) then
      dbms_output.put_line('number is 3');
elseif (numbers_array(numbers_array.last) = 4) then
      dbms_output.put_line('number is 4');
end if;

end;
/

--version 2
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  dbms_output.put_line(names_array(1));
  dbms_output.put_line(numbers_array(1));
  dbms_output.put_line(names_array(names_array.last));
  dbms_output.put_line(numbers_array(numbers_array.last));

  case numbers_array(numbers_array.last) 
    when 2 then
    dbms_output.put_line('number is 2');
    when 3 then
      dbms_output.put_line('number is 3');
    when 4 then
      dbms_output.put_line('number is 4');
  end case;
end;
/

--question 5
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  for i in 1..names_array.count loop
    dbms_output.put_line(names_array(i));
  end loop;
end;
/

--question 6
declare
type string_array is VARRAY(3) of varchar2(200);
type num_array is VARRAY(4) of number;

names_array string_array := string_array('משה', 'יוסי', 'אבנר');
numbers_array num_array := num_array(1,2,3,4);
begin
  for wordIndex in 1..names_array.count loop
      dbms_output.put_line(SUBSTR(names_array(wordIndex),1,wordIndex));
  end loop;
end;
/

--question 7
--version 1
declare
fullname oe.customers.cust_first_name%type;
firstname oe.customers.cust_first_name%type;
lastname oe.customers.cust_last_name%type;
cursor c_cust is select cust_first_name, cust_last_name from oe.customers cut;
  
begin
open c_cust;
loop
  fetch c_cust into firstname, lastname;
  fullname := firstname || ' ' || lastname;
  exit when c_cust%notfound;
    dbms_output.put_line(fullname);
end loop;
close c_cust;
end;
/

--version 2
declare
fullname oe.customers.cust_first_name%type;

begin
  for cust in (select cust_first_name, cust_last_name from oe.customers) loop
    fullname := cust.cust_first_name || ' ' || cust.cust_last_name;
    dbms_output.put_line(fullname);
  end loop;
end;
/

--question 8
--version 1
begin
  for cust in (select cust_first_name, cust_last_name from oe.customers) loop
    IF LENGTH(cust.cust_first_name) = LENGTH(cust.cust_last_name) then
		dbms_output.put_line(cust.cust_first_name || ' ' || cust.cust_last_name);
	end IF;
  end loop;
end;

--version 2
begin
  for cust in (select cust_first_name, cust_last_name from oe.customers where LENGTH(cust_first_name) = LENGTH(cust_last_name)) loop
	dbms_output.put_line(cust.cust_first_name || ' ' || cust.cust_last_name);
  end loop;
end;