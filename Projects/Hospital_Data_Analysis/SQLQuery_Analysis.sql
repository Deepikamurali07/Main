
--Count of Hospitals by Facility Type and State
SELECT Facility_Type, Facility_State, COUNT(*) AS Hospital_Count
FROM hospitals_data
GROUP BY Facility_Type, Facility_State
ORDER BY Facility_State, Facility_Type;

--Average Ratings by Facility Type
SELECT Facility_Type,
       AVG(CASE WHEN Rating_Overall IS NOT NULL THEN Rating_Overall ELSE 0 END) AS Avg_Overall_Rating,
       AVG(CASE WHEN Rating_Mortality = 'ABOVE' THEN 1
                WHEN Rating_Mortality = 'BELOW' THEN -1 ELSE 0 END) AS Avg_Mortality_Rating,
       AVG(CASE WHEN Rating_Safety = 'ABOVE' THEN 1
                WHEN Rating_Safety = 'BELOW' THEN -1 ELSE 0 END) AS Avg_Safety_Rating
FROM hospitals_data
GROUP BY Facility_Type
ORDER BY Facility_Type;

--Procedure Cost vs Quality (Heart Attack)
SELECT Procedure_Heart_Attack_Cost, Procedure_Heart_Attack_Quality, COUNT(*) AS Hospital_Count
FROM hospitals_data
GROUP BY Procedure_Heart_Attack_Cost, Procedure_Heart_Attack_Quality
ORDER BY Procedure_Heart_Attack_Cost;

--Top Performing Hospitals for a Specific Procedure (Heart Attack)
SELECT Facility_Name, Procedure_Heart_Attack_Cost, Procedure_Heart_Attack_Quality
FROM hospitals_data
WHERE Procedure_Heart_Attack_Quality = 'ABOVE'
ORDER BY Procedure_Heart_Attack_Cost DESC;


--State-wise Comparison of Procedure Costs (Average)
SELECT Facility_State,
       AVG(Procedure_Heart_Failure_Cost) AS Avg_Heart_Failure_Cost,
       AVG(Procedure_Pneumonia_Cost) AS Avg_Pneumonia_Cost,
       AVG(Procedure_Hip_Knee_Cost) AS Avg_Hip_Knee_Cost
FROM hospitals_data
GROUP BY Facility_State
ORDER BY Facility_State;


--Facility Type Comparison: Performance in Specific Procedures
SELECT Facility_Type,
       AVG(CASE WHEN Procedure_Heart_Attack_Quality = 'ABOVE' THEN 1 ELSE 0 END) AS Heart_Attack_Performance,
       AVG(CASE WHEN Procedure_Heart_Failure_Quality = 'ABOVE' THEN 1 ELSE 0 END) AS Heart_Failure_Performance
FROM hospitals_data
GROUP BY Facility_Type
ORDER BY Facility_Type;


--Distribution of Ratings Across Hospitals
SELECT Rating_Overall, COUNT(*) AS Rating_Count
FROM hospitals_data
GROUP BY Rating_Overall
ORDER BY Rating_Overall;


--Hospitals with the Highest Cost Procedures
SELECT Facility_Name, Procedure_Heart_Attack_Cost, Procedure_Heart_Failure_Cost, Procedure_Pneumonia_Cost, Procedure_Hip_Knee_Cost
FROM hospitals_data
WHERE Procedure_Heart_Attack_Cost = (SELECT MAX(Procedure_Heart_Attack_Cost) FROM hospitals_data)
   OR Procedure_Heart_Failure_Cost = (SELECT MAX(Procedure_Heart_Failure_Cost) FROM hospitals_data)
   OR Procedure_Pneumonia_Cost = (SELECT MAX(Procedure_Pneumonia_Cost) FROM hospitals_data)
   OR Procedure_Hip_Knee_Cost = (SELECT MAX(Procedure_Hip_Knee_Cost) FROM hospitals_data);

--Hospitals with the Best Rating in Specific Procedures
SELECT Facility_Name, 
       Procedure_Heart_Attack_Quality, 
       Procedure_Heart_Failure_Quality, 
       Procedure_Pneumonia_Quality, 
       Procedure_Hip_Knee_Quality
FROM hospitals_data
WHERE Procedure_Heart_Attack_Quality = 'ABOVE'
   OR Procedure_Heart_Failure_Quality = 'ABOVE'
   OR Procedure_Pneumonia_Quality = 'ABOVE'
   OR Procedure_Hip_Knee_Quality = 'ABOVE';


--Average Procedure Costs by Facility Type
SELECT Facility_Type,
       AVG(Procedure_Heart_Attack_Cost) AS Avg_Heart_Attack_Cost,
       AVG(Procedure_Heart_Failure_Cost) AS Avg_Heart_Failure_Cost,
       AVG(Procedure_Pneumonia_Cost) AS Avg_Pneumonia_Cost,
       AVG(Procedure_Hip_Knee_Cost) AS Avg_Hip_Knee_Cost
FROM hospitals_data
GROUP BY Facility_Type
ORDER BY Facility_Type;
