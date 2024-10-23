SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4



--SELECT Data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Dealths
-- Shows the likelihood of death if you get Covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- Shows percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2



--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing contintents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CONVERT(INT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
WHERE death.continent IS NOT NULL
ORDER by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
WITH PopulationVsVaccin (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CONVERT(INT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
From PopulationVsVaccin



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CONVERT(INT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CONVERT(INT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
WHERE death.continent IS NOT NULL

