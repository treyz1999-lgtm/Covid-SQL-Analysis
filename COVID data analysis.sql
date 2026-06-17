/*
==========================================================
COVID-19 DATA EXPLORATION PROJECT
==========================================================

Dataset:
    - CovidDeaths
    - CovidVaccinations

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

-- Temporarily disable safe update mode for cleaning operations
SET SQL_SAFE_UPDATES = 0;

-- Fix CovidDeaths date format
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

-- Fix blank new death values
UPDATE CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = ''
;

-- Fix vaccination date format
UPDATE CovidVaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE CovidVaccinations
MODIFY COLUMN date DATE;

-- Fix blank vaccination values
UPDATE CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

-- Re-enable safe update mode
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
COUNTRY-LEVEL ANALYSIS
==========================================================
*/

-- Death percentage by country over time
SELECT
    Location,
    Date,
    Total_Cases,
    Total_Deaths,
    (Total_Deaths / Total_Cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, Date;

-- Infection percentage by country over time
SELECT
    Location,
    Date,
    Population,
    Total_Cases,
    (Total_Cases / Population) * 100 AS InfectionPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, Date;

-- Highest infection rates by country
SELECT
    Location,
    Population,
    MAX(Total_Cases) AS HighestInfection,
    MAX((Total_Cases / Population) * 100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Highest death counts by country
SELECT
    Location,
    MAX(Total_Deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

-- Highest death rates by country
SELECT
    Location,
    MAX((Total_Deaths / Population) * 100) AS PercentPopulationDead
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY PercentPopulationDead DESC;


/*
==========================================================
CONTINENT-LEVEL ANALYSIS
==========================================================
*/

-- Infection rate by continent
SELECT
    Continent,
    MAX(Total_Cases) AS HighestInfectionCount,
    MAX((Total_Cases / Population) * 100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY PercentPopulationInfected DESC;

-- Death counts by continent
SELECT
    Continent,
    MAX(Total_Deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY HighestDeathCount DESC;

-- Fatality rate by continent
SELECT
    Continent,
    SUM(New_Cases) AS TotalCases,
    SUM(New_Deaths) AS TotalDeaths,
    (SUM(New_Deaths) / SUM(New_Cases)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY DeathPercentage DESC;


/*
==========================================================
GLOBAL ANALYSIS
==========================================================
*/

-- Total global cases, deaths, and fatality rate
SELECT
    SUM(New_Cases) AS TotalCases,
    SUM(New_Deaths) AS TotalDeaths,
    (SUM(New_Deaths) / SUM(New_Cases)) * 100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL;

-- Daily global cases, deaths, and fatality rate
SELECT
    Date,
    SUM(New_Cases) AS TotalCases,
    SUM(New_Deaths) AS TotalDeaths,
    (SUM(New_Deaths) / SUM(New_Cases)) * 100 AS GlobalDeathRate
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY Date;


/*
==========================================================
VACCINATION ANALYSIS
==========================================================
*/

-- Rolling vaccinations by country
-- Window function calculates cumulative vaccinations over time
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
FROM CovidDeaths AS death
JOIN CovidVaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY death.location, death.date;

-- Total vaccinations by continent
SELECT
    death.continent,
    SUM(vaccine.new_vaccinations) AS TotalVaccinations
FROM CovidDeaths AS death
JOIN CovidVaccinations AS vaccine
    ON death.location = vaccine.location
   AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
GROUP BY death.continent
ORDER BY TotalVaccinations DESC;

-- Global vaccinations by day
SELECT
    death.date,
    SUM(vaccine.new_vaccinations) AS GlobalVaccinations
FROM CovidDeaths AS death
JOIN CovidVaccinations AS vaccine
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

WITH PopVac AS (
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
    FROM CovidDeaths AS death
    JOIN CovidVaccinations AS vaccine
        ON death.location = vaccine.location
       AND death.date = vaccine.date
    WHERE death.continent IS NOT NULL
)

SELECT *,
       (RollingVaccination / Population) * 100 AS PopulationVaccinationPercentage
FROM PopVac;


/*
==========================================================
VIEWS
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
FROM CovidDeaths AS death
JOIN CovidVaccinations AS vaccine
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
The country with the highest recorded infection rate by 2021 was Andorra,
with approximately 17% of the population infected.

2. Countries with the highest death counts
The United States recorded the highest total death count by 2021,
with approximately 576,232 deaths.

3. Countries with the highest death rates
Hungary had one of the highest death rates relative to population,
at roughly 0.29%.

4. Global death rate trends over time
After visualization, global daily deaths showed a downward trend by 2021
compared to the major peaks observed in 2020.

5. Vaccination rollout trends
Most countries showed gradual vaccination rollouts in waves, with large
initial spikes followed by slower subsequent distribution periods.

==========================================================
*/
