Select *
From PortfolioProject..['CovidDeaths-05#09#2022$']
Order by 3,4 

--Select *
--From PortfolioProject..['CovidVaccinations-05#09#2022$']
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths-05#09#2022$']
order by 1,2

--Looking at Total Cases vs Total Deaths (Can see for specific countries)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
From PortfolioProject..['CovidDeaths-05#09#2022$']
where location like '%Kingdom%'
order by 1,2

--Looking at Total cases vs Population

Select Location, date, total_cases, Population, (total_deaths/Population)*100 as PercantPopulationInfected
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%Kingdom%'
order by 1,2

--Looking at Countries with Higest Infection Rate comared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_deaths/population)*100 as PercantPopulationInfected
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%Kingdom%'
Group by Location, Population
order by PercantPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%Kingdom%'
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--Breaking things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--showoing the continents with the highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercantage
From PortfolioProject..['CovidDeaths-05#09#2022$']
--where location like '%Kingdom%'
Where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths-05#09#2022$'] dea
Join PortfolioProject..['CovidVaccinations-05#09#2022$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths-05#09#2022$'] dea
Join PortfolioProject..['CovidVaccinations-05#09#2022$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths-05#09#2022$'] dea
Join PortfolioProject..['CovidVaccinations-05#09#2022$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

Create View ViewPercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths-05#09#2022$'] dea
Join PortfolioProject..['CovidVaccinations-05#09#2022$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated