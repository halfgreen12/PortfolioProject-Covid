Select *
	From [PortfolioProject-Covid]..CovidDeaths
	--Where continent is not null
	order by 3,4

--Select *
--	From [PortfolioProject-Covid]..CovidVaccinations
--	order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
	From [PortfolioProject-Covid]..CovidDeaths
	order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From [PortfolioProject-Covid]..CovidDeaths
	Where location like '%states%'
	order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
	From [PortfolioProject-Covid]..CovidDeaths
	order by 1,2

--Looking at countries with highest infection rate compared to Population
Select location, population, MAX(total_cases) as  HisghestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
	From [PortfolioProject-Covid]..CovidDeaths
	Group by location, population
	order by PercentPopulationInfected desc


--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as  TotalDeathCount  --Max((total_deaths/population))*100 as PercentPopulationInfected
	From [PortfolioProject-Covid]..CovidDeaths
	Where continent is not null
	Group by location
	order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as  TotalDeathCount  --Max((total_deaths/population))*100 as PercentPopulationInfected
	From [PortfolioProject-Covid]..CovidDeaths
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc



--GLOBAL NUMBERS
--Total global death death percentage

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From [PortfolioProject-Covid]..CovidDeaths
	Where continent is not null
	--Group By date
	order by 1,2




--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
--, (RollingPeopleVaccinated/population)*100 --wont work need to use CTE
From [PortfolioProject-Covid]..CovidDeaths dea
Join [PortfolioProject-Covid]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
Select*, (Rolling
From PopvsVac

--USE CTE
With PopvsVac (Continent, loaction, date, population , New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
From [PortfolioProject-Covid]..CovidDeaths dea
Join [PortfolioProject-Covid]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
From [PortfolioProject-Covid]..CovidDeaths dea
Join [PortfolioProject-Covid]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacccinated
From [PortfolioProject-Covid]..CovidDeaths dea
Join [PortfolioProject-Covid]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated