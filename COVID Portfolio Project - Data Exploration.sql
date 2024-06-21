
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4


-------------------------------------------------------------------------------------------------------------------------

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS deathPercentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS deathPercentage
FROM CovidAnalysis..CovidDeaths
Where location like '%Portugal'
ORDER BY 2


-------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date,population,total_cases, (CAST(total_cases AS float) / CAST(population AS float)*100) AS infectionRate
FROM CovidAnalysis..CovidDeaths
--Where location like '%Portugal'
WHERE continent is not null
ORDER BY 1,2


-------------------------------------------------------------------------------------------------------------------------
-- Showing Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathsCount
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
Group by location
ORDER BY TotaldeathsCount DESC

-------------------------------------------------------------------------------------------------------------------------
-- Showing Continent with Highest Death Count
SELECT continent, SUM(new_deaths) as TotalDeathsCount
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY TotalDeathsCount DESC


-------------------------------------------------------------------------------------------------------------------------
-- Global Numbers Until Today
SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null

-------------------------------------------------------------------------------------------------------------------------
--Global Numbers 2020
SELECT '2020' AS Year, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
and date like '%2020%'

-------------------------------------------------------------------------------------------------------------------------
--Global Numbers 2021
SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidAnalysis..CovidDeaths
WHERE continent is not null
and date like '%2021%'

-------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Population vs Vaccinations

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
FROM CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
FROM PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
FROM CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From #PercentPopulationVaccinated

-------------------------------------------------------------------------------------------------------------------------

-- Creating view to store data for later visualizations

Create view PercentaPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
FROM CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentaPopulationVaccinated


--Select dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, vac.people_fully_vaccinated
--, (CAST(dea.total_deaths AS float) / CAST(dea.population AS float)) * 100 AS DeathPercentage
--, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--FROM CovidAnalysis..CovidDeaths dea
--Join CovidAnalysis..CovidVaccinations vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null


Select CovidDeaths.location, CovidDeaths.date, total_cases, total_deaths, total_vaccinations
FROM CovidAnalysis..CovidDeaths
Left JOIN CovidAnalysis..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
order by 1,2


Select *
FROM CovidAnalysis..CovidDeaths


Select *
FROM CovidAnalysis..CovidVaccinations
order by location,date