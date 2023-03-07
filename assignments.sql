
select query
-- select PRODUCT_ID,PRODUCT_NAME,LIST_PRICE,MIN_PRICE
-- from oe.product_information
-- order by PRODUCT_NAME

-- select FIRST_NAME||' '|| LAST_NAME as full_name,
--        PHONE_NUMBER as Phone,
--        TRUNC(months_between(sysdate, HIRE_DATE) / 12) AS num_of_years
-- from hr.employees

-- select FIRST_NAME||' '|| LAST_NAME as full_name, SALARY	as salary
-- --select *
-- from hr.employees
-- where HIRE_DATE >= date'2005-01-01'
-- order by salary desc

-- select PRODUCT_NAME
-- from oe.product_information
-- where LIST_PRICE-MIN_PRICE>100
-- order by PRODUCT_NAME
join tables
--1
-- select cust.CUSTOMER_ID	as id, cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME as full_name, ord.ORDER_ID as order_id
-- from oe.CUSTOMERS cust
-- inner join oe.ORDERS ord on ord.CUSTOMER_ID = cust.CUSTOMER_ID
-- where ord.ORDER_DATE between date '2007-01-01' and date '2007-12-31';

--3
-- select cust.CUSTOMER_ID	as id, cust.CUST_FIRST_NAME ||' '|| cust.CUST_LAST_NAME as full_name, orderIt.PRODUCT_ID as prod_id
-- from oe.CUSTOMERS cust
-- inner join oe.ORDERS ord on ord.CUSTOMER_ID = cust.CUSTOMER_ID
-- inner join oe.ORDER_ITEMS orderIt on orderIt.ORDER_ID = ord.ORDER_ID
-- where ord.ORDER_DATE between date '2008-01-01' and date '2008-12-31' and orderIt.UNIT_PRICE>10;

--5
-- select employ.FIRST_NAME ||' '|| employ.LAST_NAME as employ_name, menger.FIRST_NAME ||' '|| menger.LAST_NAME as meneger_name
-- from hr.EMPLOYEES employ
-- inner join hr.EMP_DETAILS_VIEW menger on menger.EMPLOYEE_ID = employ.MANAGER_ID

aggregation
--1
select AVG(TRUNC(months_between(sysdate, HIRE_DATE) / 12)) AS num_of_years
from hr.employees

--3
select SUPPLIER_ID, COUNT(PRODUCT_ID) num_product
from oe.PRODUCT_INFORMATION
GRoup by SUPPLIER_ID;

--4
select PRODUCT_ID, SUM(QUANTITY) total_QUANTITY
from oe.ORDER_ITEMS
GRoup by PRODUCT_ID;
--5
select ORDER_DATE
from oe.ORDERs prod
select extract(year from order_data) as years,count(order_id),sum(order_total),max(order_data),min(order_date)
from orders
group by extract(year from order_date)
order by year



--6
select SALES_REP_ID as sales_id ,sum(ORDER_TOTAL) as total_order
from oe.ORDERS
where extract(year from ORDER_DATE) = 2007 
group by SALES_REP_ID
having sum(ORDER_TOTAL)>20000;

--7
select CUSTOMER_ID	,sum(ORDER_TOTAL)/1000
from oe.ORDERS
group by CUSTOMER_ID
sub queries
--1
select PRODUCT_NAME
from oe.PRODUCT_INFORMATION
where LIST_PRICE = (
  select max(LIST_PRICE)
from oe.PRODUCT_INFORMATION
) ;
--2
select PRODUCT_NAME
from oe.PRODUCT_INFORMATION
where PRODUCT_ID = (
  select DISTINCT PRODUCT_ID from oe.ORDER_ITEMS
where UNIT_PRICE = (
  select max(UNIT_PRICE)
from oe.ORDER_ITEMS
) 
) ;
--3
select PRODUCT_NAME
from oe.PRODUCT_INFORMATION
where LIST_PRICE > (
select avg(LIST_PRICE) from oe.PRODUCT_INFORMATION
) ;

--4
select PRODUCT_NAME from oe.PRODUCT_INFORMATION
where PRODUCT_ID in (
select PRODUCT_ID from oe.ORDER_ITEMS
where ORDER_ID in (
select ORDER_ID from oe.ORDERS
where SALES_REP_ID =(
select EMPLOYEE_ID
from hr.employees emp
where TRUNC(months_between(sysdate, HIRE_DATE) / 12) = (select max(num_of_years) from 
  (select EMPLOYEE_ID,TRUNC(months_between(sysdate, HIRE_DATE) / 12) AS num_of_years
  from hr.employees emp
  inner join oe.ORDERS ord on emp.EMPLOYEE_ID = ord.SALES_REP_ID))
  and EMPLOYEE_ID in
  (select EMPLOYEE_ID
  from hr.employees emp
  inner join oe.ORDERS ord on emp.EMPLOYEE_ID = ord.SALES_REP_ID))));
  
 --5
