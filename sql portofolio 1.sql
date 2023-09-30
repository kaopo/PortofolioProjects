select * from covdeaths
where continent !=''
order by 3,4;


select location, date, total_cases, new_cases, total_deaths, population from covdeaths
order by 1,2;

-- Looking at total cases vs total deaths
-- How likely is to die from covid if you get it in greece

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from covdeaths
where location like 'greece'
order by 1,2;

-- Total Cases vs Population
-- what percentage of population got covid in greece

select location, date, total_cases, population, (total_cases/population)*100 as Population_per_cases from covdeaths
where location like 'greece'
order by 1,2;

-- Countries with highest Infection rate compared to population

select location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 as Population_per_cases from covdeaths
-- where location like 'greece'
GROUP BY location, population
order by Population_per_cases desc;

-- Countries with the highest Death Count per population

select location, MAX(total_deaths) as Total_Deaths from covdeaths
where continent !=''
GROUP BY location
order by Total_Deaths desc;

-- Continents with the highest Death Count per population

select continent, MAX(total_deaths) as Total_Deaths from covdeaths
where continent !=''
GROUP BY continent
order by Total_Deaths desc;

-- Global numbers

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(new_cases)*100 as death_percentage from covdeaths
-- where location like 'greece'
where continent !=''
group by date
order by 1,2;

-- #2

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(new_cases)*100 as death_percentage from covdeaths
-- where location like 'greece'
where continent !=''
order by 1,2;

-- Total Population vs Total Vaccinations

select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from covdeaths as dea
join covvac as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent !=''
order by 2,3;

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vavvinations, Rolling_People_Vaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from covdeaths as dea
join covvac as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent !=''
-- order by 2,3;
)
Select *, (Rolling_People_Vaccinated/Population)*100 from PopvsVac;

-- Temp Table

drop table if exists PercentPopulationVaccinated;
Create TEMPORARY table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 );

insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covdeaths as dea
join covvac as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent !='';
-- order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100 from PercentPopulationVaccinated;

-- Creating View to store data

percentpopulationvaccinatedCreate View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covdeaths as dea
join covvac as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent !='';
-- order by 2,3;







