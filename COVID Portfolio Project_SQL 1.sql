select * 
from CovidDeaths
where continent is not null
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4

--select data to be used

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths (how many cases per country and deaths and percentage of death from cases)
--shows the likelihood of dying if you contract COVID in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%' and
continent is not null
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%philippines%'
continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
--where location like '%philippines%'
group by location, population
order by PercentPopulationInfected desc

--looking at countries with highest death count per population

select location, max(total_deaths) as HighestDeathCount
from CovidDeaths
where continent is not null
--where location like '%philippines%'
group by location
order by HighestDeathCount desc

-- showing the continents with the highest death count

select continent, max(total_deaths) as HighestDeathCount
from CovidDeaths
where continent is not null
--where location like '%philippines%'
group by continent
order by HighestDeathCount desc

--global numbers

select [date], SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, sum(CAST(new_deaths AS INT))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%' and
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN [new_vaccinations] int

--CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated