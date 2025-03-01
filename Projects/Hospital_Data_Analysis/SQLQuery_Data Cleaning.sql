SELECT * FROM hospitals_data;

--Check if any null values--
SELECT COLUMN_NAME, COUNT(*) AS NULL_Count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hospitals_data'
GROUP BY COLUMN_NAME;

--Query to Check for Negative Values in Cost Columns--
SELECT *
FROM hospitals_data
WHERE Procedure_Heart_Attack_Cost < 0 
   OR Procedure_Heart_Failure_Cost < 0
   OR Procedure_Pneumonia_Cost < 0
   OR Procedure_Hip_Knee_Cost < 0;


--Find Duplicates\
SELECT Facility_Name, Facility_City, Facility_State, COUNT(*) AS Duplicate_Count
FROM hospitals_data
GROUP BY Facility_Name, Facility_City, Facility_State
HAVING COUNT(*) > 1;

--Trim Extra Spaces
UPDATE hospitals_data
SET Facility_Name = TRIM(Facility_Name),
    Facility_City = TRIM(Facility_City),
    Facility_State = TRIM(Facility_State),
    Facility_Type = TRIM(Facility_Type);

--Check for Outliers or Invalid Values
SELECT *
FROM hospitals_data
WHERE Procedure_Heart_Attack_Cost > 100000
   OR Procedure_Heart_Failure_Cost > 100000
   OR Procedure_Pneumonia_Cost > 100000
   OR Procedure_Hip_Knee_Cost > 100000;

--Make it consistent
UPDATE hospitals_data
SET Rating_Mortality = UPPER(Rating_Mortality),
    Rating_Safety = UPPER(Rating_Safety);


