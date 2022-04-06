Use [Portfolio Project];
--SUM OF PRICES FOR CUSTOMERS BETWEEN AGE 25-45
SELECT age, SUM(price_willing) 
FROM Logistics$
WHERE age >= 25 AND age <= 45;



--PRICE DISCOUNT(30%) OFF TRAVELERS BY RAILWAY
SELECT gender, location, price_willing, best_mode,
CASE
WHEN best_mode = 'Railway' THEN (price_willing * 0.3) 
ELSE price_willing
END AS Dicounted_price
FROM Logistics$;



--COUNT OF GENDER RESPONDED TO SURVEY
SELECT gender, COUNT(gender)
OVER (PARTITION BY gender) AS Gender_Count
FROM Logistics$;



--COUNT OF ALLL CUSTOMERS BY HOW FREQUENT, PREFERED TIME, AND WHO THEY TRAVEL WITH WHEN THEIR PREFERED MODE OF TRANSPORT IS RAILWAY
SELECT location, 
COUNT(location) OVER (PARTITION BY Location) AS Count_of_state, travel_regularity,
COUNT(travel_regularity) OVER (PARTITION BY travel_regularity) AS Count_of_frequently_travel, day_time,
COUNT(day_time) OVER (PARTITION BY day_time) AS Count_of_preferred_time, travelling_company,
COUNT(travelling_company) OVER (PARTITION BY travelling_company) AS Count_of_travel_partner
FROM Logistics$
WHERE best_mode = 'Railway';



--COUNT OF ALLL CUSTOMERS BY HOW FREQUENT, PREFERED TIME, AND WHO THEY TRAVEL WITH WHEN THEIR PREFERED MODE OF TRANSPORT IS AIR
SELECT location, 
COUNT(location) OVER (PARTITION BY Location) AS Count_of_state, travel_regularity,
COUNT(travel_regularity) OVER (PARTITION BY travel_regularity) AS Count_of_frequently_travel, day_time,
COUNT(day_time) OVER (PARTITION BY day_time) AS Count_of_preferred_time, travelling_company,
COUNT(travelling_company) OVER (PARTITION BY travelling_company) AS Count_of_travel_partner
FROM Logistics$
WHERE best_mode = 'Air';



--COUNT OF ALLL CUSTOMERS BY HOW FREQUENT, PREFERED TIME, AND WHO THEY TRAVEL WITH WHEN THEIR PREFERED MODE OF TRANSPORT IS ROAD
SELECT location, 
COUNT(location) OVER (PARTITION BY Location) AS Count_of_state, travel_regularity,
COUNT(travel_regularity) OVER (PARTITION BY travel_regularity) AS Count_of_frequently_travel, day_time,
COUNT(day_time) OVER (PARTITION BY day_time) AS Count_of_preferred_time, travelling_company,
COUNT(travelling_company) OVER (PARTITION BY travelling_company) AS Count_of_travel_partner
FROM Logistics$
WHERE best_mode = 'Road';



--COUNT OF PREFERED MODE OF TRANSPORT COMPARED TO NUMBER OF RESPONDENT USING TEMP TABLE
DROP TABLE IF EXISTS #TotalResponseVsPreferedMode
CREATE TABLE #TotalResponseVsPreferedMode (best_mode VARCHAR(25),
										  price_willing INT,
										  TotalRespondent INT)
INSERT INTO #TotalResponseVsPreferedMode
SELECT best_mode, price_willing, 
COUNT(respondentID) AS TotalRespondent
FROM Logistics$
GROUP BY price_willing, Best_mode

SELECT (SUM(TotalRespondent))
FROM #TotalResponseVsPreferedMode
 



--COUNT OF LEAST PREFERRED MODE OF TRANSPORTATION AND THE AVERAGE PRICE 
SELECT  COUNT(best_mode) AS Least_mode_transport, AVG(price_willing) avg_price
FROM Logistics$
WHERE best_mode = 'railway';




--RETURN OF MALE CUSTOMERS THAT TRAVELS WITH FRIENDS
SELECT gender, travelling_company
FROM Logistics$
WHERE gender = 'Male' AND travelling_company = 'Friends';



--RETURN OF CUSTOMERS THAT TRAVELS MONTHLY AND ALONE 
SELECT gender, travelling_company, travel_regularity
FROM Logistics$
WHERE travelling_company = 'Alone' AND travel_regularity = 'Monthly';



--COUNT OF MALE CUSTOMERS THAT TRAVELS WITH FRIENDS USING PARTITION ABY
SELECT gender, COUNT(gender)
OVER (PARTITION BY gender) AS Gender_Count
FROM Logistics$
WHERE gender = 'Male' AND travelling_company = 'Friends';



--COUNT OF MALE CUSTOMERS THAT TRAVELS WITH ALONE USING PARTITION BY
SELECT gender, COUNT(gender)
OVER (PARTITION BY gender) AS Gender_Count
FROM Logistics$
WHERE gender = 'Male' AND travelling_company = 'Alone';



--COUNT OF MALE CUSTOMERS THAT TRAVELS WITH THEIR SPOUSE USING PARTITION BY 
SELECT gender, COUNT(gender) AS Gender_Count
FROM Logistics$
WHERE gender = 'Male' AND travelling_company = 'Spouse';



SELECT gender, location, COUNT(gender)
OVER (PARTITION BY Location) AS Gender_Count
FROM Logistics$
WHERE best_mode = 'Road';




--AVERAGE PRICE WILLING TO PAY FOR EACH MODE OF TRANSPORTATION
SELECT  best_mode, 
AVG(price_willing) AS Avgprice, 
SUM(price_willing) AS TotalPrice
FROM Logistics$
GROUP BY best_mode;



SELECT COUNT(best_mode) AS CountHowFrequentTheyTravelMonthly
FROM Logistics$
WHERE travel_regularity = 'Monthly';

