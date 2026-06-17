# Global COVID-19 SQL Analysis (2020–2021)

## Overview

This project is an exploratory SQL and data visualization analysis of global COVID-19 trends using historical data from 2020–2021.

Using MySQL for data cleaning and analysis, I explored infection rates, death counts, fatality trends, and vaccination rollouts across countries and continents to better understand the global impact of COVID-19 during its early stages.

This was one of my earlier analytics projects and has been cleaned and organized for portfolio purposes.

---

## Dataset

Source: Our World in Data (COVID-19 Dataset)

The dataset includes global daily COVID-19 statistics such as:

* Total cases
* Total deaths
* New daily cases
* New daily deaths
* Population
* Infection percentages
* Fatality percentages
* Vaccination counts

---

## Project Goals

The primary goals of this analysis were:

* Identify countries with the highest infection rates
* Analyze countries with the highest death counts
* Compare regional and continental COVID outcomes
* Track global fatality trends over time
* Practice real-world SQL querying and analytical workflows

---

## Tools Used

* MySQL
* Tableau
* Git / GitHub

---

## Data Cleaning & Preparation

Before analysis, the dataset required several cleaning steps:

* Converted date columns into SQL date format
* Replaced blank values with `NULL`
* Standardized numeric columns for calculations
* Validated cleaned tables before analysis

---

## SQL Concepts Used

This project involved SQL for cleaning and analysis, including:

* SELECT statements
* Filtering (`WHERE`)
* Aggregations (`SUM`, `MAX`, `AVG`)
* Grouping (`GROUP BY`)
* Joins
* CTEs
* Window Functions
* Views

---

## Analysis Performed

### Global Analysis

* Total global cases
* Total global deaths
* Global fatality percentage over time

### Country-Level Analysis

* Highest infection rates by country
* Highest death counts by country
* Death percentage by country

### Continent-Level Analysis

* Infection rates by continent
* Death counts by continent
* Death rates by continent

### Vaccination Analysis

* Rolling vaccinations by country
* Vaccination totals by continent
* Global vaccination trends over time

---

## Key Findings

* Andorra recorded one of the highest infection rates by 2021, with approximately **17% of the population infected**.
* The United States recorded the highest total death count, with approximately **576,232 deaths** by 2021.
* Hungary had one of the highest death rates relative to population, at roughly **0.29%**.
* Global daily deaths showed a downward trend by 2021 compared to the major peaks observed in 2020.
* Vaccination rollouts generally occurred in waves, with large initial spikes followed by slower distribution periods.

---

## Notes / Limitations

* This project uses historical data from 2020–2021 and should be viewed as a snapshot of the early pandemic period.
* Reported COVID cases and deaths likely underestimate true totals due to testing limitations and reporting differences across countries.
* Data quality and reporting standards varied by region.

---

## Dashboard

Tableau visualizations were created to present SQL query outputs and highlight global COVID-19 trends.
