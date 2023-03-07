-- aggregation1
SELECT
  Round(Avg(JobHistory.End_Date - JobHistory.Start_Date) / 365 , 2) AS Average_Seniority
FROM
  HR.Job_History JobHistory;

-- aggergation3
SELECT
  Supplier_Id AS Id_Of_Supplier,
  ( 
    SELECT 
      Count(*)
    FROM
       OE.Product_Information ProductInformationInner
    WHERE
      ProductInformationInner.Supplier_Id = ProductInformationOuter.Supplier_Id
  )  AS Number_Of_Products
  
FROM
  OE.Product_Information ProductInformationOuter;


-- aggregation4
SELECT
  OrderItemsOuter.product_id,
  (
    SELECT
      Sum(Quantity)
    FROM
      OE.Order_Items OrderItemsInner
    WHERE
      OrderItemsInner.Product_Id = OrderItemsOuter.Product_Id
  ) AS Items_Ordered_From_Product
FROM
  OE.Order_Items OrderItemsOuter;

-- aggregation5
SELECT
  Extract(year from Orders.Order_Date) AS Order_Year,
  To_Char(Min(Orders.Order_Date), 'dd-month-yy') AS First_Order_Of_The_Year,
  To_Char(Max(Orders.Order_Date), 'dd-month-yy') AS Last_Order_Of_The_Year,
  Count(Orders.Order_Id) AS Number_Of_Orders,
  Sum(Orders.Order_Total) AS Total_Cost_Of_Orders
FROM
  OE.Orders Orders
GROUP BY
  Extract(year from Orders.Order_Date)
ORDER BY
  Order_Year;

-- aggregation6
SELECT
  To_Char(Orders.Order_Date, 'Day') AS Day_Of_Week,
  Count(Orders.Order_Id) AS Number_Of_Orders,
  Sum(Orders.Order_Total) AS Total_Cost_Of_Orders
FROM
  OE.Orders Orders
GROUP BY
  To_Char(Orders.Order_Date, 'Day')
ORDER BY
  Day_Of_Week;

-- aggregation7

SELECT
   Employees.First_Name || '-' || Employees.Last_Name AS FullName
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
  AND
  Extract(year from Orders.Order_Date) = 2007
GROUP BY
  Employees.First_Name || '-' || Employees.Last_Name
HAVING
  Sum(Orders.Order_Total) > 20000;
  
  -- aggregation 8

SELECT
  Customers.Cust_First_Name || '-' || Customers.Cust_Last_Name AS Name,
  Sum(Orders.Order_Total) / 1000 AS Oracle_Points_Own
FROM
  OE.Customers, OE.Orders
WHERE
  Customers.Customer_Id = Orders.Customer_Id
GROUP BY
  Customers.Cust_First_Name || '-' || Customers.Cust_Last_Name;