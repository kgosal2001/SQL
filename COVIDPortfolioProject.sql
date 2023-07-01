Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4


-- Select the data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if contracted covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs population
-- Shows the likelihood of contracting covid 

Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc


-- LETS BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with Highest Death Count

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null AND new_cases != '0'
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations
-- This gives us an error because we can't do math on a column, (TotalPeopleVaccinated), that was already generated using an aggregate function.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- We have two options to fix this, either using cte or a temp table.

-- USING CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalPeopleVaccinated/population)*100
From PopvsVac


-- Using TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null

Select *, (TotalPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated



Create VIEW HighestInfectionRateCountries as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
--order by InfectedPercentage desc

Select *
From HighestInfectionRateCountries
order by InfectedPercentage desc



Create VIEW HighestDeathContinents as
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
--order by TotalDeathCount desc