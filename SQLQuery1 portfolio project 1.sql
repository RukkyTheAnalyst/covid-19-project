# Covid 19 Project : SQL

select *
from [Portfolio project 1]..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from [Portfolio project 1]..CovidVaccinations$
--order by 3,4

--select DATA that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project 1]..CovidDeaths$
order by 1,2

--looking at Total cases vs Totaldeath

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
order by 1,2


--country wth highest covid infection rate

select location, population, max(total_cases) as HighestInfectedCountry, max(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--country wth highest Death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location 
order by TotalDeathCount desc


--by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--showing continent with highest DeathCount

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select SUM( new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio project 1]..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--total population vs vaccination


select Dea.continent, Dea.location, dea.date, dea.population, Vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (Rollingpeoplevaccinated/population)*100 
from [Portfolio project 1]..CovidDeaths$ Dea
join [Portfolio project 1]..CovidVaccinations$ Vac
on Dea.location =Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (Rollingpeoplevaccinated/population)*100 
from [Portfolio project 1]..CovidDeaths$ dea
join [Portfolio project 1]..CovidVaccinations$ Vac
on Dea.location =Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac



--temp table

drop table if exists #percentagePopulationVaccinated
create table #percentagePopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentagePopulationVaccinated
select Dea.continent, Dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (Rollingpeoplevaccinated/population)*100 
from [Portfolio project 1]..CovidDeaths$ dea
join [Portfolio project 1]..CovidVaccinations$ Vac
on Dea.location =Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentagePopulationVaccinated



---creating view to store data for visualizations 

create view percentagePopulationsVaccinated as
select Dea.continent, Dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (Rollingpeoplevaccinated/population)*100 
from [Portfolio project 1]..CovidDeaths$ dea
join [Portfolio project 1]..CovidVaccinations$ Vac
on Dea.location =Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

select *
from percentagePopulationVaccinated
