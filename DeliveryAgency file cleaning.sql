Select * 
from lotadata..DeliveryAgency


--------------------------------------------
-- CHANGING DATE FORMAT
Select SaleDate, CONVERT(Date,SaleDate)
From lotadata.dbo.DeliveryAgency

ALTER TABLE DeliveryAgency
add SaleDateUpdated date;

Update lotadata..DeliveryAgency
set SaleDateUpdated = Convert(Date,SaleDate)


--  UPDATE ALL NULL VALUES IN PROPERTY ADDRESS COLUMN
Select *
from lotadata..DeliveryAgency
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress  --ISNULL(a.PropertyAddress, b.PropertyAddress)
from lotadata..DeliveryAgency a
join lotadata..DeliveryAgency b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from lotadata.dbo.DeliveryAgency a
join lotadata.dbo.DeliveryAgency b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- This is to split PropertyAddress into 2 different columns of address and city
Select *
from lotadata..DeliveryAgency

Select
Substring(a.PropertyAddress, 1, CHARINDEX(',', a.PropertyAddress)-1),
Substring(a.PropertyAddress,CHARINDEX(',', a.PropertyAddress) + 1, len(a.PropertyAddress))
from lotadata..DeliveryAgency a

Alter table lotadata..DeliveryAgency
add Propertynewaddress Nvarchar(255)

update lotadata..DeliveryAgency
set Propertynewaddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table lotadata..DeliveryAgency
add Propertynewcity NVARCHAR(255)

update lotadata..DeliveryAgency
set Propertynewcity = Substring(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))



-- This is to split OwnerAddress into 3 different columns of address, city and state 
Select * 
from lotadata..DeliveryAgency

Select OwnerAddress
from lotadata..DeliveryAgency

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3), 
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)  
from lotadata..DeliveryAgency


Alter table lotadata..DeliveryAgency
add Ownernewaddress Nvarchar(255)

update lotadata..DeliveryAgency
set Ownernewaddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table lotadata..DeliveryAgency
add Ownernewcity NVARCHAR(255)

update lotadata..DeliveryAgency
set Ownernewcity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table lotadata..DeliveryAgency
add Ownernewstate NVARCHAR(255)

update lotadata..DeliveryAgency
set Ownernewstate = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



-- SET N, Y to YES AND NO for the SoldasVacant Column
Select SoldAsVacant, count(SoldAsVacant)
from lotadata..DeliveryAgency
group by SoldAsVacant


Select 
 CASE WHEN SoldAsVacant = 'Y' then 'YES'
       WHEN SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   end
from lotadata..DeliveryAgency


update lotadata..DeliveryAgency
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'YES'
       WHEN SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   end



-- Identifying duplicates
With ROWCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from lotadata..DeliveryAgency
)

Select *
from ROWCTE
where row_num > 1


-- Deleting Irrelevant columns

Select *
From lotadata..DeliveryAgency


ALTER TABLE lotadata..DeliveryAgency
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate