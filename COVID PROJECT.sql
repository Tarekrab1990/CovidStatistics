
--showing Death Rate per country
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases))*100 AS DeathRatio
FROM 
    Covid..CovidDeaths
WHERE location like 'algeria'
ORDER BY 
    1,2


-- showing Total cases vs Population
-- the percentage of population who got COVID 19

SELECT 
    location, 
    date, 
	population,
    total_cases, 
	
    (CONVERT(FLOAT, total_cases) /  population)*100 AS CasesPerPopulation
FROM 
    Covid..CovidDeaths

ORDER BY
	1,2

--showing countries with highest contamination rate 

SELECT 
    location, 
	population,
    MAX(total_cases) as highest_contamination_count, 
	
    MAX((CONVERT(FLOAT, total_cases) /  population))*100 AS MaxCasesPerPopulation
FROM 
    Covid..CovidDeaths
GROUP BY 
	location, 
	population
ORDER BY
MaxCasesPerPopulation DESC

-- death ratio per country

SELECT 
    location, 
    MAX( CAST(total_deaths as int)) as HighestDeathCount
FROM 
    Covid..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location 
	
ORDER BY
	HighestDeathCount DESC

-- death ratio per continent

SELECT 
    continent, 
    MAX( CAST(total_deaths as int)) as HighestDeathCount
FROM 
    Covid..CovidDeaths
WHERE 
	continent IS NOT NULL 
GROUP BY 
	continent 
	
ORDER BY
	HighestDeathCount DESC

-- death ratio accross the world
SELECT
    MIN(date) AS [starting_date],
    MAX(date) AS [last_check_date],
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_death,
    (SUM(CAST(new_deaths AS int)) * 100.0 / NULLIF(SUM(new_cases), 0)) AS death_ratio
FROM
    Covid..CovidDeaths
WHERE
    continent IS NOT NULL;

--Vaccinations VS Populations
WITH VacVSPop (continent, location, date, population, new_vaccination, cumulative_vac_per_country)
as
(
SELECT 
    dth.continent,
    dth.location,
    dth.date,
    dth.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
	OVER 
		(PARTITION BY dth.location 
		ORDER BY 
			dth.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_vac_per_country
FROM
    Covid..CovidDeaths dth
JOIN Covid..CovidVaccins vac
    ON dth.location = vac.location
    AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
--ORDER BY
--    dth.location, dth.date;
)
SELECT *, (cumulative_vac_per_country/population)*100 as vaccination_ratio
from VacVSPop



-- Temp Table
DROP TABLE IF exists #PercentVaccinatedPopulation
CREATE TABLE #PercentVaccinatedPopulation
	
	(continent nvarchar(255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	cumulative_vac_per_country numeric
	)

INSERT INTO #PercentVaccinatedPopulation

SELECT 
    dth.continent,
    dth.location,
    dth.date,
    dth.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
	OVER 
		(PARTITION BY dth.location 
		ORDER BY 
			dth.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_vac_per_country
FROM
    Covid..CovidDeaths dth
JOIN Covid..CovidVaccins vac
    ON dth.location = vac.location
    AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
--ORDER BY
--    dth.location, dth.date

SELECT *, (cumulative_vac_per_country/population)*100 as vaccination_ratio
from #PercentVaccinatedPopulation

-- Creating view to store data for later viz

CREATE VIEW PercentVaccinatedPopulation as

SELECT 
    dth.continent,
    dth.location,
    dth.date,
    dth.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
	OVER 
		(PARTITION BY dth.location 
		ORDER BY 
			dth.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_vac_per_country
FROM
    Covid..CovidDeaths dth
JOIN Covid..CovidVaccins vac
    ON dth.location = vac.location
    AND dth.date = vac.date
WHERE dth.continent IS NOT NULL

SELECT *
from PercentVaccinatedPopulation