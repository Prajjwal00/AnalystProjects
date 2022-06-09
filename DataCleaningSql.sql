select * 
  FROM [SqlPortfolioProj].[dbo].[NashvilleHousing]
--------------------------------------------------------------------------------------------------------------------------
--Standardize Date format

select SaleDateConverted,Convert(Date,SaleDate)
from [SqlPortfolioProj].[dbo].[NashvilleHousing]

Update NashvilleHousing
SET SaleDate=Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date
Update NashvilleHousing
SET SaleDateConverted=Convert(Date,SaleDate)
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Populate property address data

select * 
  FROM [SqlPortfolioProj].[dbo].[NashvilleHousing]
  order by ParcelID
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [SqlPortfolioProj].[dbo].[NashvilleHousing] a
Join [SqlPortfolioProj].[dbo].[NashvilleHousing] b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [SqlPortfolioProj].[dbo].[NashvilleHousing] a
Join [SqlPortfolioProj].[dbo].[NashvilleHousing] b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address,City,state)

select substring(PropertyAddress,1,charindex(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as Address
from [SqlPortfolioProj].[dbo].[NashvilleHousing] 

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress) -1)
ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))

select * 
  FROM [SqlPortfolioProj].[dbo].[NashvilleHousing]
-------------------------------------------------------------------------------------------------------------------------
--For owners address
select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
FROM [SqlPortfolioProj].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)
ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)
------------------------------------------------------------------------------------------------------------------------------
--change Y and N to Yes and No in "Sold as Vacant" field
select Distinct(SoldAsVacant),Count(SoldAsVacant)
from [SqlPortfolioProj].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case
	when SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant= 'N' Then 'NO'
	else SoldAsVacant
END
from  [SqlPortfolioProj].[dbo].[NashvilleHousing]

update NashvilleHousing
set SoldAsVacant=Case
	when SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant= 'N' Then 'NO'
	else SoldAsVacant
	END
------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
with RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				)row_num
from [SqlPortfolioProj].[dbo].[NashvilleHousing]
)
select*
from RowNumCTE
where row_num>1
------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
select *
from [SqlPortfolioProj].[dbo].[NashvilleHousing]
Alter Table [SqlPortfolioProj].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate