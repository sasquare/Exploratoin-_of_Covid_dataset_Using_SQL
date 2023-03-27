
--shows the likelyhood of dying if you contact covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM coviddeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

-- Looking at total cases vs population
--Shows what percentages of population got Covid
SELECT location,date, population,total_cases,(total_cases/population)*100 AS PopulationPercentage 
FROM coviddeaths
--WHERE location like '%states%'
ORDER BY PopulationPercentage DESC



--Looking at country with the highest infection rate compared with the Population
SELECT location, population,MAX(total_cases)AS HighestInfectionCount,MAX((total_cases/population))*100 AS PopulationPercentage 
FROM coviddeaths
GROUP BY population,location
--WHERE location like '%states%'
ORDER BY PopulationPercentage DESC


--Showing the country with the highest death count per population
SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM coviddeaths
WHERE continent is not null
GROUP BY location
--WHERE location like '%states%'
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
--WHERE location like '%states%'
ORDER BY TotalDeathCount DESC

--Correct Query for Continent
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM coviddeaths
WHERE location is not null
AND continent is not null
GROUP BY continent
--WHERE location like '%states%'
ORDER BY TotalDeathCount DESC


--Showing the continent with the highest death count per population
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
--WHERE location like '%states%'
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
--SELECT date,sum(new_cases) as totalnewcases, sum(new_deaths)as newdeaths,sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 AS DeathParcentageperday
--FROM coviddeaths
--WHERE continent is not null
--WHERE location like '%states%'
--GROUP BY date
--ORDER BY 1,2

SELECT date,
       SUM(COALESCE(new_cases, 0)) AS totalnewcases,
       SUM(COALESCE(new_deaths, 0)) AS newdeaths,
       CASE
           WHEN SUM(COALESCE(new_cases, 0)) = 0 THEN 0
           ELSE SUM(COALESCE(new_deaths, 0)) / SUM(COALESCE(new_cases, 0)) * 100
       END AS DeathParcentageperday
FROM coviddeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
ON dea.location = vac.location
AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
ON dea.location = vac.location
AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population) AS PeopleVaccinated
FROM PopvsVac;



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
ON dea.location = vac.location
AND dea.date =vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population) AS PeopleVaccinated
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.Location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
ON dea.location = vac.location
AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3