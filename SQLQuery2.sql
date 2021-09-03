SELECT*
From PortfolioProject..CovidDeaths$
order by 3,4
where continent is not null

--SELECT*
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are goign to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows chance of dying if you have covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Total cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentPopulationPercentage
From PortfolioProject..CovidDeaths$
Group by Location, population
where continent is not null
order by PercentPopulationPercentage desc


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where --location like '%states%' 
continent is not null and total_cases is not null
--Group by date
order by 1,2

--

Select*
From PortfolioProject..Covid_Vaccinations$

--JOIN THE DEATHS AND VACCINATIONS TABLE--

--Total Population vs Vaccinations--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
		as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With Pop_vs_Vacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
		as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From Pop_vs_Vacc


--Temp Table--
DROP Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
		as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations--

Create View Deaths_by_Continent as

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
--order by TotalDeathCount desc


Create View PopuationPercentage_with_Covid as
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null

Select*
From PopuationPercentage_with_Covid

Create View DeathPercentage_by_Country as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null


