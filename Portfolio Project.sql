select * from CovidDeaths$
order by 3,4;


--Death percentage in United State
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDeaths$
Where location like '%states%'
order by 1,2;


--Total cases VS Population
-- Percentage of total Covid cases compared to population in United State

select location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfCovidCase
from CovidDeaths$
Where location like '%states%'
order by 1,2;



--Countries with highest infection rate compared to their Population

select location, population, date, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from CovidDeaths$
Group by location, population, date
order by PercentPopulationInfected DESC;
 


--Total death cases in each continent

select continent,  MAX(Cast(total_deaths as INT)) AS TotalDeathCount
from CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount DESC;


--Total cases, Total death and Death Percent 
Select date, SUM(new_cases) AS Toatl_cases, SUM(cast(new_deaths AS INT)) AS Total_deaths, 
SUM(Cast(new_deaths as INT))/SUM(new_cases) * 100 AS DeathPercentage
from CovidDeaths$
Where continent is not null
Group by date
order by 1, 4 DESC




--Global Total cases, Total death and death Percent

Select SUM(new_cases) AS Toatl_cases, SUM(cast(new_deaths AS INT)) AS Total_deaths, 
SUM(Cast(new_deaths as INT))/SUM(new_cases) * 100 AS DeathPercentage
from CovidDeaths$
Where continent is not null
order by 1,2;


-- Total death count for each continent
Select location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
from CovidDeaths$
Where continent is null AND location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location 
order by TotalDeathCount DESC


-- Joining the Covid and Vaccination table
select * 
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date;



select de.continent, de.location, de.date, de.population, va.new_vaccinations 
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date
Where de.continent is not null
order by 2,3;


-- Using Partition by
select de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (partition by de.location order by de.location, de.date) AS SumPeopleVaccinated
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date
Where de.continent is not null
order by 2,3;



--PERCENTAGE POPULATION OF PEOPLE VACCINATED USING CTE

WITH popVSvacc (continent, location, date, population, new_vaccinations, SumPeopleVaccinated)
AS
(
select de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (partition by de.location order by de.location, de.date) AS SumPeopleVaccinated
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date
Where de.continent is not null
)

select *, (SumPeopleVaccinated/population)*100
from popVSvacc; 



--CREATING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated   
Create table #PercentPopulationVaccinated (continent VARCHAR(255),
										   location VARCHAR(255),
										   date datetime,
										   population INT,
										   new_vaccinations INT,
										   SumPeopleVaccinated INT)
INSERT INTO #PercentPopulationVaccinated
select de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations AS INT)) 
OVER (partition by de.location order by de.location, de.date) AS SumPeopleVaccinated
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date

select *, (SumPeopleVaccinated/population)*100
from #PercentPopulationVaccinated ; 


--CREATING VIEW

CREATE VIEW PercentPopulationVaccinated2
AS
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
SUM(cast(va.new_vaccinations AS INT)) OVER (partition by de.location order by de.location, de.date) AS SumPeopleVaccinated
from CovidDeaths$ de
join CovidVaccination$ va
On de.location = va.location
AND de.date = va.date
where de.continent is not null;

select * from PercentPopulationVaccinated2