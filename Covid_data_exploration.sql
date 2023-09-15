select location, date, total_cases, new_cases, total_deaths, population
from covid1.covid_death 
where continent is not null
order by 1,2;

-- Percentage of people who passed away after diagnosied with Covid-19 in the United States
select location, date, total_cases, total_deaths, ROUND(100*total_deaths/total_cases, 2) AS death_percentage
from covid1.covid_death 
where location = 'United States'
order by 1,2;

-- Percentage of people who are diagnosied with Covid-19 in the United States
select location, date, total_cases, population, ROUND(100*total_cases/population, 2) AS diagonosis_percentage
from covid1.covid_death 
where location = 'United States'
order by 1,2;

-- Countries with infection rater higher than population
select location, population, max(total_cases) as highest_infection_rate, ROUND(100*max(total_cases)/population, 2) AS diagonosis_percentage
from covid1.covid_death 
group by 1,2
order by diagonosis_percentage desc;

-- Countries with highest death count
select location, max(total_deaths) as highest_death_count
from covid1.covid_death 
where continent is not null
group by 1
order by 2 desc;

-- Expanding to continent
select continent, max(total_deaths) as highest_death_count
from covid1.covid_death 
where continent is not null
group by 1
order by 2 desc;

-- Number ofcases and number of deaths globally
select date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, ROUND(100*SUM(new_deaths)/SUM(new_cases), 2) AS total_death_perctg
from covid1.covid_death 
where continent is not null
group by 1
order by 1,2;

-- Total populations and vaccinations
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(V.new_vaccinations) over(partition by D.location order by D.location, D.date) AS rolling_vaccinations
from covid1.covid_death D join covid1.covid_vacc V on D.location= V.location AND D.date= V.date
where D.continent is not null
order by 2,3;

with CTE AS 
(
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(V.new_vaccinations) over(partition by D.location order by D.location, D.date) AS rolling_vaccinations
from covid1.covid_death D join covid1.covid_vacc V on D.location= V.location AND D.date= V.date
where D.continent is not null
order by 2,3
)
select *, ROUND(rolling_vaccinations*100/population,2) AS rolling_vacc_perctg from CTE;
-- select continent, location, population, MAX(new_vaccinations) AS max_vaccinations from CTE
-- group by 2;

-- Using Temp Table to perform Calculation on Partition By in previous query

use covid1;
DROP Table if exists Population_Vaccinated;
Create Table Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into Population_Vaccinated
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(V.new_vaccinations) over(partition by D.location order by D.location, D.date) AS rolling_vaccinations
from covid1.covid_death D join covid1.covid_vacc V on D.location= V.location AND D.date= V.date
where D.continent is not null
order by 2,3;

select *, ROUND(RollingPeopleVaccinated*100/Population,2) AS rolling_vacc_perctg from Population_Vaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(V.new_vaccinations) over(partition by D.location order by D.location, D.date) AS rolling_vaccinations
from covid1.covid_death D join covid1.covid_vacc V on D.location= V.location AND D.date= V.date
where D.continent is not null
order by 2,3;