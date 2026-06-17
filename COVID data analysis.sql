/*
==========================================================
COVID-19 DATA EXPLORATION PROJECT
==========================================================

Dataset:
    CovidDeaths
    CovidVaccinations

Objectives:
    - Data Cleaning
    - Infection Analysis
    - Mortality Analysis
    - Vaccination Analysis
    - CTEs
    - Views
==========================================================
*/


/*
==========================================================
DATA CLEANING & VALIDATION
==========================================================
*/

-- Fix CovidDeaths date format

SET SQL_SAFE_UPDATES = 0;

UPDATE CovidDeaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE CovidDeaths
MODIFY COLUMN date DATE;

-- Fix blank death values

UPDATE CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = '';

ALTER TABLE CovidDeaths
MODIFY COLUMN total_deaths INT;

-- Fix blank continent values

UPDATE CovidDeaths
SET continent = NULL
WHERE continent = '';

-- Fix blank new_deaths values

UPDATE CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = '';

-- Fix vaccination date format

UPDATE CovidVaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE CovidVaccinations
MODIFY COLUMN date DATE;

-- Fix blank vaccination values

UPDATE CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

SET SQL_SAFE_UPDATES = 1;


/*
==========================================================
VALIDATION
==========================================================
*/

DESCRIBE CovidDeaths;

DESCRIBE CovidVaccinations;

SELECT *
FROM CovidDeaths
LIMIT 10;

SELECT *
FROM CovidVaccinations
LIMIT 10;


/*
==========================================================
Data by country
==========================================================
*/
-- Death Percentage
SELECT Location,
       Date,
       Total_Cases,
       Total_Deaths,
       (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, Date;

-- Infection Percentage
SELECT Location,
       Date,
       Population,
       Total_Cases,
       (Total_Cases/Population)*100 AS InfectionPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, Date;

-- Highest Infection Rates
SELECT Location,
       Population,
       MAX(Total_Cases) AS HighestInfection,
       MAX((Total_Cases/Population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Highest Death Counts
SELECT Location,
       MAX(Total_Deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

-- Highest death rates per country
SELECT
    Location,
    MAX((Total_Deaths / Population) * 100)
        AS PercentPopulationDead
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY PercentPopulationDead DESC;


/*
==========================================================
Data by continent
==========================================================
*/

-- Infection Rate
SELECT
    Continent,
    MAX(Total_Cases) AS HighestInfectionCount,
    MAX((Total_Cases / Population) * 100)
        AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY PercentPopulationInfected DESC;

-- Death Counts
SELECT Continent,
       MAX(Total_Deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY HighestDeathCount DESC;

-- Death Rate / Fatality 
SELECT Continent,
       SUM(New_Cases) AS TotalCases,
       SUM(New_Deaths) AS TotalDeaths,
       (SUM(New_Deaths)/SUM(New_Cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY DeathPercentage DESC;


/*
==========================================================
Global Data
==========================================================
*/
 -- Total Cases, Deaths, and Fatality 
 
SELECT SUM(New_Cases) AS TotalCases,
       SUM(New_Deaths) AS TotalDeaths,
       (SUM(New_Deaths)/SUM(New_Cases))*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL;

-- Daily cases, deaths, fatality

SELECT Date,
       SUM(New_Cases) AS TotalCases,
       SUM(New_Deaths) AS TotalDeaths,
       (SUM(New_Deaths)/SUM(New_Cases))*100 AS GlobalDeathRate
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY Date;

/*
==========================================================
VACCINATION ANALYSIS
==========================================================
*/

-- Rolling Vaccinations by country
SELECT
    death.continent,
    death.location,
    death.date,
    death.population,
    vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations)
        OVER (
            PARTITION BY death.location
            ORDER BY death.date
        ) AS RollingVaccination
FROM coviddeaths AS death
JOIN covidvaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY death.location, death.date;


-- Vaccinations by continent 
  SELECT
    death.continent,
    SUM(vaccine.new_vaccinations) AS TotalVaccinations
FROM coviddeaths AS death
JOIN covidvaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
GROUP BY death.continent
ORDER BY TotalVaccinations DESC;
       
-- Global Vaccinations by day
SELECT
    death.date,
    SUM(vaccine.new_vaccinations) AS GlobalVaccinations
FROM coviddeaths AS death
JOIN covidvaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
GROUP BY death.date
ORDER BY death.date;
       

           
/*
==========================================================
CTEs
==========================================================
*/

WITH PopVac AS
(
    SELECT
        death.continent,
        death.location,
        death.date,
        death.population,
        vaccine.new_vaccinations,
        SUM(vaccine.new_vaccinations)
            OVER (
                PARTITION BY death.location
                ORDER BY death.date
            ) AS RollingVaccination
    FROM coviddeaths AS death
    JOIN covidvaccinations AS vaccine
        ON death.location = vaccine.location
       AND death.date = vaccine.date
    WHERE death.continent IS NOT NULL
)

SELECT *,
       (RollingVaccination / Population) * 100
       AS PopulationVaccinationPercentage
FROM PopVac;

/*
==========================================================
Views
==========================================================
*/

CREATE VIEW PercentPopulationVaccinated AS

SELECT
    death.continent,
    death.location,
    death.date,
    death.population,
    vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations)
        OVER (
            PARTITION BY death.location
            ORDER BY death.date
        ) AS RollingVaccination
FROM coviddeaths AS death
JOIN covidvaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL;


  SELECT *
FROM PercentPopulationVaccinated
ORDER BY location, date;      



/*
==========================================================
KEY FINDINGS
==========================================================

1. Countries with the highest infection rates
The country with the highest recorded infection rate by 2021 was Andora with about a 17% infection rate

2. Countries with the highest death counts
The country with the highest death count recorded was the United States at 576232 total deaths by 2021

3. Continents with the highest fatality rates
The country with the highest fatality rate was Hungary with a rate of 0.29% of the population

4. Global death rate trends over time
It isn't very obvious just looking at the query results but after putting them into Excel and plotting a line chart we can see that the daily global deaths are trending down and are significantly lower than in 2020

5. Vaccination rollout trends by country
Overall we see that each country has gradually begun vaccinations and it appears almost in waves where there is a big peak in vaccinations and then there might be a smaller dip between waves


==========================================================
*/



