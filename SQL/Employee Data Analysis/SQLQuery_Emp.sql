use EmployeeDB;


SELECT * FROM Employe_Performance_dataset;

EXEC sp_help 'Employe_Performance_dataset';

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [ID] INT;

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [Age] INT;

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [Salary] DECIMAL(10,2);

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [Joining Date] DATE;

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [Experience] INT;


UPDATE Employe_Performance_dataset
SET [Performance Score] = NULL
WHERE ISNUMERIC([Performance Score]) = 0;

ALTER TABLE Employe_Performance_dataset
ALTER COLUMN [Performance Score] FLOAT;

EXEC sp_help 'Employe_Performance_dataset';

--How many employees are there in total?
SELECT COUNT(*) AS Total_Employee FROM Employe_Performance_dataset;

--What is the distribution of employees across different departments?
SELECT Department, COUNT(*) As Total_Employee FROM Employe_Performance_dataset
GROUP BY Department;

--What is the average salary across all employees?
SELECT AVG(Salary) As Average_Salary FROM Employe_Performance_dataset;

--What is the total salary expenditure for the company
SELECT SUM(Salary) AS Total_Salary_Expenditure FROM Employe_Performance_dataset;

--What is the average salary in each department?
SELECT Department, AVG(Salary) As Average FROM Employe_Performance_dataset
group by Department;

--What is the salary range (minimum and maximum salary) for employees in each department?
SELECT Department, MIN(Salary) AS Minimum, MAX(Salary) AS Maximum FROM Employe_Performance_dataset
GROUP BY Department;

--How many employees have been with the company for over 5 years in each department?
SELECT Department, COUNT(*) AS Number_Of_Employees FROM Employe_Performance_dataset
WHERE Experience>5
GROUP BY Department;

--How many new hires were made by each department in the last year?
SELECT Department, COUNT(*) AS New_Hires
FROM Employe_Performance_dataset
WHERE [Joining Date] >= '2024-01-01' AND [Joining Date] < '2025-01-01'
GROUP BY Department;

--What is the average tenure of employees in the company?
SELECT AVG(Experience) AS Average_Tenure FROM Employe_Performance_dataset;

--How many employees have been with the company for 1, 5, 10, and 20 years?
SELECT COUNT(*) AS Number_Of_Employee FROM Employe_Performance_dataset
WHERE Experience IN (1,5,10,20);

--How does employee tenure vary by department or job title?
SELECT Department, AVG(Experience) AS Tenure FROM Employe_Performance_dataset
GROUP BY Department;

--What is the distribution of employees by years of service?
SELECT Experience, COUNT(*) AS Number_Of_Employees 
FROM Employe_Performance_dataset
GROUP BY Experience;

--What is the distribution of salaries across the company?
SELECT Salary, COUNT(*) AS Number_Of_Employees 
FROM Employe_Performance_dataset
GROUP BY Salary;

--What is the average salary by Department?
SELECT Department, AVG(Salary) AS Average_Salary FROM Employe_Performance_dataset
GROUP BY Department;

--How do salaries vary by location, if the dataset includes location data
SELECT Location, AVG(Salary) AS Average_Salary
FROM Employe_Performance_dataset
GROUP BY Location;

--Are there any salary discrepancies based on gender or other demographics (if applicable)?
SELECT Gender, AVG(Salary) AS Average_Salary, COUNT(*) AS Number_Of_Employees
FROM Employe_Performance_dataset
GROUP BY Gender;

--Salary trend over years
SELECT YEAR([Joining Date]) AS Year, AVG(Salary) AS Average_Salary
FROM Employe_Performance_dataset
GROUP BY YEAR([Joining Date])
ORDER BY Year;

--What is the gender distribution of employees in the company?
SELECT Gender, COUNT(*) AS Total_Employee
FROM Employe_Performance_dataset
GROUP BY Gender;

--How many employees belong to each age group?
SELECT Age_Group, COUNT(*) AS Total_Employee
FROM (
    SELECT 
        CASE
            WHEN Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN Age >= 60 THEN '60+'
        END AS Age_Group
    FROM Employe_Performance_dataset
) AS AgeGroups
GROUP BY Age_Group;



--How does the gender distribution vary across departments or job titles?
SELECT Department, Gender, COUNT(*) AS Total_Employee
FROM Employe_Performance_dataset
GROUP BY Gender, Department
ORDER BY Department;

--What is the age distribution across various job titles and departments?
SELECT Department, Age, COUNT(*) AS Total_Employee
FROM Employe_Performance_dataset
GROUP BY Age, Department
ORDER BY Department, Age;

--What is the average performance rating across departments?
SELECT Department, AVG([Performance Score]) AS Average_Performance FROM Employe_Performance_dataset
GROUP BY Department;

SELECT * FROM Employe_Performance_dataset

--How many employees have received performance ratings in the past year?
SELECT [Performance Score], COUNT(*) AS New_Hires
FROM Employe_Performance_dataset
WHERE [Joining Date] >= '2024-01-01' AND [Joining Date] < '2025-01-01'
GROUP BY [Performance Score];

--What is the gender diversity at various levels of the company
SELECT Experience, Gender, COUNT(*) AS Total_Employee
FROM Employe_Performance_dataset
GROUP BY Gender, Experience
ORDER BY Experience;

--How many employees were hired in the past year?
SELECT COUNT(*) AS New_Hires
FROM Employe_Performance_dataset
WHERE [Joining Date] >= '2024-01-01' AND [Joining Date] < '2025-01-01'


--What is the total compensation package for employees in each department?\
SELECT Department, SUM(Salary) AS Compensation FROM Employe_Performance_dataset
GROUP BY Department;

--How many employees are located in each office or region?
SELECT Location, COUNT(*) AS Number_Of_Employee FROM Employe_Performance_dataset
GROUP BY Location

--How does the salary differ between different locations?
SELECT Location, AVG(Salary) AS Average_Salary FROM Employe_Performance_dataset
GROUP BY Location

--Employee Turnover rate
SELECT 
    (COUNT(CASE WHEN Status = 'Inactive' THEN 1 END) * 100.0) / COUNT(*) AS turnover_rate
FROM 
    Employe_Performance_dataset;

--Turnover by Department 
SELECT 
    Department, 
    COUNT(CASE WHEN Status = 'Inactive' THEN 1 END) AS turnover_count
FROM 
    Employe_Performance_dataset
GROUP BY 
    Department;

