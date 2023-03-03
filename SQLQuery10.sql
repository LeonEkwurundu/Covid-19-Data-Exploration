/*
Covid 19 Data Exploration using the table gotten from ourworldindata.org using Nigeria as a case study.

Skills used: Temp Tables, Joins, Creating Views, Converting Data Types, CTE's, Windows Functions, Aggregate Functions
*/


select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select the data we are starting with.
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Looking at Death Percentage in Nigeria (Total Cases vs Total Deaths).
-- This shows the chances of dying in Nigeria.
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%nigeria%'
and continent is not null
order by 1,2

-- Looking at the total cases in Nigeria vs population.
-- This shows infected percent population.
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercent
from PortfolioProject..CovidDeaths
where Location like '%nigeria%'
and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population.
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPopulationPercent
from PortfolioProject..CovidDeaths
group by Location, population
-- where Location like '%nigeria%'
order by InfectedPopulationPercent desc

-- Countries with Highest Death Count per Population.
select location, max(cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject..CovidDeaths
--where location like'%nigeria%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- Breaking things down by Continent.
-- Continents with highest Death count per population.
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing Global Numbers
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Joining CovidDeaths and CovidVaccinations
select *
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date

-- Total Population vs Vaccinations.
-- Showing Percentage of Population that has received at least one Covid Vaccine.
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollOverVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query
with PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollOverVaccinatedPeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollOverVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
 select *, (RollOverVaccinatedPeople/population)*100
 from PopulationVsVaccination

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #vaccinatedpopulationpercent
create table #vaccinatedpopulationpercent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollOverVaccinatedPeople numeric
)
insert into #vaccinatedpopulationpercent
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollOverVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null
 
 select *, (RollOverVaccinatedPeople/population)*100
 from #vaccinatedpopulationpercent





 -- Creating views for visualization
 create view vaccinatedpopulationpercent as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollOverVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null


 create view DeathPercentageNigeria as
 select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%nigeria%'
and continent is not null
--order by 1,2

create view HighestInfectionRate as
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPopulationPercent
from PortfolioProject..CovidDeaths
group by Location, population
-- where Location like '%nigeria%'
--order by InfectedPopulationPercent desc

