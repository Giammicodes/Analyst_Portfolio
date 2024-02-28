Queries used for Tableu Dashboard:

Tableu link: https://public.tableau.com/app/profile/gian.marco.caramelli/viz/CovidDashboardPortfolio_17091406069980/Dashboard2?publish=yes

1. Global Overview:
select
sum(new_cases) as Total_Cases,
sum(new_deaths) as Total_Deaths,
round(sum(new_deaths)/sum(new_cases)*100,2) as Death_Percentage


from chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
where continent is not null

order by 1, 2

2. Total Death Per Continent
Select location, 
SUM(new_deaths) as TotalDeathCount
From chrome-folio-405910.Portfolio_Giammi.Covid_Deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

3. Percent Population Infected Per Country
Select 
Location, 
safe_cast(Population as INT64) as population, 
MAX(total_cases) as HighestInfectionCount,

Max((total_cases/safe_cast(population as int64)))*100 as PercentPopulationInfected

From chrome-folio-405910.Portfolio_Giammi.Covid_Deaths

--Where location like '%states%'
Group by Location, Population

order by PercentPopulationInfected desc

4. Percent Population Infected
Select 
Location, 
safe_cast(Population as INT64),
date, 
MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/safe_cast(population as INT64)))*100 as PercentPopulationInfected

From chrome-folio-405910.Portfolio_Giammi.Covid_Deaths

--Where location like '%states%'

Group by Location, Population, date

order by PercentPopulationInfected desc
