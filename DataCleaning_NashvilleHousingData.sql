Select *
From NashvilleHousing

#### Standardize Date Format
ALTER TABLE NashvilleHousing
CHANGE SaleDate_new SaleDateConverted DATE

ALTER TABLE NashvilleHousing
CHANGE SaleDateConverted SaleDate DATE

# use convert fn
Select convert(SaleDate, Date)
From NashvilleHousing

#### Populate null Property Address Data (Parcel ID to Property Addresss)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL

####Breaking out Address into Individual columns (Address, City, State)
Select PropertyAddress
From NashvilleHousing

# Address
SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) AS ADDRESS
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress))

Select *
From NashvilleHousing

#### OWNER ADDRESS -> Address, City, State
SELECT SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)
FROM NashvilleHousing;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1) AS Address1
, SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS Address2
, SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1) AS Address3
FROM NashvilleHousing;

# Owner Address : Address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1)

# Owner Address : City
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1)

# Owner Address : State
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1)

##### Change Y to Yes, and N to No in "Sold as Vacant" field
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant
       END
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       ELSE SoldAsVacant
       END

#### Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
)


#### Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate


