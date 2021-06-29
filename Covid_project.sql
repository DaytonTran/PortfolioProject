USE [Hung Tran];

--Explore the data --
SELECT * 
FROM covid_death
WHERE continent is not null
ORDER BY 3,4 ;

SELECT * 
FROM covid_vaccination
WHERE continent is not null
ORDER BY 3,4;

-- Select the data to explore 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
WHERE continent is not null
ORDER BY 3,4;

--Calculate the percentage of people who died because of COVID-19
--The likelyhood of dying if someone got infected by COVID-19
SELECT location,date, total_cases, total_deaths, total_deaths/total_cases as DeathRate
FROM covid_death
WHERE location = 'Vietnam'
ORDER BY 1,2;

--The percentage of population who got infected by COVID-19
SELECT location,date, total_cases, population, (total_cases/population)*100 as CovidInfectionRate
FROM covid_death
WHERE location = 'Vietnam'
ORDER BY 1,2;

--Country with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS TotaltInfectionCount, MAX(total_cases/population)*100 AS CovidInfectionRate
FROM covid_death
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc;

--Countries with the highest dead count per population
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX(CAST(total_deaths AS int)/population)*100 AS CovidDeathRate
FROM covid_death
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 desc;

--DIVIDE THE DATA INTO CONTINENTS
SELECT continent, MAX(total_cases) AS TotalInfectionCount
FROM covid_death
WHERE continent is not null
GROUP BY continent
ORDER BY TotalInfectionCount desc;


--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM covid_death
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--GLOBAL NUMBERS 
SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS INT)) as NewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM covid_death
WHERE continent is not null
GROUP BY date
ORDER BY date

--Join covid death and covid vaccination together
SELECT * 
FROM covid_death cd
JOIN covid_vaccination cv
ON cd.location = cv.location
and cd.date = cv.date;

--Looking at total population vs vaccination
WITH PopvsVac 
AS
(
SELECT cd.date, cd.location, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS RollingPeopleVaccinated
FROM covid_death cd
JOIN covid_vaccination cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PopulationVaccinatedPercentage
FROM PopvsVac
--WHERE location = 'Vietnam'
ORDER BY date;

--Create View to store data for later visualisation
CREATE VIEW PercentagePopulationVaccinated AS
SELECT cd.date, cd.location, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS RollingPeopleVaccinated
FROM covid_death cd
JOIN covid_vaccination cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null 

