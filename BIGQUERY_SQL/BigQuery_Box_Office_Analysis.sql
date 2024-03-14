--Project is divided into 3 parts: 1. Data Cleaning 2. Data Analysis 3. Data Visualisation on Tableau
--Tableau link: https://public.tableau.com/app/profile/gian.marco.caramelli/viz/WIP_InteractiveMovieDashboard/Dashboard2?publish=yes

--DATA CLEANING
--Improve the clarity of the CSV format by extracting the genres names.
--the genres column in the excel file is extremely confusing and very messy, by using JSON_EXTRACT_SCALAR we extract the value of the name key from the first element ($[0]) of the JSON array stored in the genres column.
select
 JSON_EXTRACT_SCALAR(genres, "$[0].name") AS genre1,
  JSON_EXTRACT_SCALAR(genres, "$[1].name") AS genre2,
  JSON_EXTRACT_SCALAR(genres, "$[2].name") AS genre3,
  JSON_EXTRACT_SCALAR(genres, "$[3].name") AS genre4,
  JSON_EXTRACT_SCALAR(genres, "$[4].name") AS genre5,
  from `chrome-folio-405910.Movies.test_v2`


-- Update the CSV table so that the genres are now separated and clear


alter table `chrome-folio-405910.Movies.test_v2`
add column Genre1 string


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Genre1 = JSON_EXTRACT_SCALAR(genres, "$[0].name")
where Genre1 is null


alter table `chrome-folio-405910.Movies.test_v2`
add column Genre2 string


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Genre2 =  JSON_EXTRACT_SCALAR(genres, "$[1].name")
where Genre2 is null


alter table `chrome-folio-405910.Movies.test_v2`
add column Genre3 string


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Genre3 =  JSON_EXTRACT_SCALAR(genres, "$[2].name")
where Genre3 is null


alter table `chrome-folio-405910.Movies.test_v2`
add column Genre4 string


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Genre4 =  JSON_EXTRACT_SCALAR(genres, "$[3].name")
where Genre4 is null


alter table `chrome-folio-405910.Movies.test_v2`
add column Genre5 string


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Genre5 =  JSON_EXTRACT_SCALAR(genres, "$[4].name")
where Genre5 is null


-- check if the new columns were added
select
*
from `chrome-folio-405910.Movies.test_v2`


-- extract the year for clarity and data analysis


SELECT
EXTRACT(YEAR FROM DATE(release_date)) AS year
FROM `chrome-folio-405910.Movies.test_v2`
--group by year
--order by year desc


-- add new column into the dataset
alter table `chrome-folio-405910.Movies.test_v2`
add column Release_Year1 INT64


UPDATE `chrome-folio-405910.Movies.test_v2`
SET  Release_Year1 =  EXTRACT(YEAR FROM DATE(release_date))
where Release_Year1 is null


-- drop the genres column and any other uneccessary column
alter table `chrome-folio-405910.Movies.test_v2`
drop column genres,
drop column tagline,
drop column popularity,
drop column Release_Year


--DATA ANALYSIS
--overview of the table and highligting their genres and profitability
SELECT
original_title,
budget,
revenue as box_office,
revenue-budget as profit_or_loss,
ROUND(SAFE_DIVIDE((revenue-budget),budget),2) as profit_loss_ratio,
genre1,
genre2,
genre3,
Genre4,
genre5,
FROM `chrome-folio-405910.Movies.test_v2`
order by revenue desc
limit 10




#BO by year
select
Release_year1,
sum(revenue) as total_BO
from `chrome-folio-405910.Movies.test_v2`
where release_year1 is not null
group by Release_Year1
order by Release_Year1 desc


#Box Office by year by genre (in this query we use the main genre, genre1, rather than all 5 genres to minimise confusion)
select
Release_year1,
Genre1,
sum(revenue) as total_BO,
round(avg(revenue),1) as avg_BO
from `chrome-folio-405910.Movies.test_v2`
where release_year1 is not null and genre1 is not null
group by Release_Year1,2
order by Release_Year1 desc


#budget by year by genre (in this query we use the main genre, genre1, rather than all 5 genres to minimise confusion)
select
Release_year1,
Genre1,
sum(budget) as Total_cost,
round(avg(budget),1) as avg_cost
from `chrome-folio-405910.Movies.test_v2`
where release_year1 is not null and genre1 is not null
group by Release_Year1,2
order by Release_Year1 desc


#Box Office profit by year by genre (in this query we use the main genre, genre1, rather than all 5 genres to minimise confusion)
select
Release_year1,
Genre1,
sum(revenue) - sum(budget) as profit_or_loss,
round(avg(revenue - budget),1) as avg_profit_loss
from `chrome-folio-405910.Movies.test_v2`
where release_year1 is not null and genre1 is not null
group by Release_Year1,2
order by Release_Year1 desc


