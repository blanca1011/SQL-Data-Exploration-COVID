SELECT *
FROM COVID.DBO.Deaths
ORDER BY 3,4;

SELECT *
FROM COVID.DBO.Vaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID.DBO.Deaths
ORDER BY 1,2;

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in unites states
SELECT location, date, total_cases, total_deaths, (CAST (total_deaths AS FLOAT)/CAST (total_cases AS FLOAT))*100 AS DeathPercentage
FROM COVID.DBO.Deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- looking at total cases vs polulation
-- shows what percentage of population got covid in unites sates
SELECT location, date, total_cases, population, (CAST (total_cases AS FLOAT)/CAST (population AS FLOAT))*100 AS InfectionPercentage
FROM COVID.DBO.Deaths
-- WHERE location like '%states%'
ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, (CAST (MAX(total_cases) AS FLOAT)/CAST (population AS FLOAT))*100 AS InfectionPercentage
FROM COVID.DBO.Deaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

-- showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM COVID.DBO.Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- showing continents with highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM COVID.DBO.Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- global numbers per day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM COVID.DBO.Deaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2;

-- accumulative global numbers 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM COVID.DBO.Deaths
WHERE continent IS NOT NULL;



SELECT *
FROM COVID.DBO.Vaccinations

SELECT *
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
;

-- looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location
            ORDER BY dea.location, dea.date)
        AS RollingPeopleVaccinated   
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- use CTE (common table expression)
WITH 
    PopvsVac 
        (continent, 
        location, 
        date, 
        population, 
        new_vaccinations, 
        RollingPeopleVaccinated)
AS 
    (SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
            AS RollingPeopleVaccinated   
    FROM COVID.DBO.Deaths dea 
    JOIN COVID.DBO.Vaccinations vac 
        ON dea.location = vac.location 
        AND dea.date = vac.date 
    WHERE dea.continent IS NOT NULL)
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/CAST(population AS FLOAT))*100
FROM PopvsVac;

-- temp table
CREATE TABLE #PercentPopulationVaccinated 
    (
        continent NVARCHAR(255),
        location NVARCHAR(255),
        date DATETIME,
        population NUMERIC,
        new_vaccinations NUMERIC,
        RollingPeopleVaccinated NUMERIC
    )
INSERT INTO #PercentPopulationVaccinated 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS RollingPeopleVaccinated   
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/CAST(population AS FLOAT))*100
FROM #PercentPopulationVaccinated;



DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
    (
        continent NVARCHAR(255),
        location NVARCHAR(255),
        date DATETIME,
        population NUMERIC,
        new_vaccinations NUMERIC,
        RollingPeopleVaccinated NUMERIC
    )
INSERT INTO #PercentPopulationVaccinated 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS RollingPeopleVaccinated   
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
-- WHERE dea.continent IS NOT NULL
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/CAST(population AS FLOAT))*100
FROM #PercentPopulationVaccinated;


-- creating view to store data for later visualizations
GO
Create View PercentPopulationVaccinated2 as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS RollingPeopleVaccinated   
FROM COVID.DBO.Deaths dea 
JOIN COVID.DBO.Vaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated2;
