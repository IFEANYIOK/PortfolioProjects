--SELECT *
--FROM PortfolioProject..CovidDeaths$


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--Order by 3,4;

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Population 
--Shows the percentage of the population that has gotten covid

SELECT location, date, total_cases, population, 
(total_cases/population)*100 as Population_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

SELECT location,population , MAX(total_cases) as total_cases,  
MAX(total_cases/population)*100 as Percentage_population_infected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Percentage_population_infected desc;

--Showing the Country with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount desc;

--BREAKDOWN BY CONTINENT
--Showing the Continents with the Highest Death Count per Population

--SELECT continent, MAX(CAST(total_deaths as int))AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount desc
 

 --Worldwide Numbers

 SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
( SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths$
 WHERE continent IS NOT NULL
 GROUP BY date 
 ORDER BY 1,2
 
 SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
( SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths$
 --WHERE location LIKE '%Nigeria%'
 WHERE continent IS NOT NULL
 --GROUP BY date 
 ORDER BY 1,2

 -- Looking at total Population vs Vaccination

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location = vac.location and dea.date =vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 1,2,3;

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) 
 OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinations
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location = vac.location and dea.date =vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 1,2,3;
 
 -- USE CTE to Show Rolling Percentage of people vaccinated per day per population.

WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinations)
AS (SELECT dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) 
 OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinations
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location = vac.location and dea.date =vac.date
 WHERE dea.continent IS NOT NULL) 

 SELECT *, (RollingPeopleVaccinations/population)*100 RollingPeopleVaccinationspercentage
 FROM PopvsVac;
 

 -- Temp Table

 DROP TABLE IF EXISTS #RollingPercentVac
 CREATE TABLE #RollingPercentVac
 (continent nvarchar(255), 
 location nvarchar(255),
 date datetime,
 population float, 
 new_vaccinations nvarchar(255), 
 RollingPeopleVaccinations nvarchar (255))

 INSERT INTO #RollingPercentVac 
 SELECT dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) 
 OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinations
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location = vac.location and dea.date =vac.date
 --WHERE dea.continent IS NOT NULL;

 SELECT *, (RollingPeopleVaccinations/population)*100 AS RollingPeopleVaccinationspercentage
 FROM #RollingPercentVac
 