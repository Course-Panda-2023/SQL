SELECT 
  *
FROM
  OE.Orders;

SELECT
  *
FROM
  OE.Customers Customers, OE.Orders Orders;

-- Join1
SELECT 
  Customers.Customer_Id AS Id,
  Cust_First_Name||'-'||Cust_Last_Name AS FullName,
  Order_Id AS OrderID
FROM
  OE.Customers Customers, OE.Orders Orders
WHERE
  Customers.Customer_Id = Orders.Customer_Id and
  Extract(year from Orders.Order_Date) = 2007 and
  Customers.Credit_Limit between 200 and 700;
ORDER BY
  FullName, OrderID;

SELECT
  *
FROM
  OE.Product_information Products;

SELECT 
  *
FROM
  OE.Categories_Tab;

-- Join2
SELECT
  Products.Product_Name AS ProductName,
  Products.List_Price AS Price,
  Categories.Category_Name AS CategoryName
FROM
  OE.Categories_Tab Categories, OE.Product_information Products
WHERE
  Categories.Category_Id = Products.Category_Id
ORDER BY
  Categories.Category_Name;

SELECT 
  *
FROM
  OE.Product_information;  

-- Join3
SELECT
  Cust_First_Name || '-' || Cust_Last_Name AS Name,
  ProductInformation.Product_Name AS ProductName
FROM
  OE.Customers Customers
  INNER JOIN
  OE.Orders Orders
  ON
  Customers.Customer_Id = Orders.Customer_Id
  INNER JOIN
  OE.Order_Items OrderItems 
  ON
  Orders.Order_Id = OrderItems.Order_Id
  INNER JOIN
  OE.Product_information ProductInformation
  ON
  OrderItems.Product_Id = ProductInformation.Product_Id
WHERE
  Extract(year from Orders.Order_Date) = 2008
  AND
  OrderItems.Unit_Price > 10;

-- Join4
SELECT
  Cust_First_Name || '-' || Cust_Last_Name AS Name,
  ProductInformation.Product_Name AS ProductName,
  OrderItems.Quantity * OrderItems.Unit_Price AS Cost
FROM
  OE.Customers Customers
  INNER JOIN
  OE.Orders Orders
  ON
  Customers.Customer_Id = Orders.Customer_Id
  INNER JOIN
  OE.Order_Items OrderItems 
  ON
  Orders.Order_Id = OrderItems.Order_Id
  INNER JOIN
  OE.Product_information ProductInformation
  ON
  OrderItems.Product_Id = ProductInformation.Product_Id
WHERE
  Extract(year from Orders.Order_Date) = 2007;

-- Join5
SELECT
  Employees1.First_Name || '-' || Employees1.Last_Name AS FullEmployeeName,
  Employees2.First_Name || '-' || Employees2.Last_Name AS FullEmployeeName
FROM
  HR.Employees Employees1
  INNER JOIN
  HR.Employees Employees2
  ON
  Employees1.Employee_Id = Employees2.Manager_Id;

