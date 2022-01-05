SELECT * FROM [Portfolio project1]..[covid deaths]

SELECT * FROM [Portfolio project1]..[covid vaccinations]

SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM [Portfolio project1]..[covid deaths]
 where location like '%India%'
order by 1,2

-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as Casespermillion
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 --where location like '%India%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, max(total_cases) as HighestInfection, max((total_cases/population)*100) as PercentCasespermillion
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 --where location like '%India%'
 Group by location, population
order by PercentCasespermillion desc

-- Countries with Highest Death Count per Population

SELECT location, max(cast(total_deaths as int)) as HighestDeath
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 Group by location
order by HighestDeath desc

-- Showing contintents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as HighestDeath
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 Group by continent
order by HighestDeath desc

-- GLOBAL NUMBERS

SELECT date, SUM(cast(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, ((SUM(CAST(new_deaths as int))/SUM(new_cases))*100) as DeathPercentage --total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercent
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 --where location like '%India%'
 Group by date
order by DeathPercentage desc

--Total Population vs Vaccinations

SELECT SUM(cast(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, ((SUM(CAST(new_deaths as int))/SUM(new_cases))*100) as DeathPercentage --total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercent
 FROM [Portfolio project1]..[covid deaths]
 where continent is not null
 --where location like '%India%'
 --Group by date
order by DeathPercentage desc

-- Using CTE to perform Calculation on Partition By in previous query

SELECT x.continent, x.location, x.date, x.population, y.new_vaccinations, SUM(convert(bigint,y.new_vaccinations)) OVER (Partition by x.location order by x.date, x.location) as RollingPeopleVac
FROM [Portfolio project1]..[covid deaths] x
JOIN [Portfolio project1].. [covid vaccinations] y
ON x.location = y.location
and x.date = y.date
--and x.continent = y.continent
where x.continent is not null
order by 2,3

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
SELECT x.continent, x.location, x.date, x.population, y.new_vaccinations, SUM(convert(bigint,y.new_vaccinations)) OVER (Partition by x.location order by x.date, x.location) as RollingPeopleVac
FROM [Portfolio project1]..[covid deaths] x
JOIN [Portfolio project1].. [covid vaccinations] y
ON x.location = y.location
and x.date = y.date
where x.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVac/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists PercentPopulVacc
Create Table PercentPopulVacc
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVac numeric
)
Insert Into PercentPopulVacc
SELECT x.continent, x.location, x.date, x.population, y.new_vaccinations, SUM(convert(bigint,y.new_vaccinations)) OVER (Partition by x.location order by x.date, x.location) as RollingPeopleVac
FROM [Portfolio project1]..[covid deaths] x
JOIN [Portfolio project1].. [covid vaccinations] y
ON x.location = y.location
and x.date = y.date
where x.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVac/population)*100 as RollingPeopleVaccpermil
FROM PercentPopulVacc

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulVacci AS
SELECT x.continent, x.location, x.date, x.population, y.new_vaccinations, SUM(convert(bigint,y.new_vaccinations)) OVER (Partition by x.location order by x.date, x.location) as RollingPeopleVac
FROM [Portfolio project1]..[covid deaths] x
JOIN [Portfolio project1].. [covid vaccinations] y
ON x.location = y.location
and x.date = y.date
where x.continent is not null


SELECT * FROM PercentPopulVacci
