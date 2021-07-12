SELECT * from Covid_deaths_csv cdc 
order by 3,4

SELECT location , date , total_cases,new_cases ,total_deaths, population 
from Covid_deaths_csv cdc 
order by 1,3

--total cases vs total deaths

SELECT location , date, total_cases, total_deaths, (cast(total_deaths as float)) / (cast (total_cases as float))*100  as death_percentage
from Covid_deaths_csv cdc                          
order by 1,3

--population vs total cases

SELECT location, date , population, total_cases , (cast(total_cases as float)) / (cast (population as float))*100 as infected_percentage
from Covid_deaths_csv cdc 
-- WHERE location like "%ruba%"
order by 1,3

--highest infected country

SELECT location, population, MAX(total_cases) as highest_infections,MAX((cast(total_cases as float)) / (cast (population as float)))*100 as highestinfected_percentage
from Covid_deaths_csv cdc 
group by location , population 
ORDER by highestinfected_percentage desc

--highest deathcount per country

SELECT location, population, MAX(total_deaths) as highest_infections,MAX((cast(total_deaths as float)) / (cast (population as float)))*100 as highestinfected_percentage
from Covid_deaths_csv cdc 
group by location , population 
ORDER by highestinfected_percentage desc

--breaking down in continents

SELECT continent , 
MAX(cast(total_deaths as int )) as total_death_counts
from Covid_deaths_csv cdc 
where continent is not null
group by continent 
order by total_death_counts desc

--Global numbers

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM((cast (new_deaths as float)))/SUM((cast (new_cases as float))) * 100 as deathpercentage
from Covid_deaths_csv cdc 
where continent is not NULL 
--group by date
order by 1,2


--Total population vs total vaccinations

--SELECT cdc.continent ,cdc.location , cdc.date, cdc.population, cvc.new_vaccinations 
--from Covid_deaths_csv cdc 
--join Covid_vaccinations_csv cvc 
--on cdc .location = cvc .location 
--and cdc.date = cvc.date
--where cdc.continent is not null
--order by 1,2,3 

With PopvsVac (Continent, location, Date, population, new_vaccinations,
rollingpeoplevaccinated) AS 
(
SELECT cdc.continent,cdc.location, cdc.date, cdc.population, cvc.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION by cdc.location order by cdc.location,
cdc.date) as rollingpeoplevaccinated
from Covid_deaths_csv cdc 
join Covid_vaccinations_csv cvc 
on cdc .location = cvc .location 
and cdc.date = cvc.date
where cdc.continent is not null
--order by 2,3 
)
SELECT *, (rollingpeoplevaccinated/population)*100
from PopvsVac

--TEMPORARY TABLE

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations
, SUM(cvc.new_vaccinations) OVER (Partition by cdc.Location Order by cdc.location, cdc.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths_csv cdc
Join Covid_vaccinations_csv cvc
	On cdc.location = cvc.location
	and cdc.date = cvc.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- Creating view to store data for visualization

Create view Percent_Population_Vaccinated as
Select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations
, SUM(cvc.new_vaccinations) OVER (Partition by cdc.Location Order by cdc.location, cdc.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_deaths_csv cdc
Join Covid_vaccinations_csv cvc
	On cdc.location = cvc.location
	and cdc.date = cvc.date
where cdc.continent is not null 
--order by 2,3




