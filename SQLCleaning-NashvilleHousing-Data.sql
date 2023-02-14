/*

data cleaning in sql queries

*/

select * from Project1..nashvilleHousing


-- change SaleDate format
Update nashvilleHousing 
set SaleDate = CONVERT(date,SaleDate)

select SaleDate from Project1..nashvilleHousing	


Alter table nashvilleHousing
add SaleDateConv Date;

Update nashvilleHousing 
set SaleDateConv = CONVERT(date,SaleDate)

select SaleDateConv from Project1..nashvilleHousing	


-- populate the address data
select *
from Project1..nashvilleHousing
where PropertyAddress is null

select *
from Project1..nashvilleHousing
order by ParcelID


select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
from Project1..nashvilleHousing a
join Project1..nashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
 

update a 
set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Project1..nashvilleHousing a
join Project1..nashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
	

-- breaking out the address into separate columns (address, city, state)

select PropertyAddress
from Project1..nashvilleHousing


select
PropertyAddress,
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress)) as city


from Project1..nashvilleHousing


Alter table project1..nashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update project1..nashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)

Alter table project1..nashvilleHousing
add PropertySplitCity Nvarchar(255);

Update project1..nashvilleHousing 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress))

select * from Project1..nashvilleHousing



select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Project1..nashvilleHousing


Alter table project1..nashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update project1..nashvilleHousing 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table project1..nashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update project1..nashvilleHousing 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table project1..nashvilleHousing
add OwnerSplitState Nvarchar(255);

Update project1..nashvilleHousing 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from Project1..nashvilleHousing



-- change Y and N in SoldAsVacant field.
select Distinct(SoldAsVacant), count(SoldAsVacant)
from Project1..nashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Project1..nashvilleHousing

update Project1..nashvilleHousing
set SoldAsVacant = case
	 when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

select SoldAsVacant, count(SoldAsVacant)
from Project1..nashvilleHousing
group by SoldAsVacant
order by 2


-- Remove duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by parcelID,
				PropertyAddress,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from Project1..nashvilleHousing
--order by ParcelID
)
Delete from RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Delete unused columns


Alter table Project1..nashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table Project1..nashvilleHousing
Drop Column SaleDate
select * from Project1..nashvilleHousing