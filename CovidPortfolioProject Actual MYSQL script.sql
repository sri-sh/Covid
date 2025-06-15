
Select * from dbo.CovidDeaths
Select * from dbo.CovidVaccinations;

-- Looking at Total Cases and total deaths for each country

Select Location,Count(total_cases) as total_cases,Count(total_deaths) as total_deaths from dbo.CovidDeaths 
group by location
order by location

-- -- Looking at overall Total Cases Vs Total Deaths for India
Select Location,sum(total_cases) as totalcases,sum(total_deaths) as totaldeaths,(sum(total_cases)/sum(total_deaths))*100 as deathpercent
from dbo.CovidDeaths
where Location = 'India'
group by location

-- Looking at Total Cases Vs Total Deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage 
from dbo.CovidDeaths
where Location = 'India'


--Looking at total cases Vs Population 
--Shows what percentage of population got covid
Select Location,date,Population,total_cases,total_deaths,(total_cases/population)*100 as percentage_population_infected
from dbo.CovidDeaths
where Location = 'India'

-- Looking at countries with highest infection rate compared to population

Select Location,Population,max(total_cases) as Max_total_cases,Max((total_cases/Population))*100 as percentagepopulationinfected
from dbo.CovidDeaths
group by location,population
order by percentagepopulationinfected desc

Alter table dbo.CovidDeaths
alter column total_deaths bigint

--Showing countries with highest death count per Population
Select Location ,Max(total_deaths) as totaldeathcount 
from dbo.CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

Select Location ,Max(total_deaths) as totaldeathcount 
from dbo.CovidDeaths
where continent is  null 
group by location
order by totaldeathcount desc

--Showing continents with highest death count per population
Select continent ,Max(total_deaths) as totaldeathcount 
from dbo.CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- Global Numbers datewise data for 

Select date, sum(new_cases) as total_new_cases ,sum (new_deaths) as total_new_death_count,
sum(new_deaths)/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null
group by date
order by date

--Location with total tests and total vaccinations
Select a.location,a.total_cases,a.total_deaths,b.total_tests,b.total_vaccinations
from dbo.CovidDeaths a 
inner join dbo.CovidDeaths b
on a.Location = b.location 
where a.continent is not null 

-- Looking at total population Vs Vaccinations

Select a.continent, a.location,a.date, a.population,b.new_vaccinations
from dbo.CovidDeaths a
join dbo.CovidVaccinations b
on a.location=b.location
and a.date=b.date
where a.continent is not null
order by 1, 2,3



With POPvsVAC (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
Select a.continent, a.location,a.date, a.population,b.new_vaccinations,
sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
from dbo.CovidDeaths a
join dbo.CovidVaccinations b
on a.location=b.location
and a.date=b.date
where a.continent is not null
)
Select * ,(rolling_people_vaccinated/population)*100 as popvsvacc
from POPvsVAC
-- order by 2, 3

--Temporary table

Create table PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric)

Insert into PercentPopulationVaccinated
Select a.continent, a.location,a.date, a.population,b.new_vaccinations,
sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
from dbo.CovidDeaths a
join dbo.CovidVaccinations b
on a.location=b.location
and a.date=b.date

Select * from PercentPopulationVaccinated

-- Creating Views

Create view percentpeoplevaaccinated as
Select a.continent, a.location,a.date, a.population,b.new_vaccinations,
sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
from dbo.CovidDeaths a
join dbo.CovidVaccinations b
on a.location=b.location
and a.date=b.date
where a.continent is not null