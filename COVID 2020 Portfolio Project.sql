SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location LIKE '%states%'
AND Continent IS NOT NULL
ORDER BY 1,2 

-- Total Cases vs Population
SELECT Location, Date, Total_cases, Population, (Total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
ORDER BY 1,2 

-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(Total_cases) AS HighestInfectionCount, MAX((Total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population
SELECT Continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT Date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,
 dea.Date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,
 dea.Date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- VIEW

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated