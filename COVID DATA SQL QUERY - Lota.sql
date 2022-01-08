Select * from lotadata..CovidDeaths
where continent is not null  --To avoid printinting out continents in the location columns
order by 3,4

--Country with the most deaths so far
Select location, MAX(total_cases) as overalltotalcases, MAX(cast(total_deaths as int)) as overalltotaldeaths
from lotadata..CovidDeaths
where continent is not null  --To avoid printinting out continents in the location columns
group by location
order by 3 desc



Select * from lotadata..CovidVaccinations
where continent is not null
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from lotadata..CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from lotadata..CovidDeaths
order by 1,2
--4 percent chance of dying in Afghanistan as at 31st of december.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from lotadata..CovidDeaths
where location like '%states%'  -- here they use single quotes
and continent is not null 
order by date
-- 28/04/2021 had peaked in deadrates(6% +) for the United States
-- dropped to 1 percent at the end of 2021



--Deathrates in relation to the population in the United States
Select location, date, population, total_deaths, (total_deaths/population)*100 as deathpercent
from lotadata..CovidDeaths
where location like '%states%'  -- here they use single quotes and lower case
and continent is not null 
order by date

--Percentage of the populace who have contracted covid in United states in the last year.
Select location, date, population, total_cases, (total_cases/population)*100 as percentinfected
from lotadata..CovidDeaths
where location like '%states%'  -- here they use single quotes and lower case
and continent is not null 
order by 2


--What country has the highest percentage infection rate of covid for a day
Select location, population, max(total_cases) maximuminfected, max(total_cases/population)*100 as maxpercentinfected
from lotadata..CovidDeaths
where continent is not null
group by location, population
ORDER BY 4 DESC

Select location, population, date, max(total_cases) maximuminfected, max(total_cases/population)*100 as maxpercentinfected
from lotadata..CovidDeaths
where continent is not null
group by location, population, date
ORDER BY 5 DESC


-- -What country has the highest percentage infection rate of covid
Select location, population, max(total_deaths) as maximuminfected, max(total_deaths/population)*100 as totalpercentdeaths
from lotadata..CovidDeaths
group by location, population
order by 4 desc


--Countries with the highest death count
Select location, max(cast(total_deaths as int)) as totaldeathcount
from lotadata..CovidDeaths
where continent is not null 
group by location
order by totaldeathcount desc


Select location, max(cast(total_deaths as int)) as totaldeathcount
from lotadata..CovidDeaths
where continent is null 
and location not in ('World', 'European Union', 'International', 'Low income', 'Upper middle income', 'High income', 'Lower middle income')
group by location
order by totaldeathcount desc



-- CONTINENTAL DATA
Select continent, max(cast(total_deaths as int)) as totaldeathcount
from lotadata..CovidDeaths
where continent is not null 
group by continent
order by totaldeathcount desc


--GLOBAL
--Most deaths occured on the 20/01/2021
Select date, SUM(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) as totaldeaths_casesratio
from lotadata..CovidDeaths
where continent is not null
group by date
order by  3 desc

--Most cases/deaths across the world
Select SUM(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) as totaldeaths_casesratio
from lotadata..CovidDeaths
where continent is not null
--group by date
order by  3 desc



--Joining both tables with dea and vac as short forms for tables



SELECT *
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Total number of fully vaccinated people in the world per location and total deaths
SELECT vac.location, MAX(population) as totalpopulation, MAX(convert(bigint, vac.people_fully_vaccinated)) as totalvaccinations, MAX(cast(dea.total_deaths as int)) as totaldeaths
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null
group by vac.location
order by 3 desc
--CHINA, INDIA, UNITED STATES are top 3 countries with most vaccinations



--CONTINENTAL VACCINATIONS
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


--  RUNNING TOTAL OF VACCINATIONS AGAINST POPULATION IN PERCENTAGE USING CTE'S
-- CTE's
With PopvsVac (continent, location, date,population,  new_vaccinations, cummincreasevac) as 
(
-- new vaccinations per day for each country, as well as cummulativetotals(runningtotal)
SELECT dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cummincreasevac
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--and dea.location like '%states%'
--order by 2, 3
)

Select *, (cummincreasevac/population) * 100 
from PopvsVac



--TEMP TABLE
-- --  RUNNING TOTAL OF VACCINATIONS AGAINST POPULATION IN PERCENTAGE USING TEMP TABLE
Drop table if exists Percentagecummtotalofvaccinated
--Drop table if exists #Percentagecummtotalofvaccinated  -- I wanted to edit the table.
Create Table #Percentagecummtotalofvaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummincreasevac numeric
)

Insert into #Percentagecummtotalofvaccinated
SELECT dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cummincreasevac
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--and dea.location like '%states%'
--order by 2, 3

Select *,  (cummincreasevac/population)*100
from #Percentagecummtotalofvaccinated

-- CREATE VIEW
use lotadata
go
CREATE VIEW cummtotalofvaccinated as
SELECT dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as cummincreasevac
FROM lotadata..CovidDeaths dea
Join lotadata..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3



Select * from  cummtotalofvaccinated