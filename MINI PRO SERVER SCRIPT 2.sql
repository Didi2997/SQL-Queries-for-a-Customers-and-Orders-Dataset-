SELECT *
FROM Customers$

SELECT *
FROM Orders$


--PRODUCT WITH THE HIGHEST TOTAL COST
SELECT TOP 1 Product_ID, SUM(Total_Cost) AS SumCost
FROM Orders$
GROUP BY Product_ID
ORDER BY SumCost DESC

--TOTAL REVENUE ACCRUED FROM LARGE ORDERS
SELECT Order_Category, SUM(Total_Cost) AS STC
FROM Orders$
WHERE Order_Category = 'Large Order'
GROUP BY Order_Category

--NUMBER OF ORDERS PLACED IN NOVEMBER 2014
SELECT COUNT(Order_Category)
FROM Orders$
WHERE Order_Date BETWEEN '11-01-2014' AND '11-30-2014'

--SALES RECORDS FROM OCTOBER 2014 TO OCTOBER 2015
SELECT Order_Date, Product_ID, Total_Cost, Order_Category
FROM Orders$
WHERE Order_Date BETWEEN '2014-10-01' AND '2015-10-31'
ORDER BY Order_Date

--COUNTRY WITH THE HIGHEST NUMBER OF LARGE ORDERS
SELECT TOP 1 Cs.Country, COUNT(Os.Order_Category) AS OrderCategoryCount
FROM Customers$ AS Cs
JOIN Orders$ AS Os
ON Cs.Customer_ID = Os.Customer_ID
WHERE Os.Order_Category = 'Large Order'
GROUP BY Cs.Country
ORDER BY OrderCategoryCount DESC

--COUNTRY WITH THE LOWEST NUMBER OF LARGE ORDERS
SELECT TOP 1 Cs.Country, COUNT(Os.Order_Category) AS OrderCategoryCount
FROM Customers$ AS Cs
JOIN Orders$ AS Os
ON Cs.Customer_ID = Os.Customer_ID
WHERE Os.Order_Category = 'Large Order'
GROUP BY Cs.Country
ORDER BY OrderCategoryCount ASC

--TOTAL QUANTITY OF NORMAL ORDERS PLACED IN 2013
WITH CTE_NormalOrder2013 AS
(SELECT Order_Category, SUM(Quantity) AS NormalOrderFor2013
FROM Orders$
WHERE YEAR(Order_Date)='2013'
GROUP BY Order_Category)
SELECT Order_Category, NormalOrderFor2013
FROM CTE_NormalOrder2013
WHERE Order_Category = 'Normal Order'
GROUP BY Order_Category, NormalOrderFor2013

--CUSTOMERS WHO RANK AS PATRONS WITH TOP 3 HIGHEST NUMBER OF ORDERS
SELECT CD.Customer_ID, CD.CountOrders, CD.CustomerRank
FROM (SELECT C.Customer_ID, C.CountOrders, 
DENSE_RANK()OVER(ORDER BY CountOrders DESC) AS CustomerRank
FROM (SELECT Customer_ID, COUNT(Order_Category) AS CountOrders
FROM Orders$
GROUP BY Customer_ID) AS C) AS CD
WHERE CD.CustomerRank <= 3

--COUNTRY WHERE THE HIGHEST REVENUE IS GENERATED FROM
SELECT TOP 1 CTS.Country, SUM(ODS.Total_Cost) AS RevenuePerCountry
FROM Customers$ AS CTS
JOIN Orders$ AS ODS
ON CTS.Customer_ID = ODS.Customer_ID
GROUP BY CTS.Country
ORDER BY RevenuePerCountry DESC

--MOST LUCRATIVE YEAR FOR THE COMPANY (FROM 2010-2015)
SELECT TOP 1 CB.NYEAR, CB.AggregateRevenue
FROM (SELECT YEAR(Order_Date) AS NYEAR, SUM(Total_Cost) AS AggregateRevenue
FROM Orders$
GROUP BY YEAR(Order_Date)) AS CB
ORDER BY AggregateRevenue DESC

--CREATE TEMP TABLE TO STORE RATING SYSTEM AWARDED TO PATRONS ACCORDING TO REVENUE GENERATED IN 2015
DROP TABLE IF EXISTS #Temp_CustomerRating
CREATE TABLE #temp_CustomerRating 
(Customer_ID INT NOT NULL,
Full_Name NVARCHAR(50) NOT NULL,
Revenue_Generated INT NOT NULL,
Star_Rating NVARCHAR(25) NOT NULL)
INSERT INTO #temp_CustomerRating
SELECT CO.Customer_ID, CO.Full_Name, CO.SumRev,
CASE
WHEN SumRev >= '400' THEN CONCAT('Gold','   ',N'⭐⭐⭐⭐⭐')
WHEN SumRev < '400' AND SumRev >= '200' THEN CONCAT('Silver',' ', N'⭐⭐⭐⭐')
WHEN SumRev < '200' THEN CONCAT('Bronze',' ',N'⭐⭐⭐')
ELSE '0'
END AS Rating 
FROM (SELECT ORS.Customer_ID, CRS.Full_Name, SUM(ORS.Total_Cost) AS SumRev 
FROM Customers$ AS CRS
JOIN Orders$ AS ORS
ON CRS.Customer_ID = ORS.Customer_ID
WHERE YEAR(ORS.Order_Date) = '2015'
GROUP BY ORS.Customer_ID, CRS.Full_Name) AS CO
ORDER BY CO.SumRev DESC

SELECT *
FROM #temp_CustomerRating
ORDER BY Customer_ID

--CREATE A STORED PROCEDURE FOR ASSESSING AVERAGE REVENUE PER MONTH OF SALES IN 2013
GO
CREATE PROCEDURE AVG1 AS
SELECT MONTH(Order_Date) AS nMonth, AVG(Total_Cost) AS AverageRevenue2013
FROM Orders$
GROUP BY MONTH(Order_Date)
ORDER BY nMonth
GO

EXECUTE AVG1
 


