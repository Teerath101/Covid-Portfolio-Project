/*
Covid-19 Data

Skills Used: Joins, CTE's, TEMP tables, Windows Functions. Aggregate Functions, Creating Views, Converting Data types

*/

Select * 
from [PortFolio  Project]..[Covid Deaths]
where continent is  not null
order by 3,4



-- Select Inital Data to start with
Select Location, date, Total_cases, new_cases, total_deaths, population
from [PortFolio  Project]..[Covid Deaths]
where continent is not null
order by 1,2


-- Loking for total cases vs total deaths
-- Show likelihood of  dying if you contract covid in your country

Select Location, date, Total_cases, total_deaths,  (total_deaths/total_cases)*100 as Death_Percentage
From [PortFolio  Project]..[Covid Deaths]
Where location like '%brazil%'
and continent  is not null
Order by 1,2

-- Looking at total cases vs population
-- Show what percentage of population got Covid 

Select Location, date, population, Total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from [PortFolio  Project]..[Covid Deaths]
-- where location like '%India%'
order by 1,2

-- Looking at coutries with highest Infection rate compared to  population

Select Location, population, max(Total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from [PortFolio  Project]..[Covid Deaths]
-- where location like '%India%'
Group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with highest deathcount per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [PortFolio  Project]..[Covid Deaths]
-- where location like '%India%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break thing down by Continents
-- Showing the continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [PortFolio  Project]..[Covid Deaths]
-- where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--  GLOBAL NUMBERS

Select sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from [PortFolio  Project]..[Covid Deaths]
-- where location like '%brazil%'
where continent is not null
-- Group by date	
order by 1,2


-- Looking at Total Population vs Vacinations
-- Shows Percentage of Populations that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortFolio  Project]..[Covid Deaths] dea
Join [PortFolio  Project]..[Covid vacinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, population, New_vacinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortFolio  Project]..[Covid Deaths] dea
Join [PortFolio  Project]..[Covid vacinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac


-- Using TEMP table to perform same operations as above

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortFolio  Project]..[Covid Deaths] dea
Join [PortFolio  Project]..[Covid vacinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is null
-- order by 2,3

Select *, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for visulation

Create View PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortFolio  Project]..[Covid Deaths] dea
Join [PortFolio  Project]..[Covid vacinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null


Select *
from PercentPopulationVacinated



