SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that I am going to use
SELECT [Location],[date],total_cases,new_cases,total_deaths,[population]
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at total cases vs total deaths 
--Shows the likelihood of dying after contract covid
SELECT [Location],[date],total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

--Total cases vs population
--Shows what percentage of population contract covid
SELECT [Location],[date],total_cases,[population],(total_cases/[population])*100 AS CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2


--Looking at Countries with Highest Infection rate compared to population
SELECT [Location],[population],MAX(total_cases) as HighestInfectionCount,MAX((total_cases/[population]))*100 AS MaxCovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY [Location],[population]
ORDER BY MaxCovidPercentage DESC



-- The Countries with highest death count per populatoin
SELECT [Location],MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY [Location]
ORDER BY TotalDeathCount DESC


-- The Continents with highest death count per populatoin
SELECT [Location],MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY [Location]
ORDER BY TotalDeathCount DESC


-- Global Numbers per date
SELECT [date],SUM(new_cases) AS 'TotalCases',SUM(CAST(new_deaths AS INT)) AS 'TotalDeaths',(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY [date]
ORDER BY 1,2

-- Global Numbers Total
SELECT SUM(new_cases) AS 'TotalCases',SUM(CAST(new_deaths AS INT)) AS 'TotalDeaths',(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null


--Total Population vs Vaccinations using CTE
WITH PopVsVac (continent,[location],[date],[population],new_vaccinations,Cumulative_Vaccinations) 
AS
(
SELECT dea.continent,dea.[location],dea.[date],dea.[population],vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) over(PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS Cumulative_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea JOIN 
PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT *,(Cumulative_Vaccinations/[population])*100 AS Cumulative_Vaccinations_Percentage
FROM PopVsVac


--Total Population vs Vaccinations using TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
[Location]  nvarchar(255),
[Date] datetime,
[Population] numeric,
New_vaccinations numeric,
Cumulative_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.[location],dea.[date],dea.[population],vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) over(PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS Cumulative_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea JOIN 
PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null

SELECT *,(Cumulative_Vaccinations/[population])*100 AS Cumulative_Vaccinations_Percentage
FROM #PercentPopulationVaccinated


--Creating VIEW to store data for Dashboard
DROP VIEW IF EXISTS CumulativePopulationVaccinated
--RUN DROP and CREATE VIEW in separate Executes
CREATE VIEW CumulativePopulationVaccinated AS
SELECT dea.continent,dea.[location],dea.[date],dea.[population],vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) over(PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS Cumulative_Vaccinations
FROM PortfolioProject..CovidDeaths AS dea JOIN 
PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null

-- VIEW Total Death Count Per Continet
DROP VIEW IF EXISTS TotalDeathCountPerContinet
CREATE VIEW TotalDeathCountPerContinet AS
SELECT [Location],MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY [Location]


-- VIEW Countries with highest death count per populatoin
DROP VIEW IF EXISTS TotalDeathCountPerCountries
CREATE VIEW TotalDeathCountPerCountries AS
SELECT [Location],MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY [Location]


--VIEW Countries with Highest Infection rate compared to population
DROP VIEW IF EXISTS MaxCovidPercentagePerCountries
CREATE VIEW MaxCovidPercentagePerCountries AS
SELECT [Location],[population],MAX(total_cases) as HighestInfectionCount,MAX((total_cases/[population]))*100 AS MaxCovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY [Location],[population]


