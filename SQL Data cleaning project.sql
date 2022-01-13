DROP TABLE IF EXISTS nashvilleHousing;
CREATE TABLE nashvilleHousing 
	(
	UniqueID VARCHAR(20), 
	ParcelID VARCHAR(20),
	LandUse	VARCHAR(255),
	PropertyAddress	VARCHAR(255),
	SaleDate DATE,
	SalePrice MONEY,
	LegalReference VARCHAR(20),
	SoldAsVacant VARCHAR(3),	
	OwnerName	VARCHAR(255),
	OwnerAddress VARCHAR(255),	
	Acreage	NUMERIC,
	TaxDistrict	VARCHAR(50),
	LandValue NUMERIC,	
	BuildingValue NUMERIC,	
	TotalValue NUMERIC,
	YearBuilt INT,	
	Bedrooms INT,	
	FullBath INT,	
	HalfBath INT
	);
COPY nashvilleHousing(UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath)	
FROM 'D:\TOPIC_RELATED VOCABULARY IELTS\Finland\aalto\ISM major\CAREER side projects+portfolio for DA+ dashboard\SQL data cleaning project 3\Nashville Housing Data for Data Cleaning.csv'
DELIMITER ','
CSV HEADER;

SHOW datestyle;
SET datestyle TO "DMY";

--------
---How to populate the property address (how to handle missing values)? 
UPDATE nashvilleHousing
SET propertyAddress= COALESCE(na.propertyAddress, na2.propertyAddress)
FROM
	nashvilleHousing na INNER JOIN nashvilleHousing  na2
	ON na.parcelId = na2.parcelId AND na.uniqueId <> na2.uniqueId
WHERE nashvilleHousing.propertyAddress IS NULL


---How to break out address into individual columns( Address, city if there is only one comma separating these two parts)?
ALTER TABLE nashvilleHousing 
ADD COLUMN
	Address VARCHAR (255);
UPDATE nashvilleHousing
SET Address= LEFT (propertyAddress, POSITION(',' IN propertyAddress)-1);

ALTER TABLE nashvilleHousing 
ADD COLUMN City VARCHAR (50);
UPDATE nashvilleHOusing 
SET City =SUBSTRING(propertyAddress,POSITION(',' IN propertyAddress)+2,LENGTH(propertyAddress));


--- How to break out a long string into components(if there exists more than 1 comma)?
ALTER TABLE nashvilleHousing
DROP COLUMN IF EXISTS OwnerAddressSplit;
ALTER TABLE nashvilleHousing
ADD COLUMN OwnerAddressSplit VARCHAR(255); 
UPDATE nashvilleHousing
SET OwnerAddressSplit= SPLIT_PART(ownerAddress, ', ', 1);

ALTER TABLE nashvilleHousing
DROP COLUMN IF EXISTS OwnerCitySplit;
ALTER TABLE nashvilleHousing
ADD COLUMN OwnerCitySplit VARCHAR(50);
UPDATE nashvilleHousing
SET OwnerCitySplit= SPLIT_PART(ownerAddress, ', ', 2);

ALTER TABLE nashvilleHousing
DROP COLUMN IF EXISTS OwnerStateSplit;
ALTER TABLE nashvilleHousing
ADD COLUMN OwnerStateSplit VARCHAR(50);
UPDATE nashvilleHousing
SET OwnerStateSplit= SPLIT_PART(ownerAddress, ', ', 3);

-- How to change Y and N to Yes and No in soldAsVacant field?
UPDATE nashvilleHousing
SET soldAsVacant= CASE WHEN soldAsVacant='Y' THEN 'Yes'
					   WHEN soldAsVacant='N' THEN 'No'
					   ELSE soldAsVacant
					   END
	
	
--- How to create a temp table without the duplicates or how to remove duplicates?
WITH rowNumCTE  AS 
(
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY na.parcelID,
					  				na.propertyAddress,
					  				na.salePrice,
					  				na.saleDate,
					  				na.legalReference
					    ORDER BY na.uniqueID DESC) as unique_count
FROM 
	nashvilleHousing na
)
DELETE 
FROM rowNumCTE
WHERE unique_count>1;

--- How to delete unused ownerAddress?
ALTER TABLE nashvilleHousing
DROP COLUMN ownerAddress, propertyAddress




















