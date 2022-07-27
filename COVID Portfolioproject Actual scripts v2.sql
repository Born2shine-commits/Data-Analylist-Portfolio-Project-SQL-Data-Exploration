select*
From Portfolioproject..CovidDeaths$
where continent is not null
Order by 3,4

--select*
--From Portfolioproject..CovidVaccinations$
--Order by 3,4

--select Data that we are going to be using

select Location,date,total_cases,new_cases,(cast(total_deaths as int))as total_deaths, (cast(new_deaths as int))as new_deaths,population
From Portfolioproject..CovidDeaths$
where continent is not null
Order by 1,2

--Lookoing at Total cases vs Total Deaths
--shows lilkelihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths$
Where location like 'Africa'
and continent is not null
Order by 1,2

---Looking at total cases vs population
---shows what percentage of population got covid

select Location,date,total_cases,population,(total_deaths/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths$
Where location like 'Africa'
and continent is not null
Order by 1,2

--Looking at countries with highest infection Rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths$
where continent is not null
--Where location like 'Africa'
Group by Location,population
Order by percentPopulationInfected desc

--Showing countries with Hihgest Death Count per population


select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths$
where continent is not null
--Where location like 'Africa'
Group by Location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths$
where continent is not null
--Where location like 'Africa'
Group by continent
Order by TotalDeathCount desc
 

 --GLOBAL NUMBERS

 select date,SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths,
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths$
--Where location like 'Africa'
Where continent is not null
Group by date
Order by 1,2

--joining the two tables
select*
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date

	--Looking at Total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.Date)as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With popsvac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
From popsvac



---TEMP TABLE

--Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



----creating views to store data for later visualisation


Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVaccinations$ vac
    on dea.Location=vac.Location
    and dea.date=vac.date
--where dea.continent is not null
--order by 2,3


Select*
From PercentPopulationVaccinated