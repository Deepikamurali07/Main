use SalesAnalysis;

select *
From ecommerce_dataset_updated;

--Data Cleaning--

--Check missing values--
SELECT * FROM ecommerce_dataset_updated
WHERE [Product_ID] IS NULL
   OR [Category] IS NULL
   OR [Price (Rs )] IS NULL
   OR [Discount (%)] IS NULL
   OR [Final_Price(Rs )] IS NULL
   OR [Payment_Method] IS NULL
   OR [Purchase_Date] IS NULL;

-- Alter the Discount, Price and Final Price column to Decimal
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Discount (%)] DECIMAL(5, 2);

ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Price (Rs )] DECIMAL(10, 2);

ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Final_Price(Rs )] DECIMAL(10, 2);

-- Alter the Purchase_Date column to DATE
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Purchase_Date] DATE;

-- Alter the User_ID column to VARCHAR
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [User_ID] VARCHAR(255);

-- Alter the Product_ID column to VARCHAR
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Product_ID] VARCHAR(255);

-- Alter the Category column to VARCHAR
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Category] VARCHAR(255);

-- Alter the Payment_Method column to VARCHAR
ALTER TABLE ecommerce_dataset_updated
ALTER COLUMN [Payment_Method] VARCHAR(255);

EXEC sp_help 'ecommerce_dataset_updated';

--Check Outliers--
SELECT *
FROM ecommerce_dataset_updated
WHERE [Discount (%)] > 100 OR [Discount (%)] < 0;

SELECT *
FROM ecommerce_dataset_updated
WHERE [Price (Rs )] < 0;

-- Remove leading and trailing spaces from text-based columns
UPDATE ecommerce_dataset_updated
SET [User_ID] = LTRIM(RTRIM([User_ID]));

UPDATE ecommerce_dataset_updated
SET [Product_ID] = LTRIM(RTRIM([Product_ID]));

UPDATE ecommerce_dataset_updated
SET [Category] = LTRIM(RTRIM([Category]));

UPDATE ecommerce_dataset_updated
SET [Payment_Method] = LTRIM(RTRIM([Payment_Method]));

-- Standardize Category column
UPDATE ecommerce_dataset_updated
SET [Category] = UPPER([Category]);

-- Standardize Payment_Method column
UPDATE ecommerce_dataset_updated
SET [Payment_Method] = UPPER([Payment_Method]);


-- Check for NULL or unexpected values in Purchase_Date
SELECT *
FROM ecommerce_dataset_updated
WHERE [Purchase_Date] IS NULL;

-- Duplicate Records--
SELECT [User_ID], [Product_ID], COUNT(*) AS No_Of_Duplicate_Rows
FROM ecommerce_dataset_updated
GROUP BY [User_ID], [Product_ID]
HAVING COUNT(*) > 1;


--ANALYSIS--

--1. Monthly sales based on Category--
SELECT Category,
       SUM(CASE WHEN MONTH(Purchase_Date) = 1 THEN [Final_Price(Rs )] ELSE 0 END) AS Jan_Sales,
       SUM(CASE WHEN MONTH(Purchase_Date) = 2 THEN [Final_Price(Rs )] ELSE 0 END) AS Feb_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 3 THEN [Final_Price(Rs )] ELSE 0 END) AS Mar_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 4 THEN [Final_Price(Rs )] ELSE 0 END) AS Apr_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 5 THEN [Final_Price(Rs )] ELSE 0 END) AS May_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 6 THEN [Final_Price(Rs )] ELSE 0 END) AS June_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 7 THEN [Final_Price(Rs )] ELSE 0 END) AS July_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 8 THEN [Final_Price(Rs )] ELSE 0 END) AS Aug_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 9 THEN [Final_Price(Rs )] ELSE 0 END) AS Sept_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 10 THEN [Final_Price(Rs )] ELSE 0 END) AS Oct_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 11 THEN [Final_Price(Rs )] ELSE 0 END) AS Nov_Sales,
	   SUM(CASE WHEN MONTH(Purchase_Date) = 12 THEN [Final_Price(Rs )] ELSE 0 END) AS Dec_Sales
FROM ecommerce_dataset_updated
GROUP BY Category;

--2. Trend Analysis with Discount and Revenue--
SELECT YEAR(Purchase_Date) AS Year,
       MONTH(Purchase_Date) AS Month,
       AVG([Discount (%)]) AS Avg_Discount,
       SUM([Final_Price(Rs )]) AS Total_Revenue
FROM ecommerce_dataset_updated
GROUP BY YEAR(Purchase_Date), MONTH(Purchase_Date)
ORDER BY Year, Month;

--3. Top Products by Revenue--
SELECT Top 5 Product_ID, 
       SUM([Final_Price(Rs )]) AS Total_Revenue
FROM ecommerce_dataset_updated
GROUP BY Product_ID
ORDER BY Total_Revenue DESC;

--4. Which category generates the highest revenue?--
SELECT TOP 1 Category, 
       SUM([Final_Price(Rs )]) AS Total_Revenue
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY Total_Revenue DESC;

--5. What is the effect of discounts on revenue generation?--
SELECT Category,
       AVG([Discount (%)]) AS Average_Discount,
       SUM([Final_Price(Rs )]) AS Total_Revenue
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY Average_Discount DESC;

--6. Which payment methods are preferred by customers?--
SELECT Payment_Method,
       COUNT(*) AS Number_of_Transactions,
       SUM([Final_Price(Rs )]) AS Total_Revenue,
       AVG([Final_Price(Rs )]) AS Average_Transaction_Value
FROM ecommerce_dataset_updated
GROUP BY Payment_Method
ORDER BY Number_of_Transactions DESC;

--7. Are there specific time periods with spikes or drops in sales?--
SELECT Purchase_Date,
       SUM([Final_Price(Rs )]) AS Daily_Sales
FROM ecommerce_dataset_updated
GROUP BY Purchase_Date
ORDER BY Purchase_Date;


--8. How effective are discounts in driving sales across categories?--
SELECT Category,
       SUM([Final_Price(Rs )]) AS Total_Revenue,
       AVG([Discount (%)]) AS Average_Discount,
       SUM([Final_Price(Rs )] * ([Discount (%)]/100)) AS Discount_Impact
FROM ecommerce_dataset_updated
GROUP BY Category;

--9. How is each category performing over time?--
SELECT YEAR(Purchase_Date) AS Year,
       MONTH(Purchase_Date) AS Month,
       Category,
       SUM([Final_Price(Rs )]) AS Monthly_Sales
FROM ecommerce_dataset_updated
GROUP BY YEAR(Purchase_Date), MONTH(Purchase_Date), Category
ORDER BY Year, Month;

--10. What are the moving averages of sales for specific products?--
SELECT Product_ID,
       Purchase_Date,
       SUM([Final_Price(Rs )]) AS Daily_Sales,
       AVG(SUM([Final_Price(Rs )])) OVER (PARTITION BY Product_ID ORDER BY Purchase_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Moving_Avg_7_Days
FROM ecommerce_dataset_updated
GROUP BY Product_ID, Purchase_Date
ORDER BY Product_ID, Purchase_Date;


--11. How can customers be segmented based on spending?--
SELECT User_ID,
       SUM([Final_Price(Rs )]) AS Total_Spent,
       CASE 
           WHEN SUM([Final_Price(Rs )]) < 500 THEN 'Low Spender'
           WHEN SUM([Final_Price(Rs )]) BETWEEN 500 AND 1000 THEN 'Moderate Spender'
           ELSE 'High Spender'
       END AS Spending_Segment
FROM ecommerce_dataset_updated
GROUP BY User_ID;

--12. What are the top-selling products in each category?--
SELECT Category, 
       Product_ID, 
       SUM([Final_Price(Rs )]) AS Total_Revenue
FROM ecommerce_dataset_updated
GROUP BY Category, Product_ID
ORDER BY Category, Total_Revenue DESC;
