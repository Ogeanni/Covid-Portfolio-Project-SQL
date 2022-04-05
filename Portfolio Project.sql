SELECT * FROM CovidDeaths$
ORDER BY 3,4;




--TOTAL CASES VS POPULATION
-- PERCENTAGE OF TOTAL COVID CASES COMPARED TO POPULATION IN UNITED STATES
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfCovidCase
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2;



--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO THEIR POPULATION

SELECT location, population, date, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;
 


--TOTAL DEATHS CASES IN EACH CONTINENT

SELECT continent,  MAX(Cast(total_deaths as INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--TOTAL CASES, TOTAL DEATHS, AND DEATH PERCENT

Select date, SUM(new_cases) AS Toatl_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 4 DESC




--GLOBAL TOTAL CASES, TOTAL DEATHS, AND DEATH PERCENT

SELECT SUM(new_cases) AS Toatl_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2;


-- TOTAL DEATH COUNT FOR EACH CONTINENT

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is null AND location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location 
ORDER BY TotalDeathCount DESC


-- JOINING THE COVID AND VACCINATION TABLE 

SELECT * 
from CovidDeaths$ de
JOIN CovidVaccination$ va
ON de.location = va.location
AND de.date = va.date;



SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations 
FROM CovidDeaths$ de
JOIN CovidVaccination$ va
ON de.location = va.location
AND de.date = va.date
WHERE de.continent is not null
ORDER BY 2,3;


-- USING PARTITION BY
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (PARTITION BY de.location order by de.location, de.date) AS SumPeopleVaccinated
FROM CovidDeaths$ de
JOIN CovidVaccination$ va
ON de.location = va.location
AND de.date = va.date
WHERE de.continent is not null
ORDER BY 2,3;



--PERCENTAGE POPULATION OF PEOPLE VACCINATED USING CTE

WITH popVSvacc (continent, location, date, population, new_vaccinations, SumPeopleVaccinated)
AS
(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (PARTITION BY de.location order by de.location, de.date) AS SumPeopleVaccinated
FROM CovidDeaths$ de
JOIN CovidVaccination$ va
ON de.location = va.location
AND de.date = va.date
WHERE de.continent is not null
)

SELECT *, (SumPeopleVaccinated/population)*100
FROM popVSvacc; 



--CREATING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated   
CREATE TABLE #PercentPopulationVaccinated (continent VARCHAR(255),
										   location VARCHAR(255),
										   date datetime,
										   population INT,
										   new_vaccinations INT,
										   SumPeopleVaccinated INT)
INSERT INTO #PercentPopulationVaccinated
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (PARTITION BY de.location order by de.location, de.date) AS SumPeopleVaccinated
FROM CovidDeaths$ de
JOIN CovidVaccination$ va
On de.location = va.location
AND de.date = va.date

SELECT *, (SumPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated ; 


--CREATING VIEW

CREATE VIEW PercentPopulationVaccinated2
AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(cast(va.new_vaccinations AS INT)) OVER (PARTITION BY de.location order by de.location, de.date) AS SumPeopleVaccinated
FROM CovidDeaths$ de
JOIN CovidVaccination$ va
On de.location = va.location
AND de.date = va.date
WHERE de.continent is not null;

SELECT * FROM PercentPopulationVaccinated2