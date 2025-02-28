use CCF_DB;

CREATE TABLE creditcard (
    Client_Num VARCHAR(50),
    Card_Category VARCHAR(50),
    Annual_Fees DECIMAL(10, 2),
    Activation_30_Days INT,
    Customer_Acq_Cost DECIMAL(10, 2),
    Week_Start_Date VARCHAR(50),  -- Temporary VARCHAR column for date values
    Week_Num VARCHAR(50),
    Qtr VARCHAR(50),
    current_year INT,
    Credit_Limit DECIMAL(10, 2),
    Total_Revolving_Bal DECIMAL(10, 2),
    Total_Trans_Amt DECIMAL(10, 2),
    Total_Trans_Vol INT,
    Avg_Utilization_Ratio DECIMAL(5, 4),
    [Use Chip] VARCHAR(50),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10, 2),
    Delinquent_Acc INT
);


select * from creditcard

BULK INSERT creditcard
FROM 'C:\Users\deepi\OneDrive\Power BI\archive\credit_card.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

SELECT Client_Num, Week_Start_Date
FROM creditcard
WHERE ISDATE(Week_Start_Date) = 0;

UPDATE creditcard
SET Week_Start_Date = CONVERT(DATE, Week_Start_Date, 103)  -- Assuming DD-MM-YYYY format
WHERE ISDATE(Week_Start_Date) =0;

EXEC sp_help 'creditcard';

--Customer Segmentation Analysis
SELECT 
    c.Customer_Age, 
    c.Gender, 
    c.Education_Level, 
    c.Marital_Status, 
    cc.Card_Category, 
    cc.Avg_Utilization_Ratio, 
    cc.Total_Trans_Amt, 
    cc.Total_Trans_Vol,
    c.Income
FROM 
    dbo.customer c
JOIN 
    creditcard cc 
    ON c.Client_Num = cc.Client_Num
ORDER BY 
    cc.Total_Trans_Amt DESC;



--Credit Utilization & Risk Analysis
SELECT 
    c.Client_Num, 
    c.Customer_Age, 
    cc.Credit_Limit, 
    cc.Total_Revolving_Bal, 
    cc.Avg_Utilization_Ratio, 
    cc.Delinquent_Acc
FROM 
    dbo.customer c
JOIN 
    creditcard cc 
    ON c.Client_Num = cc.Client_Num
WHERE 
    cc.Avg_Utilization_Ratio > 0.7  -- High utilization ratio
ORDER BY 
    cc.Avg_Utilization_Ratio DESC;


--Spending Patterns Analysis--
SELECT 
    cc.Exp_Type, 
    SUM(cc.Total_Trans_Amt) AS Total_Spent, 
    COUNT(cc.Client_Num) AS Number_of_Customers
FROM 
    creditcard cc
GROUP BY 
    cc.Exp_Type
ORDER BY 
    Total_Spent DESC;

--Activation & Acquisition Costs Analysis
SELECT 
    cc.Card_Category, 
    AVG(cc.Customer_Acq_Cost) AS Avg_Acq_Cost, 
    COUNT(DISTINCT CASE WHEN cc.Activation_30_Days = 1 THEN cc.Client_Num END) AS Activated_Customers,
    COUNT(DISTINCT cc.Client_Num) AS Total_Customers
FROM 
    creditcard cc
GROUP BY 
    cc.Card_Category;

--Interest Earned vs. Customer Income
SELECT 
    c.Income, 
    SUM(cc.Interest_Earned) AS Total_Interest_Earned
FROM 
    dbo.customer c
JOIN 
    creditcard cc 
    ON c.Client_Num = cc.Client_Num
GROUP BY 
    c.Income
ORDER BY 
    Total_Interest_Earned DESC;


--Delinquency Analysis
SELECT 
    c.Customer_Age, 
    c.Gender, 
    cc.Card_Category, 
    cc.Avg_Utilization_Ratio, 
    cc.Total_Revolving_Bal, 
    cc.Interest_Earned
FROM 
    dbo.customer c
JOIN 
    creditcard cc 
    ON c.Client_Num = cc.Client_Num
WHERE 
    cc.Delinquent_Acc = 1  -- Delinquent accounts
ORDER BY 
    cc.Total_Revolving_Bal DESC;

