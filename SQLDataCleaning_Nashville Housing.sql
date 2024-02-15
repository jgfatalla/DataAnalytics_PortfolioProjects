--Cleaning data in SQL queries

select *
from NashvilleHousing



--standardize date format

select SaleDateConverted, convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table [dbo].[NashvilleHousing]
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



--populate property address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select nash1.ParcelID, nash1.PropertyAddress, nash2.ParcelID, nash2.PropertyAddress, isnull(nash1.PropertyAddress, nash2.PropertyAddress)
from NashvilleHousing nash1
join NashvilleHousing nash2
	on nash1.ParcelID = nash2.ParcelID
	and nash1.[UniqueID ] <> nash2.[UniqueID ]
where nash1.PropertyAddress is null


update nash1
set PropertyAddress = isnull(nash1.PropertyAddress, nash2.PropertyAddress)
from NashvilleHousing nash1
join NashvilleHousing nash2
	on nash1.ParcelID = nash2.ParcelID
	and nash1.[UniqueID ] <> nash2.[UniqueID ]
where nash1.PropertyAddress is null



--breaking out address into individual columns (address, city, state)

select PropertyAddress
from NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

alter table [dbo].[NashvilleHousing]
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table [dbo].[NashvilleHousing]
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing

--simpler way

select OwnerAddress
from NashvilleHousing

select
parsename(REPLACE(OwnerAddress, ',', '.'),3)
,parsename(REPLACE(OwnerAddress, ',', '.'),2)
,parsename(REPLACE(OwnerAddress, ',', '.'),1)
from NashvilleHousing

alter table [dbo].[NashvilleHousing]
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',', '.'),3)

alter table [dbo].[NashvilleHousing]
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.'),2)

alter table [dbo].[NashvilleHousing]
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(REPLACE(OwnerAddress, ',', '.'),1)



--change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-- Remove Duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER()  over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress



-- Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate
