
--- creating RFM model. creating ONLY FREQUENCYSCORE column AND MONETRYSCORE column

-- using CTEs WITH()function and NTILE() function which orders/sort from the number in its brackets downwards (d number in the bracket is d highest number)
WITH CustomerSalesOrder AS   -- creates 1st virtual table
(
	SELECT FIS.CustomerKey          ----- dis is 1st inner query
		  ,FIS.SalesOrderNumber
		  ,SUM(SalesAmount) AS MySalesAmount   -- creates a new column
	FROM FactInternetSales FIS
	GROUP BY FIS.CustomerKey, FIS.SalesOrderNumber  -- displays distinct/unique values in the 2 stated columns
),
CustomerSalesOrderedStory AS  -- creates 2nd virtual table
(
SELECT CSO.CustomerKey                   -- dis is 2nd inner query using the 1st virtual table created
	  ,COUNT(*) AS SalesOrderCount  -- creates new column
      ,SUM(CSO.MySalesAmount) AS OurSalesAmount  -- creates new column
FROM CustomerSalesOrder CSO   -- using 1st virtual table
GROUP BY CSO.CustomerKey 
)
SELECT CSOS.CustomerKey               --- dis is outter query using the 2nd virtual table created
,NTILE(10) OVER (ORDER BY CSOS.SalesOrderCount ASC) AS FrequencyScore  -- creates new column
,NTILE(10) OVER (ORDER BY CSOS.OurSalesAmount ASC) AS MonetryScore  -- creates new column
FROM CustomerSalesOrderedStory CSOS
ORDER BY CSOS.CustomerKey  -- using 2nd virtual table

--------------------------------------------------------------------------------------------------------------------------------------

-- using NTILE() function 2 to displays a specific top value/client in the RFM model
WITH CustomerSalesOrder AS   -- creates 1st virtual table
(
	SELECT FIS.CustomerKey
		  ,FIS.SalesOrderNumber
		  ,SUM(SalesAmount) AS MySalesAmount   -- creates a new column
	FROM FactInternetSales FIS
	GROUP BY FIS.CustomerKey, FIS.SalesOrderNumber  -- displays distinct/unique values in the 2 stated columns
),
CustomerSalesOrderedStory AS  -- creates 2nd virtual table
(
SELECT CSO.CustomerKey
	  ,COUNT(*) AS SalesOrderCount  -- creates new column
      ,SUM(CSO.MySalesAmount) AS OurSalesAmount  -- creates new column
FROM CustomerSalesOrder CSO   -- using 1st virtual table
GROUP BY CSO.CustomerKey 
),
RFM AS  -- creating another virtual table with NTILE() function
(
	SELECT CSOS.CustomerKey
		  ,NTILE(10) OVER (ORDER BY CSOS.SalesOrderCount ASC) AS FrequencyScore  -- creates new column
		  ,NTILE(10) OVER (ORDER BY CSOS.OurSalesAmount ASC) AS MonetryScore  -- creates new column
	FROM CustomerSalesOrderedStory CSOS
)
SELECT *             
FROM RFM FM
WHERE FM.FrequencyScore = 10 AND FM.MonetryScore = 10   -- displays data that corresponds to only value 10 in the 2 columns stated
ORDER BY FM.CustomerKey

---------------------------------------------------------------------------------------------------------------------------------------

-- Creating RFM 2 using DATEDIFF() to add RECENCYSCORE column to FREQUENCYSCORE column AND MONETRYSCORE column


WITH CustomerSalesOrder AS   -- creates 1st virtual table
(
	SELECT FIS.CustomerKey
		  ,FIS.SalesOrderNumber
		  ,SUM(SalesAmount) AS MySalesAmount   -- creates a new column
		  ,MAX(OrderDate) AS MyOrderDate    -- creating a new column using MAX()function showing OrderDate datetime values but d time values are all zeros
	FROM FactInternetSales FIS
	GROUP BY FIS.CustomerKey, FIS.SalesOrderNumber  -- displays distinct/unique values in the 2 stated columns
),
CustomerSalesOrderedStory AS  -- creates 2nd virtual table
(
SELECT CSO.CustomerKey
	  ,COUNT(*) AS SalesOrderCount  -- creates new column
      ,SUM(CSO.MySalesAmount) AS OurSalesAmount  -- creates new column
	  ,DATEDIFF(DAY, MAX(CSO.MyOrderDate), CURRENT_TIMESTAMP) AS ElapsedRecentOrder  -- creates new column
FROM CustomerSalesOrder CSO   -- using 1st virtual table
GROUP BY CSO.CustomerKey 
)
SELECT CSOS.CustomerKey
      ,NTILE(10) OVER (ORDER BY CSOS.ElapsedRecentOrder DESC) AS RecencyScore  -- creates new column
      ,NTILE(10) OVER (ORDER BY CSOS.SalesOrderCount ASC) AS FrequencyScore  -- creates new column
      ,NTILE(10) OVER (ORDER BY CSOS.OurSalesAmount ASC) AS MonetryScore  -- creates new column
FROM CustomerSalesOrderedStory CSOS
ORDER BY CSOS.CustomerKey  -- using 2nd virtual table

--------------------------------------------------------------------------------------------------------------

-- RFM model to display the top top clients/values in all 3 columns- Recency, Monetary and Frequency columns 

WITH CustomerSalesOrder AS   -- creates 1st virtual table
(
	SELECT FIS.CustomerKey
		  ,FIS.SalesOrderNumber
		  ,SUM(SalesAmount) AS MySalesAmount   -- creates a new column
		  ,MAX(OrderDate) AS MyOrderDate    -- creating a new column using MAX()function showing OrderDate datetime values but d time values are all zeros
	FROM FactInternetSales FIS
	GROUP BY FIS.CustomerKey, FIS.SalesOrderNumber  -- displays distinct/unique values in the 2 stated columns
),
CustomerSalesOrderedStory AS  -- creates 2nd virtual table
(
SELECT CSO.CustomerKey
	  ,COUNT(*) AS SalesOrderCount  -- creates new column
      ,SUM(CSO.MySalesAmount) AS OurSalesAmount  -- creates new column
	  ,DATEDIFF(DAY, MAX(CSO.MyOrderDate), CURRENT_TIMESTAMP) AS ElapsedRecentOrder  -- creates new column
FROM CustomerSalesOrder CSO   -- using 1st virtual table
GROUP BY CSO.CustomerKey 
),
RFMAnalysis AS  -- creating another virtual table with NTILE() function
(
	SELECT CSOS.CustomerKey
	      ,NTILE(10) OVER (ORDER BY CSOS.ElapsedRecentOrder DESC) AS RecencyScore  -- creates new column
		  ,NTILE(10) OVER (ORDER BY CSOS.SalesOrderCount ASC) AS FrequencyScore  -- creates new column
		  ,NTILE(10) OVER (ORDER BY CSOS.OurSalesAmount ASC) AS MonetryScore  -- creates new column
	FROM CustomerSalesOrderedStory CSOS
)
SELECT FM.CustomerKey
,FM.RecencyScore
,FM.FrequencyScore
,FM.MonetryScore
FROM RFMAnalysis FM
WHERE FM.FrequencyScore = 10 AND FM.MonetryScore = 10 AND FM.RecencyScore = 10  -- displays data that corresponds to only value 10 in the 3 columns stated
ORDER BY FM.CustomerKey ASC;                                                    -- or use >= 8 rather than = 10 values

