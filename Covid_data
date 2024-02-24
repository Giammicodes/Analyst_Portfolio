Query 1
-- comments: Simple query extracting key information such as location. total case etc and ordering the resultrs by location (1) and date (2)


select
location,
date,
total_cases,
new_cases,
total_deaths,
population


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
order by 1, 2


Quey 2
-- comments: Simple query extracting key information and using calculations to calculate death percentage as a new column and formating the new column using the round() syntax to two decimals places and again ordering by location (1) and date (2). This new table showes the likelihood of dying if contracting covid


select
location,
date,
total_cases,
total_deaths,
round((total_deaths/total_cases)*100,2) as Death_Percentage


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
order by 1, 2

Query 3
-- comments: Simple query looking tital cases vs population, show what % of population has gotten COVID. In this example population is defined in the schema as a string. Therefore to make the calculation work for Big Query we use the CAST() syntax to convert it into an integer


select
location,
date,
population,
total_cases,
round((total_cases/cast(population as INT64))*100,2) as COVID_Percentage


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
where location like 'United Kingdom'
order by 1, 2

Query 4
-- comments: Coubtry with highest infection rate compared to population. The population field is a string, and some events (for reasons unknown) contain an empty string, which cannot be cast to an integer.SAFE_CAST in SQL is a function that attempts to cast a value to a specified data type, and returns NULL if the cast is not possible.


select
location,
population,
Max(total_cases) as Highest_infection_Count,
round(max((total_cases/safe_cast(population as INT64)))*100,2) as Percentage_Population_Infected


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
group by location, population
order by Percentage_Population_Infected desc

Query 5
-- comments: Country with the highest death count per population. The where clause is used as the data groups contitents as location tehrefore where is not nul it'll elimate duplicate


select
location,
max(total_deaths) as total_deaths_count


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
where continent is not null
group by location
order by total_deaths_count desc


Query 6
-- comments: global breakdown by date of total cases and deaths per day. By aggregating new_cases and new_death we can group by date, previosuly the query would have use total_cases which would have resulted in an error due to the need of aggeregate function. sum(new_cases) allows us to have the total_cases per date.


select
date,
sum(new_cases) as Total_Cases,
sum(new_deaths) as Total_Deaths,
round(sum(new_deaths)/sum(new_cases)*100,2) as Death_Percentage


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
where continent is not null
group by date
order by 1, 2


Query 7
-- comments: total population vs vaccination. we use a sum() over to show the cumulative vaccinations and partition by location allows us to split the cumulative by location. Order by allows the numbers to have more clarity as w/o it it'd just show the full total of vaccinations rather than a rolling number


select
A.continent,
a.location,
a.date,
a.population,
b.new_vaccinations,
sum(new_vaccinations) over (partition by a.location order by a.location, a.date) as Cumulative_Vaccinations
from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths A
join chrome-folio-405910.Portfolio_Giammi.Covid_Vaccinations B
on A.location = b.location and a.date = b.date
where a.continent is not null
order by 2 ,3

Query 8
-- comments: usig a CTE we can calculate the vaccination rate per location and per date. Only issue stands with the population data type. Population is a String data type therefore safe_cast is used to convert it into an integer. as a result the aggregation and cte works perfectly. However, it makes the table less impactful as loads of popluatons are missing as a result of the safe_cast




with Table1 as
(


select
A.continent,
a.location,
a.date,
safe_cast(a.population as int64) as population,
b.new_vaccinations,
sum(new_vaccinations) over (partition by a.location order by a.location, a.date) as Cumulative_Vaccinations
from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths A
join chrome-folio-405910.Portfolio_Giammi.Covid_Vaccinations B
on A.location = b.location and a.date = b.date
where a.continent is not null
order by 2 ,3
)


select *,
(Cumulative_Vaccinations/population)*100 as Vaccination_Percentage
from table1

Query 9
-- comments: WIP


CREATE TABLE chrome-folio-405910.Portfolio_Giammi.percentpopulationvaccinated (
  continent STRING,
  location STRING,
  date TIMESTAMP,
  population NUMERIC,
  new_vaccinations NUMERIC,
  Cumulative_Vaccinations NUMERIC
);


INSERT INTO chrome-folio-405910.Portfolio_Giammi.percentpopulationvaccinated
SELECT
  A.continent,
  A.location,
  A.date,
  SAFE_CAST(A.population AS INT64) AS population,
  B.new_vaccinations,
  SUM(B.new_vaccinations) OVER (PARTITION BY A.location ORDER BY A.location, A.date) AS Cumulative_Vaccinations
FROM
  chrome-folio-405910.Portfolio_Giammi.Covid_Deaths A
JOIN
  chrome-folio-405910.Portfolio_Giammi.Covid_Vaccinations B
ON
  A.location = B.location
  AND A.date = B.date
WHERE
  A.continent IS NOT NULL
ORDER BY
  2, 3;


SELECT
  *,
  (Cumulative_Vaccinations / population) * 100 AS Vaccination_Percentage
FROM
  chrome-folio-405910.Portfolio_Giammi.percentpopulationvaccinated;


Query 10
--Comments: create a view which can then be used for data visualisation


Create view  chrome-folio-405910.Portfolio_Giammi.percentpopulationvaccinated1 as
select
A.continent,
a.location,
a.date,
a.population,
b.new_vaccinations,
sum(new_vaccinations) over (partition by a.location order by a.location, a.date) as Cumulative_Vaccinations
from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths A
join chrome-folio-405910.Portfolio_Giammi.Covid_Vaccinations B
on A.location = b.location and a.date = b.date
where a.continent is not null

