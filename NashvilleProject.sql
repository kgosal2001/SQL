-- Cleaning Data

Select *
From NashvilleHousing


-----------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDate, CONVERT(date, SaleDate)
From NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


-----------------------------------------------------------------------------------------

-- Populate property address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelId

-- Find null values in Property Address by joining the table onto itself(a) and comparing it (b)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelId = b.parcelId
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- Update the null addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelId = b.parcelId
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-----------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelId

-- Separate address into different columns using substring function (coulumn, starting index, ending index)
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHousing

-- Add new columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

-- Update new columns
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Do the same for owner address, this time using parsename(coulumn, delimiter index from back) 
-- replace the commas with periods because the delimiter for the function is .
Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

-- Add new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

-- Update new columns
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

-- Case statement
SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       Else SoldAsVacant
       END
FROM NashvilleHousing

-- Update Column using case statement
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       Else SoldAsVacant
       END


-----------------------------------------------------------------------------------------

-- Remove duplicates

--create cte to find duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
        Partition by ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY UniqueID
    ) row_num
From NashvilleHousing
)

-- View CTE and the duplicate rows then change select * to delete to delete them
Select *
From RowNumCTE
Where row_num > 1


-----------------------------------------------------------------------------------------

-- Delete unused columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress