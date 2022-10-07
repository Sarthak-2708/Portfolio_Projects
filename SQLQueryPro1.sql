--Basic info from deaths table

select location, date, total_cases, new_cases, total_deaths, population
from[PortfolioProject].[dbo].[Covid_deaths] where continent is not null order by 1,2

--Total cases vs Total deaths (likelihood of dying if you get covid in your country)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death %'
from [PortfolioProject].[dbo].[Covid_deaths] where location='India' order by 1,2

--looking at total cases vs population (Shows what % of population got covid)

select location, date, total_cases, population ,(total_cases/population)*100 as 'Infected by virus %'
from [PortfolioProject].[dbo].[Covid_deaths] where location='India' order by 1,2

select location, date, total_cases, population ,(total_cases/population)*100 as 'Infected by virus %'
from [PortfolioProject].[dbo].[Covid_deaths] where continent is not null order by 1,2

--looking at countries with highest infection rate compared to population

select Location, Population , max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as '% PopulationInfected' 
from [PortfolioProject].[dbo].[Covid_deaths] where continent is not null group by location,population order by '% PopulationInfected' desc

--Showing countries with the highest death count for population

select location, max(cast(total_deaths as bigint)) as DeathCount
from [PortfolioProject].[dbo].[Covid_deaths] where continent is not null group by location order by 2 desc

select location, max(cast(total_deaths as bigint)) as DeathCount, population ,max((total_deaths/population))*100 as 'death by virus %'
from [PortfolioProject].[dbo].[Covid_deaths] where continent is not null group by location,population order by 'death by virus %' desc

--Showing continents with the highest death count(using the first one)

select continent, max(cast(total_deaths as bigint)) as DeathCount
from [PortfolioProject].[dbo].[Covid_deaths] where continent is not null group by continent order by 2 desc

select location, max(cast(total_deaths as bigint)) as DeathCount
from [PortfolioProject].[dbo].[Covid_deaths] where continent is null group by location order by 2 desc

--Total cases and total deaths

select sum(new_cases) as 'Total cases',SUM(cast(new_deaths as bigint)) as 'Total_Deaths', (SUM(cast(new_deaths as bigint))/sum(new_cases))*100 as 'Death %'
from [dbo].[Covid_deaths] where continent is not null

--Basic info from vaccinations table

select * from [dbo].[Covid_vaccinations]

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.[dbo].[Covid_deaths] dea
Join PortfolioProject.[dbo].[Covid_vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.[dbo].[Covid_deaths] dea
Join PortfolioProject.[dbo].[Covid_vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.[dbo].[Covid_deaths] dea
Join PortfolioProject.[dbo].[Covid_vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
