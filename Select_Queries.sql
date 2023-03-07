-- Select Queries

SELECT *
FROM  OE.Product_Information, HR.Employees;

SELECT *
FROM  OE.Product_Information;

  
SELECT 
  Product_Id AS Id,
  Product_Name AS Name,
  List_Price AS Price
FROM OE.Product_Information
ORDER BY
  Name;

SELECT 
  First_Name||'-'||Last_Name AS Name,
  Phone_Number AS Phone,
  Cast(Substr(trunc(sysdate, 'YEAR'), -2) AS INT) -
  Cast(Substr(Hire_Date, -2) AS INT) AS Number_Of_Years_Working_In_Company
FROM 
  HR.Employees;

SELECT 
  First_Name||' '||Last_Name AS FullName,
  Salary As Worker_Salary_Per_Month
From 
  HR.Employees
WHERE 
  Cast(Substr(trunc(sysdate, 'YEAR'), -2) AS INT) -
  Cast(Substr(Hire_Date, -2) AS INT) > 05
ORDER BY
  Salary ASC;

SELECT
  Product_Name AS Name
FROM 
  OE.Product_Information
WHERE
  Cast(List_Price AS INT) - Cast(Min_Price AS INT) > 100;

-- Join Tables
Select 
  *
From
  OE.Orders;
    
SELECT 
  Customer_Id AS Id,
  Cust_First_Name||'-'||Cust_Last_Name AS FullName,
  Order_Id As OrderID
FROM
  OE.Customers customers, OE.Orders orders
WHERE
  customers.Customer_Id = orders.Customer_Id;

