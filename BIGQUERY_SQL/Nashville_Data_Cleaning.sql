--Data Manipulation Query 1:
--Modifying date format from May 15, 2014 to dd/mm/yy


SELECT SaleDate,
FORMAT_DATE("%d/%m/%y",PARSE_DATE("%B %d, %Y",SaleDate)) as Formatted_Date


FROM `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--update the table with the new formatting


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET saledate = FORMAT_DATE("%d/%m/%y", PARSE_DATE("%B %d, %Y", SaleDate))
where SaleDate is not null


--Data Manipulation Query 2:
--populate null property addresses that share the same ParcelId. The idea is that if a property address is empty but shares the same parcelId as another address to fill it in. we join the same table and identify the ParcelId that shares the same address and fill it in.


SELECT
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database` a
join `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database` b
  on a.ParcelID = b.ParcelID and a.UniqueID_ <> b.UniqueID_
  where a.PropertyAddress is null


--update the table with the new data


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database` AS a
SET PropertyAddress = (
    SELECT MAX(b.PropertyAddress)
    FROM `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database` AS b
    WHERE a.ParcelID = b.ParcelID
      AND a.UniqueID_ <> b.UniqueID_
      AND b.PropertyAddress IS NOT NULL
)
WHERE PropertyAddress IS NULL;


--Data Manipulation Query 3:
-- in the original dataset PropertyAddress contained both the address and the city (0  BRICK CHURCH PIKE, GOODLETTSVILLE). Here we split the two and create separate columns for both for better clarity.


SELECT
PropertyAddress
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


select
regexp_extract(PropertyAddress, r'[^,]*') as address,
regexp_extract(PropertyAddress, r',\s*(.*)') as address
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--create new columns by altering the table and updating those columns with the new data


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column NewSplitAddress string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET NewSplitAddress = regexp_extract(PropertyAddress, r'[^,]*')
where NewSplitAddress is null


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column NewSplitCity string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET NewSplitCity = regexp_extract(PropertyAddress, r',\s*(.*)')
where NewSplitCity is null


--checking to see if the new columns were added


select *
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--Same with OwnerAddress


select
regexp_extract(OwnerAddress, r'[^,]*') as address,
regexp_extract(OwnerAddress, r',\s*([^,]+),\s*[^,]+$') as addressCity,
regexp_extract(OwnerAddress, r',\s*([^,]+)$') as addressState
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--can use also Split and Trim but I prefer Regexp_extract for simplicity


SELECT
  SPLIT(OwnerAddress, ',')[OFFSET(0)] AS address,
  TRIM(SPLIT(OwnerAddress, ',')[OFFSET(1)]) AS addressCity,
  TRIM(SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)]) AS addressState
FROM
  `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--create new columns by altering the table and updating those columns with the new data


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column NewOwnerSplitAddress string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET NewOwnerSplitAddress = regexp_extract(OwnerAddress, r'[^,]*')
where NewOwnerSplitAddress is null


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column NewOwnerSplitCity string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET NewOwnerSplitCity = regexp_extract(OwnerAddress, r',\s*([^,]+),\s*[^,]+$')
where NewOwnerSplitCity is null


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column NewOwnerSplitState string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET NewOwnerSplitState = regexp_extract(OwnerAddress, r',\s*([^,]+)$')
where NewOwnerSplitState is null


--checking to see if the new columns were added


select *
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`



--Data Manipulation Query 4:
--remove duplicates within dataset
--window function to find the number of times a value is repeated


WITH Table1 as
(
select *,
row_number() over(
  partition by ParcelID,
  PropertyAddress,
  SalePrice,
  SaleDate,
  LegalReference
  order by UniqueID_
) row_num
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
)


--using a CTE allows us to highlight the duplicate rows in the database (104 rows of duplicates)
Select *
from Table1
where row_num >1
order by propertyaddress


--delete them: BigQuery doesn't support directly deleting from CTEs like some other databases do. Therefore, a subquery is used instead of a CTE


DELETE FROM `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
WHERE UniqueID_ IN (
  SELECT UniqueID_
  FROM (
    SELECT UniqueID_,
           ROW_NUMBER() OVER (
             PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
             ORDER BY UniqueID_
           ) AS row_num
    FROM `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
  ) subquery
  WHERE row_num > 1
);


--Data Manipulation Query 5:
--Replace truer or false with yes or no
SELECT


distinct(SoldAsVacant),
count(SoldAsVacant)


from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
group by SoldAsVacant
order by 2


--a Boolean expression is evaluated as either TRUE or FALSE. When a Boolean expression is used in a CASE statement, it's implicitly understood that if the expression evaluates to TRUE, the corresponding THEN clause will be executed.


SELECT
  SoldAsVacant,
  CASE
    WHEN SoldAsVacant THEN 'yes'
    ELSE 'no'
  END AS SoldAsVacant
FROM
  `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`




-- Because the data type is Boolean and we are trying to assign them a string value (yes/no) the error message pops up.
UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET SoldAsVacant = CASE
    WHEN SoldAsVacant THEN 'yes'
    ELSE 'no'
  END
where SoldAsVacant is not null


--Therefore we could create a new column that displays yes or no rather than true or false


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
add column SoldAsVacant2 string


UPDATE `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
SET SoldAsVacant2 = CASE
    WHEN SoldAsVacant THEN 'yes'
    ELSE 'no'
  END
where SoldAsVacant2 is null


--checking if column has been added
select *
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`




--Data Manipulation Query 6:
--delete unused columns
select
*
from `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`


--previously we divided the owner and property addresses for better clarity so now we can drop those columns


alter table `chrome-folio-405910.Portfolio_Giammi.Data_Cleaning_Database`
drop column OwnerAddress,
drop column PropertyAddress