select distinct PRODUCT_ID from oe.ORDER_ITEMS
where ORDER_ID in (
	select ORDER_ID from oe.ORDER_ITEMS
	where PRODUCT_ID = 
		(select PRODUCT_ID
		 from oe.PRODUCT_INFORMATION
		 where PRODUCT_ID = (
			 select DISTINCT PRODUCT_ID from oe.ORDER_ITEMS
			 where UNIT_PRICE = (
			 select max(UNIT_PRICE)
			from oe.ORDER_ITEMS
								) 
							)
		)
				);

Analytic function
--1
SELECT * FROM 
(
    SELECT PRODUCT_NAME,CATEGORY_ID,LIST_PRICE
    ,row_number() over (partition by CATEGORY_ID order by LIST_PRICE desc) tabel
    from oe.PRODUCT_INFORMATION
    where LIST_PRICE is not null
) t
WHERE tabel <=3;


--2
select distinct YEARS, TOTAL,
    TOTAL -lAg(TOTAL)  over(order by YEARS) as diff
  from
  (
  select distinct TO_CHAR(ORDER_DATE, 'YYYY') as years,
     sum(ORDER_TOTAL) over(partition by TO_CHAR(ORDER_DATE, 'YYYY')) total
  from oe.ORDERS
  order by years
  );

--3
select distinct TO_CHAR(ORDER_DATE, 'yyyy') as years, TO_CHAR(ORDER_DATE, 'mm') as monthe,
      sum(ORDER_TOTAL)
	  over(partition by TO_CHAR(ORDER_DATE, 'yyyy') order by TO_CHAR(ORDER_DATE, 'yyyy'),TO_CHAR(ORDER_DATE, 'mm')) diff
from oe.ORDERS
order by years,monthe;

Views
--1
CREATE VIEW num_of_items AS
select distinct years,max(diff)over(partition by years) as num_of_items
from(
select distinct TO_CHAR(ORDER_DATE, 'yyyy') as years,
      sum(ORDER_TOTAL)
	  over(partition by SALES_REP_ID order by TO_CHAR(ORDER_DATE, 'yyyy')) diff
from oe.ORDERS)
order by years;

מחזיר את הרשימה עבור כל סוכן כמה מכר
select distinct 
  TO_CHAR(ORDER_DATE, 'yyyy') as years,
  sum(ORDER_TOTAL) over(partition by SALES_REP_ID ,TO_CHAR(ORDER_DATE, 'yyyy')) as diff,
  SALES_REP_ID
from oe.ORDERS 
where (years,diff) in (select years,num_of_items from num_of_items)
order by years;


declare
  type VARCHAR_array is varray(3) of varchar(6);
  type numbers_arr is varray(4) of number;
  namess VARCHAR_array  := VARCHAR_array('may','june','july');
  numsss numbers_arr := numbers_arr(1,2,3,4);
  number a :=1;
  --name VARCHAR2(10) :='omri';
begin
  -- dbms_output.put_line(namess(1));
  -- dbms_output.put_line(numsss(1));
  -- dbms_output.put_line(namess(namess.last));
  -- dbms_output.put_line(numsss(namess.last));
  -- dbms_output.put_line(namess.last);
  --namess.extend;
  --namess[namess.last] := 'kfir';
    -- if LENGTH(namess(1)) = 4 then 
    --   dbms_output.put_line('there are four characters');
    -- else
    --   dbms_output.put_line('this is not are four characters');
    -- end if;

    -- case numsss(namess.last)
    -- when  2 then 
    --   dbms_output.put_line('number is tow');
    -- when 3 then 
    --   dbms_output.put_line('number is three');
    -- when 4 then 
    --   dbms_output.put_line('number is four');
    -- else
    --   dbms_output.put_line('bad number');
    -- end case;
    -- while a <= namess.count loop
    --   dbms_output.put_line(namess(a));
    --   a:= a+1;
    -- end loop;
  for i in 1..namess.count loop
    dbms_output.put_line(substr(namess(i),1,i));
  end loop;  
end;





  namess VARCHAR_array  := VARCHAR_array('may','june','july');
  numsss numbers_arr := numbers_arr(1,2,3,4);
  c_firs_name oe.CUSTOMERS.CUST_FIRST_NAME%type;
  c_last_name oe.CUSTOMERS.CUST_lsat_NAME%type;
  -- cursor
  --number a :=1;
  --name VARCHAR2(10) :='omri';
  cursor nams_c is select CUST_FIRST_NAME,CUST_LAST_NAME from oe.CUSTOMERS;
begin
  loop 
  fetch names_c into c_firs_name,c_last_name;
  exit when names_c%notfuond
    dbms_output.put_line(c_firs_name ||' '|| c_last_name);
  end loop;
  for r in (select CUST_FIRST_NAME as first_name,CUST_LAST_NAME as last_name from oe.CUSTOMERS) loop
    if LENGTH(r.first_name) = LENGTH(r.last_name) then
      dbms_output.put_line(r.first_name ||' '|| r.last_name);
    end if;
  end loop;
