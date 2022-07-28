Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--  Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%india%'
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%india%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%india%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated


