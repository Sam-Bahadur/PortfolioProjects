select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
	from portfolioProject..CovidDeaths
	where location like '%states%'
	order by 1,2

--looking at total cases vs population
-- shows what population got covid
select Location, date, Population, total_cases,total_deaths,(total_deaths/population)*100 as DeathPercentage
	from portfolioProject..CovidDeaths
	where location like '%states%'
	order by 1,2

--Looking at the countiries with highest infection rate compared to population
select Location, Population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as percentPopulationInfected
	from portfolioProject..CovidDeaths
--where location like '%states%'
	group by Location,Population
	order by percentPopulationInfected desc


--showing countries with highest death count per population
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- breaking down by continent
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 	
	from portfolioProject..CovidDeaths
	where continent is not null
	--group by date
	order by 1,2

-- using CTE for rolling count
with popVsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths dea 
join portfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population) * 100
from popVsVac



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated