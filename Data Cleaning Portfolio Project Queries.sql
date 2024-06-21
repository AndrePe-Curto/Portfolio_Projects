/*

Cleaning Data in SQL Queries

*/

Select *
From NashvileAnalysis..Nashvillehousing

-------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Fromat

Select SaleDate, CONVERT(Date, SaleDate)
From NashvileAnalysis..Nashvillehousing


ALTER TABLE NashvileAnalysis..Nashvillehousing
ALTER COLUMN SaleDate DATE 



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvileAnalysis..Nashvillehousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileAnalysis..Nashvillehousing a
Join NashvileAnalysis..Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileAnalysis..Nashvillehousing a
Join NashvileAnalysis..Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Columns (Adress, City, State)

Select PropertyAddress
From NashvileAnalysis..Nashvillehousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Adress
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvileAnalysis..Nashvillehousing



ALTER TABLE Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvileAnalysis..Nashvillehousing



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvileAnalysis..Nashvillehousing

ALTER TABLE Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From NashvileAnalysis..Nashvillehousing



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Columns (Adress, City, State)

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvileAnalysis..Nashvillehousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From NashvileAnalysis..Nashvillehousing

UPDATE NashvileAnalysis..Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END



--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvileAnalysis..Nashvillehousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvileAnalysis..Nashvillehousing

ALTER TABLE NashvileAnalysis..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress