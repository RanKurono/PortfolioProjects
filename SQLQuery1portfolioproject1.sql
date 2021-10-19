Select *
from PortfolioProject01..CovidDeaths01
where continent is not null
order by 3,4


--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data tat we are going to be using
Select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject01..CovidDeaths01
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths01
where location like '%stan%'
and continent is not null
order by 1,2


--looking at total cases vs population
--shows what percentage of population got Covid

Select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject01..CovidDeaths01
--where location like '%Arab%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select location, population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject01..CovidDeaths01
--where location like '%Arab%'
Group by location,population
order by PercentPopulationInfected desc

--Select location, population, MAX((total_cases/population))*100 as HighestInfectionCount,(total_deaths/total_cases)*100 as PercentPopulationInfected
--from PortfolioProject..CovidDeath$
--where location like '%stan%'
--group by location, population
--order by 1,2

-- showing countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject01..CovidDeaths01
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject01..CovidDeaths01
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, 
SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths01
--where location like '%stan%'
WHERE continent is not null
--group by date
order by 1,2

--Looking at total population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int, vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths01 dea
JOIN PortfolioProject01..CovidVaccinations01 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3

--Use CTE

With Popvsvac(Continent, Location, date, Population, New_vaccinations, RollingPopulationVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths01 dea
JOIN PortfolioProject01..CovidVaccinations01 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3
)

Select *, (RollingPopulationVaccinated/Population)*100
from Popvsvac

-- TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric


)
insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths01 dea
JOIN PortfolioProject01..CovidVaccinations01 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
from  #percentpopulationvaccinated

-- creating vieew to store data for later visualization

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths01 dea
JOIN PortfolioProject01..CovidVaccinations01 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

select *
from PercentagePopulationVaccinated