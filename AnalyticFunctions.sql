-- analytic function1
SELECT
  Products_Ordered_By_Price_Category.Product_Name, Products_Ordered_By_Price_Category.Category_Name, Products_Ordered_By_Price_Category.List_Price
FROM 
  (
    SELECT
      Product_Information.Product_Name, Categories_Tab.Category_Name, Product_Information.List_Price,
      Row_Number() Over (Partition BY Categories_Tab.Category_Name ORDER BY Product_Information.List_Price)
      AS
      Row_Number
    FROM
      OE.Categories_Tab
      INNER JOIN
      OE.Product_Information
      ON
      Categories_Tab.Category_Id
      =
      Product_Information.Category_Id
  ) Products_Ordered_By_Price_Category
WHERE
  Row_Number <= 3;
  

-- analytic functions 2
SELECT
  TotalOfEachYear.*,
  Total_Sales_Of_Year - Lag(Total_Sales_Of_Year) 
  OVER
  (ORDER BY Years ASC)
  AS Diffrence_From_Last_Year
FROM
  (
    SELECT
      Extract(year from Order_date) AS Years,
      Sum(Order_Total) AS Total_Sales_Of_Year
    FROM
      OE.Orders
    GROUP BY
      Extract(year from Order_Date)
  ) TotalOfEachYear;
  
-- analytic functions 3
SELECT
  Extract(year from Orders.Order_date) AS Year,
  Extract(month from Orders.Order_date) AS Month,
  Sum(Orders.Order_Total) AS Monthly_Total,
  Sum(Sum(Orders.Order_Total)) OVER (ORDER BY Extract(year from Orders.Order_Date), EXTRACT(month from Orders.Order_Date)) AS Running_Total
FROM
  OE.Orders
GROUP BY
  Extract(year from Orders.Order_Date),
  Extract(month from Orders.Order_Date)
ORDER BY
  Year,
  Month;