select * from Project1..CovidDeaths
order by 3,4

--select * from Project1..CovidVaccinations
--order by 3,4


-- selecting the data we want
select Location,date,total_cases,new_cases,total_deaths,population
from Project1..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows how likely its that you might die if you get infected
select Location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Project1..CovidDeaths
order by 1,2

-- looking at Egypt's percentage 
select Location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Project1..CovidDeaths
where location = 'Egypt'
order by 1,2

-- looking at total cases vs population
-- shows the percentage of infected
select Location,date,population,total_cases, (total_cases/population) * 100 as InfectedPercentage
from Project1..CovidDeaths
where location = 'Egypt'
order by 1,2

	
-- looking at countries with the highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as InfectedPercentage
from Project1..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- showing countries with the highest deaths count compared to population 
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from Project1..CovidDeaths
where continent is not null
group by location
order by 2 desc


--showin continents with the highest deaths count compared to population 
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from Project1..CovidDeaths
where continent is null
group by location
order by 2 desc

-- using continents 
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from Project1..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- global numbers by date 
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Project1..CovidDeaths
where continent is not null
group by date
order by 1,2

-- global numbers 
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Project1..CovidDeaths
where continent is not null
order by 1,2

-- looking at both tables joined 
select * from Project1..CovidDeaths dea join Project1..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

-- looking at total population vs vaccinantions
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from Project1..CovidDeaths dea join Project1..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- total vaccination partitioned by location 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int, vac.new_vaccinations))
over(partition by dea.location order by dea.location, dea.date) as total_vaccinations
from Project1..CovidDeaths dea join Project1..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with PopvsVac(continent, location, date, population, new_vaccination, total_vaccinations) as	
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int, vac.new_vaccinations))
over(partition by dea.location order by dea.location, dea.date) as total_vaccinations
from Project1..CovidDeaths dea join Project1..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

select *, (total_vaccinations/population)*100 as total_vac_pct
from PopvsVac


drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinations
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (total_vaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinations
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
 