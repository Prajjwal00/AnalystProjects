select Location,date,total_cases ,new_cases,total_deaths,population
from SqlPortfolioProj..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases v/s Total deaths
--Shows the likelihood of dying if you contract covid in your country

select Location,date,total_cases ,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [SqlPortfolioProj].[dbo].[CovidDeaths]
where continent is not null
--where location like '%india'
order by 1,2

--Looking at Total Cases vs Total Population
select Location,date,total_cases ,population, total_deaths,(total_cases/population)*100 as PercentPopulationInfected
from SqlPortfolioProj..CovidDeaths
where continent is not null
--where location like '%india'
order by 1,2

--Looking for countries with highest infection Rate compared to population

select Location ,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentPopulationInfected
from SqlPortfolioProj..CovidDeaths
where continent is not null
group by Location,Population
order by PercentPopulationInfected desc

-- Showing the countries with Highest death count
select Location ,max(cast(total_deaths as bigint)) as TotalDeathCount
from SqlPortfolioProj..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
select continent ,max(cast(total_deaths as bigint)) as TotalDeathCount
from SqlPortfolioProj..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as bigint)) as total_deaths,
sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from SqlPortfolioProj..CovidDeaths
where continent is not null
group by Date
order by 1,2

--total cases
select sum(new_cases) as total_cases,sum(cast(new_deaths as bigint)) as total_deaths,
sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from SqlPortfolioProj..CovidDeaths
where continent is not null
order by 1,2
--joining death and vaccination table
--Looking at Total Population vs Vaccinations
--USING CTE
with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from SqlPortfolioProj..CovidDeaths dea
join SqlPortfolioProj..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

---Creating view tom store data for later visualisation
create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Convert(bigint,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from SqlPortfolioProj..CovidDeaths dea
join SqlPortfolioProj..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
