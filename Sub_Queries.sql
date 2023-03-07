SELECT
	Product_Name
FROM
	OE.Product_Information ProductInformationOuter
WHERE
	ProductInformationOuter.List_Price 
	= 
	(
		SELECT
			Max(LIST_PRICE)
		FROM
			OE.Product_Information ProductInformationInner
	);



-- subqueries2
SELECT
  Product_Information.Product_Name
FROM
	OE.Product_Information
	INNER JOIN
	OE.Order_Items
	ON
	Product_Information.Product_Id = Order_Items.Product_Id
	INNER JOIN
	OE.Orders
	ON
	Order_Items.Order_Id = Orders.Order_Id 
WHERE
	Orders.Order_Total
	=
	(
		SELECT
			Max(OrdersInner.Order_Total)
		FROM
			OE.Orders OrdersInner
	);
	
-- subqueries3
SELECT
  Product_Information.Product_Name
FROM
	OE.Product_Information
	INNER JOIN
	OE.Order_Items
	ON
	Product_Information.Product_Id = Order_Items.Product_Id
	INNER JOIN
	OE.Orders
	ON
	Order_Items.Order_Id = Orders.Order_Id 
WHERE
	Orders.Order_Total
	>
	(
		SELECT
			Avg(OrdersInner.Order_Total)
		FROM
			OE.Orders OrdersInner
	);
	
-- subqueries4

SELECT
  Sum(Orders.Order_Total) 
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
  Employees.Employee_Id
  
  
SELECT
  Employees.Employee_Id,
  Employees.First_Name || '-' || Employees.Last_Name AS Name,
  Sum(Orders.Order_Total) AS Order_Total
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
  Employees.First_Name || '-' || Employees.Last_Name

-- subqueries5
SELECT
  UNIQUE(Product_Information.Product_Name)
FROM  
    OE.Orders 
	INNER JOIN
	OE.Order_Items
	ON
	Orders.Order_Id
	=
	Order_Items.Order_Id
	INNER JOIN
	OE.Product_Information
	ON
	Order_Items.Product_Id
	=
	Product_Information.Product_Id
WHERE
  Orders.Order_Id
  IN
  (
    SELECT
      Order_Items.Order_Id
    FROM
      OE.Order_Items
    WHERE
      Order_Items.Unit_Price 
      =
      (
        SELECT 
        	Max(Order_Items.Unit_Price)
        FROM	
        	OE.Order_Items
      )
  );