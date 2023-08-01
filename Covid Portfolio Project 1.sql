Select *
From [Portfolio Project 1].dbo.COVIDDEATH
Where continent is not Null
order by 3, 4


--Select *
--From [SQL Portfolio Project].dbo.['owid-covid-data$']
--order by 3, 4

Select Location, (cast(total_cases_per_million as float)), new_cases, (cast(total_deaths as int)), population
From [Portfolio Project 1].dbo.COVIDDEATH
Where continent is not Null and total_cases_per_million is not NULL and total_deaths is not NULL
Group by Location, total_cases_per_million, new_cases, total_deaths, population
order by 5 DESC

--Total Cases VS Total Deaths (CaseFatalityRate)

  
select 
continent,
total_cases_per_million as HighestCase, 
total_deaths as HighestDeaths,
(MAX(Cast(total_cases_per_million AS float)/Cast(total_deaths as int))*100) AS CaseFatalityRate
From [Portfolio Project 1].dbo.COVIDDEATH
Where continent is Not NULL
GROUP by continent, total_cases_per_million, total_deaths
order by continent, HighestCase, total_deaths 


--total cases vs population

Select Location, date, total_cases_per_million, population, (total_cases_per_million/population)*100 as InfectionPercentage
From [Portfolio Project 1].dbo.COVIDDEATH
where location like '%kingdom%'
order by 1, 2

--highest Deaths country in respect to population 

Select location, population, MAX(total_deaths) as HighestDeathRate, Max((total_deaths/population))*100 as HighestDeathPercentage
From [Portfolio Project 1].dbo.COVIDDEATH
--where location like '%kingdom%'
Where continent is not Null
Group by location, population
order by HighestDeathPercentage desc

--Showing which country got highest Death in figure 

Select location,  MAX(CAST(total_deaths as Int)) as HighestDeath
From [Portfolio Project 1].dbo.COVIDDEATH
--where location like '%kingdom%'
Where continent is not Null
Group by location
order by HighestDeath desc


-- country with highest deathrecorded in respect to Cases


select Location, total_cases_per_million as HighestCase, total_deaths as HighestDeaths, (Cast(total_deaths as int))/(MAX(Cast(total_cases_per_million AS float)*100)) AS HighestDeathRecorded 
From [Portfolio Project 1].dbo.COVIDDEATH
Where continent is Not NULL
GROUP by location, total_cases_per_million, total_deaths
order by HighestDeathRecorded DESC


Select location,   MAX(cast(total_deaths as float)) as HighestDeathCount
From [Portfolio Project 1].dbo.COVIDDEATH
--where location like '%kingdom%'
Where continent is not Null
Group by location
order by HighestDeathCount desc

--GLOBAL COUNT
Select
Location, 
SUM(new_cases) as TotalNewCase, 
SUM(new_deaths) as TotalNewDeath,
SUM(cast(New_cases as int)) / Sum(cast(new_deaths as int))*100 as CaseFatalityRate
From [Portfolio Project 1].dbo.COVIDDEATH
--where location like '%kingdom%'
Where continent is Null
Group by location
order by  Location Desc


SELECT *
FROM
[Portfolio Project 1].dbo.CovidVaccination

--Total Population VS Total Vaccination


SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
(RollingPeopleVaccinated/population)*100 as PopulationVaccinationRatio
FROM 
[Portfolio Project 1].dbo.COVIDDEATH Dea
JOIN [Portfolio Project 1].[dbo].[CovidVaccination] Vac 
ON Dea.location = Vac.Location
AND Dea.date = Vac.date
WHERE Dea.continent is not NULL
ORDER BY Dea.location, Dea.date


--USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
[Portfolio Project 1].dbo.COVIDDEATH Dea
JOIN [Portfolio Project 1].[dbo].[CovidVaccination] Vac 
ON Dea.location = Vac.Location
AND Dea.date = Vac.date
WHERE Dea.continent is not NULL
--ORDER BY Dea.location, Dea.date 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--USING #TEMP TABLE
DROP TABLE if Exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
[Portfolio Project 1].dbo.COVIDDEATH Dea
JOIN [Portfolio Project 1].[dbo].[CovidVaccination] Vac 
ON Dea.location = Vac.Location
AND Dea.date = Vac.date
--WHERE Dea.continent is not NULL
--ORDER BY Dea.location, Dea.date 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated


--Creating View to store data for later use


CREATE view PercentagePopulationVaccinated as

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
SUM (CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.location, Dea.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
[Portfolio Project 1].dbo.COVIDDEATH Dea
JOIN [Portfolio Project 1].[dbo].[CovidVaccination] Vac 
ON Dea.location = Vac.Location
AND Dea.date = Vac.date
WHERE Dea.continent is not NULL
--ORDER BY Dea.location, Dea.date 


Select *
FROM PercentagePopulationVaccinated
