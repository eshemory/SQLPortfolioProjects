-- Check to make sure the tablse were imported correctly

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Looking at Total Cases vs Population
-- Proportion of population that contracted COVID

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as MaxInfectionCount, MAX((total_cases/population))*100 as MaxInfectionRate
From PortfolioProject..CovidDeaths
Group By population, location
Order by MaxInfectionRate desc

-- Looking at Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount desc

-- Looking at Coninents

-- Showing Continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc

-- Global Numbers

-- Time Series

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

-- Global numbers for total cases, total deaths and death percentage.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by 
dea.location, dea.date) as Cumulative_Vaccinations
--, (Cumulative_Vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Cumulative_Vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by 
dea.location, dea.date) as Cumulative_Vaccinations
--, (Cumulative_Vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Cumulative_Vaccinations/Population)*100 as Cumulative_Vac_Percentage
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Coninent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Cumulative_Vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by 
dea.location, dea.date) as Cumulative_Vaccinations
--, (Cumulative_Vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and
	dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (Cumulative_Vaccinations/Population)*100 as Cumulative_Vac_Percentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by 
dea.location, dea.date) as Cumulative_Vaccinations
--, (Cumulative_Vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
