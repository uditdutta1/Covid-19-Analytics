SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
ORDER BY 1,2

------------------------------------------------------------------------------------------------

--TOTAL CASES vs TOTAL DEATHS
--showing likelihood of dying if you contract covis in your country;
SELECT location, date, total_cases, new_cases, total_deaths, 
		(total_deaths/total_cases) * 100 AS DeathPercentage
FROM portfolioproject.coviddeaths
WHERE location like 'India%'
ORDER BY 1,2

---------------------------------------------------------------------------------------------

--TOTAL CASES vs POPULATION
--what percaentage of population got covid

SELECT location, date, total_cases, population, 
		(total_cases/population) * 100 AS 	Infected_Population_percentage
FROM portfolioproject.coviddeaths
ORDER BY 5 desc

------------------------------------------------------------------------------------------------


--Which Countries have highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infeted, MAX((total_cases/population)) *100 AS Highest_Percentage_of_population_Infected
FROM portfolioproject.coviddeaths
WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 desc

------------------------------------------------------------------------------------------------

--Which Countries has highest death count per population
SELECT continent, location, MAX((total_deaths)) AS Highest_Total_deaths_count, MAX((total_deaths/population))*100
FROM portfolioproject.coviddeaths
WHERE continent <> ''
GROUP BY continent, location
ORDER BY 3 DESC

------------------------------------------------------------------------------------------------

--showing continents with highest death count
SELECT continent, location, MAX((total_deaths)) AS Highest_Total_deaths_count
FROM portfolioproject.coviddeaths
WHERE continent = ''
GROUP BY continent, location
ORDER BY 3 DESC
------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS
SELECT SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100
FROM portfolioproject.coviddeaths
WHERE continent <> ''

---------------------------------------------------------------------------------------------------

--Total population vs vacination
SELECT deaths.continent, deaths.location, deaths.date, 
	deaths.population, vaccine.new_vaccinations,
	SUM(vaccine.new_vaccinations) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_People_Vaccinated
    ##(Rolling_People_Vaccinated/deaths.population)*100

FROM portfolioproject.coviddeaths AS deaths
JOIN portfolioproject.covidvaccine AS vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date

WHERE deaths.continent <>''
ORDER BY 1,2,3

------------------------------------------------------------------------------------------------

--CTE

WITH Population_vs_Vaccination (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, 
	deaths.population, vaccine.new_vaccinations,
	SUM(vaccine.new_vaccinations) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_People_Vaccinated
   
FROM portfolioproject.coviddeaths AS deaths
JOIN portfolioproject.covidvaccine AS vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date

WHERE deaths.continent <>''
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM Population_vs_Vaccination

------------------------------------------------------------------------------------------------

--TEMP TABLE
use portfolioproject;
DROP TABLE IF EXISTS portfolioproject.temp_VaccinatedPopulationPercentage;
CREATE TABLE portfolioproject.temp_VaccinatedPopulationPercentage
(
Continent varchar(255),
location varchar(255),
DATE datetime,
Population numeric,
New_Vaccinations text,
Rolling_People_Vaccinated numeric
);

INSERT INTO temp_VaccinatedPopulationPercentage
SELECT deaths.continent, deaths.location, deaths.date, 
	deaths.population, vaccine.new_vaccinations,
	SUM(vaccine.new_vaccinations) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_People_Vaccinated

FROM portfolioproject.coviddeaths AS deaths
JOIN portfolioproject.covidvaccine AS vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date
WHERE deaths.continent <>'';

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM portfolioproject.temp_VaccinatedPopulationPercentage;

------------------------------------------------------------------------------------------------

--Creating view to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated AS

SELECT deaths.continent, deaths.location, deaths.date, 
	deaths.population, vaccine.new_vaccinations,
	SUM(vaccine.new_vaccinations) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_People_Vaccinated
    ##(Rolling_People_Vaccinated/deaths.population)*100

FROM portfolioproject.coviddeaths AS deaths
JOIN portfolioproject.covidvaccine AS vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date

WHERE deaths.continent <>''
ORDER BY 1,2,3

------------------------------------------------------------------------------------------------
