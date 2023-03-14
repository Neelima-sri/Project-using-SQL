/*
Covid-19 Data Exploration 
Skills used: Import tables with the correct data type, Aggregate Functions, Joins, CTE's, Temp Tables, Creating Views
Data source:  Retrieved from: 'https://ourworldindata.org/coronavirus' (Online Resource)
*/

-- Check with Deaths table
SELECT * 
from  coviddeaths12
where continent is not null
order by 3,4


-- Select data we are going to use 
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths12
Where continent is not null 
order by 1,2


-- GLOBAL NUMBERS

select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, ROUND(SUM(new_deaths*1.0)/SUM(New_Cases)*100) 
as DeathPercentage
from coviddeaths12
order by 3



-- Select Data that we want to start 
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths12
where continent is not null
order by 3,4

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 AS DeathPercentage
FROM CovidDeaths12
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
ORDER BY 1,2


-- Checking US Death rate status
SELECT location, date, total_cases, total_deaths, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM CovidDeaths12
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
GROUP BY location, date, total_cases, total_deaths
ORDER BY DeathPercentage DESC
----------------------------------------------------------------------------------


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, Population, total_cases, (total_cases*1.0/population)*100 as PercentPopulationInfected
FROM CovidDeaths12
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
order by 1,2

-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths12
WHERE continent IS NULL AND location NOT IN ('World', 'European Union','International')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing location with the highest cases count and death count per population
SELECT continent, location, MAX(total_cases) AS TotalCasesCount, MAX(Total_deaths) as TotalDeathCount
FROM CovidDeaths12
WHERE continent IS  NULL 
GROUP BY continent, location
ORDER BY 4 DESC


-- review the Vaccinations table
SELECT * 
FROM vaccinations


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths12 AS dea
JOIN Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5


-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths12 AS dea
JOIN Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

-- DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated(
Continent VARCHAR(255),
Location VARCHAR(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths12 AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths12 AS dea
JOIN Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5