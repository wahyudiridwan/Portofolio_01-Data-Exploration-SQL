-- Active: 1664624935373@@127.0.0.1@3306@portoflio

/* DATA EXPLORATIONS */

/* Data Set that We Use */
     --https://ourworldindata.org/covid-deaths
     --It appears the dataset may have been changed at the source. Please use links below to get the dataset easily
     --https://drive.google.com/drive/folders/1juqxfZ1Im3UXCY711TXgZ3eECstNsH56?usp=sharing



/* Showing all data */
select * from covid_deaths;
select * from covid_vaccinations;


/* Select data that we gonna use */
select continent, iso_code, location, date, new_cases, total_cases, new_deaths, total_deaths, population
from covid_deaths
order by location, date;



/* Compare Total Case vs Total Deaths data */
    /* All Location */
select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
from covid_deaths
order by location, date;

     /* Try to find cases in specific country like 'Indonesia' */
select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
from covid_deaths
where location = 'Indonesia' 
order by date;

     /* Looking at percentage of the population infected with covid in Indonesia*/
select continent, location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
from covid_deaths
where location = 'Indonesia' 
order by date;

      /* Looking at Country with Highest Infection percentage*/ 
select continent, location, population, max(total_cases) as highest_infection, max((total_cases/population)*100) as infection_percentage
from covid_deaths
group by location
order by infection_percentage desc;

     /* Looking at Country with Highest death_percentage*/ 
select continent, location, population, max(total_cases)as max_cases, max(total_deaths) as max_deaths, max((total_deaths/total_cases)*100) as death_percentage
from covid_deaths
group by location
order by death_percentage desc;

     /* Looking at Country with Highest Cases Count*/ 
select continent, location, max(total_cases) as total_cases_count
from covid_deaths
group by location
order by total_cases_count desc;

     /* Looking at Highest Deaths Count for every Country*/ 
select  location, max(total_deaths) as total_deaths_count
from covid_deaths
group by location
order by total_deaths_count desc;

     /* Looking at Highest Deaths Count for every Continent */ 
select continent, max(total_deaths) as total_deaths_count
from covid_deaths
group by continent
order by total_deaths_count desc;




/* Global Data */ 

     -- Looking at Deaths Percentage Global
select date, sum(total_cases) as total_case, sum(total_deaths) as total_death , (sum(total_deaths)/sum(total_cases))*100 as death_percentage_global
from covid_deaths
group by date
order by  date;


    -- Looking at percentage of population who have been vaccinated

create table percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations text,
rolling_vaccinated numeric
);
insert into percent_population_vaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date ) as rolling_vaccinated --(sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date ) /population) *100 as percentage_vaccinated
from covid_deaths as cd
     join covid_vaccinations as cv
          on cd.date=cv.date
          and cd.location=cv.location
order by location, date;

select *, (rolling_vaccinated/population) *100 as percentage_vaccinated
from percent_population_vaccinated;




     --Looking at relationship between vaccinated people and mortality rate  

--select continent, date, location, population, total_cases, total_deaths --((b_deaths/a_cases)*100) as death_percentage
--from covid_deaths
--group by date;
--order by death_percentage desc;

/* Looking at Country with Highest death_percentage */ 
--select continent, location, population, sum(total_cases) over (partition by location order by location) as amount_cases, sum(total_deaths) over (partition by location order by location) as amount_deaths --max((total_deaths/total_cases)*100) as death_percentage
--from covid_deaths
--group by location;
--order by death_percentage desc; 




     /*Data on the effect of vaccinations on mortality */

     --First try use CTE
with eff_vac_death (continent, location, date, new_deaths, rolling_deaths, new_vaccinations, rolling_vaccinated) 
as 
(
select cd.continent, cd.location, cd.date, cd.new_deaths, sum(cd.new_deaths) over (partition by cd.location order by cd.location, cd.date) as rolling_deaths, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date ) as rolling_vaccinated
     join covid_vaccinations as cv
          on cd.date=cv.date
          and cd.location=cv.location
order by location, date
);
select *, (rolling_vaccinated /population) *100 as percentage_vaccinated
from covid_deaths as cd



     -- Second try
create table eff_vac_death
(
continent VARCHAR(255),
location varchar(255),
date datetime,
population numeric,
new_deaths numeric,
rolling_deaths numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
);

insert into eff_vac_death
select cd.continent, cd.location, cd.date, cd.population, cd.new_deaths, sum(cd.new_deaths) over (partition by cd.location order by cd.location, cd.date) as rolling_deaths, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date ) as rolling_vaccinated--(sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date ) /population) *100 as percentage_vaccinated
from covid_deaths as cd
     join covid_vaccinations as cv
          on cd.date=cv.date
          and cd.location=cv.location
order by location, date;

select continent, location, date, new_deaths, rolling_deaths,((new_deaths/population))*100 as percentage_deaths, 
new_vaccinations, rolling_vaccinated, ((new_vaccinations/population) *100) as percentage_vaccinated
from eff_vac_death;




     -- Third try
 
 select cd.location, cd.date, cd.new_deaths, cd.total_deaths, cv.new_vaccinations, cv.total_vaccinations
 from covid_deaths as cd
     join covid_vaccinations as cv
          on cd.date=cv.date
          and cd.location=cv.location
order by location, date;