use nashville;
SET SQL_SAFE_UPDATES = 0;


CREATE database Nashville;

Create table nash (
UniqueID int, 
ParcelID varchar(255),
LandUse varchar(255),
PropertyAddress	varchar(255),
SaleDate varchar(255),
SalePrice int,
LegalReference varchar(255),
SoldAsVacant varchar(255),	
OwnerName varchar(255),
OwnerAddress varchar(255),
Acreage	decimal(15,5),
TaxDistrict varchar(255),	
LandValue int,
BuildingValue int,	
TotalValue int,
YearBuilt int,
Bedrooms int,
FullBath int,
HalfBath int

);



SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE "C:/Users/Nashville Housing Data for Data Cleaning.csv"
INTO TABLE nash
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- LINES TERMINATED BY 'n'
IGNORE 1 ROWS;



-- Standardize Data Format

update nash set saledate=

      
         CASE SUBSTR(SaleDate, 1, instr(SaleDate, ' ')-1 )
         
             WHEN 'January' THEN REPLACE(SaleDate,'January',1)
             WHEN 'February' THEN REPLACE(SaleDate,'February',2)
             WHEN 'March' THEN REPLACE(SaleDate,'March',3)
             WHEN 'April' THEN REPLACE(SaleDate,'April',4)
             WHEN 'May' THEN REPLACE(SaleDate,'May',5)
             WHEN 'June' THEN REPLACE(SaleDate,'June',6)
             WHEN 'July' THEN REPLACE(SaleDate,'July',7)
             WHEN 'August' THEN REPLACE(SaleDate,'August',8)
             WHEN 'September' THEN REPLACE(SaleDate,'September',9)
             WHEN 'October' THEN REPLACE(SaleDate,'October',10)
             WHEN 'November' THEN REPLACE(SaleDate,'November',11)
             WHEN 'December' THEN REPLACE(SaleDate,'December',12)
         
          END ;
     
     
 -- Select SUBSTR(SaleDate, 1, instr(SaleDate, ' ')-1 ) from nash;

-- Select SUBSTR(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',')-instr(SaleDate, ' ') ) from nash;


SET SQL_SAFE_UPDATES = 0;

update nash set saledate=
replace(saledate,', ',' ');

SELECT saledate, STR_TO_DATE(saledate, '%m %d %Y') from nash;

update nash set saledate=STR_TO_DATE(saledate, '%m %d %Y');

alter table nash modify saledate date;

select saledate from nash;

-- Populate Property Address date

update nash 
set propertyaddress = nullif(propertyaddress,'');


select a.Parcelid,a.PropertyAddress,b.Parcelid,b.Propertyaddress, a.PropertyAddress is null,b.PropertyAddress is null
from nash a
join nash b 
on a.ParcelId=b.ParcelId
AND a.UniqueId!=b.UniqueId
Where a.Propertyaddress is null;

Update nash a
JOIN nash b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
SET a.PropertyAddress= b.propertyaddress
Where a.PropertyAddress is null;


-- Breaking out Address Into Individual Columns (Address, City, State)

select PropertyAddress
from nash;



SELECT substr(PropertyAddress, 1,instr(PropertyAddress,',')-1) as Address
,substr(PropertyAddress, instr(PropertyAddress,',')+1, LENGTH(PropertyAddress)) as City
from nash;

ALTER TABLE nash 
add PropertySplitAddress NVARCHAR(255);

UPDATE nash 
set PropertySplitAddress=substr(PropertyAddress, 1,instr(PropertyAddress,',')-1) ;

ALTER TABLE nash 
add PropertySplitCity NVARCHAR(255);

UPDATE nash 
set PropertySplitCity=substr(PropertyAddress, instr(PropertyAddress,',')+1, LENGTH(PropertyAddress));


select propertysplitaddress,PropertySplitcity  from nash;


-- Split OwnerAddress to address, City, State

select owneraddress from nash;

/*
SET SQL_SAFE_UPDATES = 0;

update nash 
set owneraddress = nullif(owneraddress,'');
*/

SELECT owneraddress,
   SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 1), ',', -1) AS address,
   If(  length(owneraddress) - length(replace(owneraddress, ',', ''))>1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) ,NULL) 
           as City,
   SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1) AS State
FROM nash;

 
ALTER TABLE nash 
add OwnerSplitAddress NVARCHAR(255);

UPDATE nash 
set OwnerSplitAddress=SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 1), ',', -1) ;

ALTER TABLE nash 
add OwnerSplitCity NVARCHAR(255);

UPDATE nash 
set OwnerSplitCity=
If(  length(owneraddress) - length(replace(owneraddress, ',', ''))>1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) ,NULL) 
;


ALTER TABLE nash 
add OwnerSplitState NVARCHAR(255);

UPDATE nash 
set OwnerSplitState=
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1) 
;



select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState from nash;

select * from nash;


-- Change Y and N to YES and NO in ''Sold as Vacant'' field


Select distinct Soldasvacant, count(soldasvacant) from nash
group by soldasvacant
order by 2
 ;


select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
     else soldasvacant
end
     from nash;

update nash 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
     else soldasvacant
end
;


-- Remove Duplicates 

 -- 1)
 DELETE FROM nash
WHERE 
	uniqueid IN (
	SELECT 
		uniqueid
	FROM (
		SELECT 
			uniqueid,
			ROW_NUMBER() OVER (
				PARTITION BY PARCELid, 
   propertyaddress, 
   saleprice, 
   saledate, 
   legalreference
				ORDER BY PARCELid, 
   propertyaddress, 
   saleprice, 
   saledate, 
   legalreference) AS row_num
		FROM 
			nash
		
	) t
    WHERE row_num > 1
);
 
 
 -- 2)

DELETE t1 FROM nash t1
INNER JOIN nash t2 
WHERE 
    t1.uniqueid < t2.uniqueid AND 
    t1.PARCELid = t2.PARCELid AND
t1.propertyaddress = t2.propertyaddress AND
t1.saleprice = t2.saleprice AND
t1.saledate = t2.saledate AND
t1.legalreference = t2.legalreference;

SELECT 
   PARCELid, 
   propertyaddress, 
   saleprice, 
   saledate, 
   legalreference,
    COUNT(PARCELid),
   COUNT(propertyaddress), 
   COUNT(saleprice), 
   COUNT(saledate), 
   COUNT(legalreference)
FROM
    nash
GROUP BY 
   PARCELid, 
   propertyaddress, 
   saleprice, 
   saledate, 
   legalreference
HAVING 
   COUNT(PARCELid) > 1 and
   COUNT(propertyaddress) > 1 and
   COUNT(saleprice) > 1 and
   COUNT(saledate) > 1 and
   COUNT(legalreference) > 1;

select * from nash;


-- Delete Unused Columns

select * from nash;


alter table nash 
drop column owneraddress;


drop column propertyaddress,
drop column taxdistrict;















