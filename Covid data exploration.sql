--Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Loking at total cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Loking at total cases vs Total Deaths
--Shows what percentage of population got covid
select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at countries with highest INfection Rate compared to Population

select Location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Group By Location, Population
order by PercentPopulationInfected desc


---Showing Countries with Highest Death Count per Population

select Location, MAX(CAST(total_deaths as int))as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By Location
order by TotalDeathCount desc


--BROKEN DOWN BY CONTINENT
--Showing continents with the highest death count per population

select continent, MAX(CAST(total_deaths as int))as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2



--Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With  PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
From
PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From
#PercentPopulationVaccinated


--CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select* from

PercentPopulationVaccinated


Create view ContinentDeathCount as 
select continent, MAX(CAST(total_deaths as int))as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By continent
--order by TotalDeathCount desc
Select* from ContinentDeathCount


Create view GlobalNumbers as
select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date
--order by 1,2
Select* from GlobalNumbers