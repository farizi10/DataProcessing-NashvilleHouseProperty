/* CLEANING DATA IN SQL*/

select * from PortfolioProject.dbo.NashvilleHouse


--Standarisasi Format Data

select SaleDate, CONVERT(Date,SaleDate) from PortfolioProject.dbo.NashvilleHouse

update PortfolioProject.dbo.NashvilleHouse
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashvillehouse
add SaleDateConverted Date;

update NashvilleHouse
SET SaleDateConverted = CONVERT(Date, Saledate)

--setelah di upadet dan ditambahkan kolom baru "SaleDateConverted"
select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHouse


----------------------------------------------------------------

--Cleaning pada data alamat properti

select PropertyAddress from PortfolioProject.dbo.NashvilleHouse

--kondisi : alamat properti NULL
select * from PortfolioProject.dbo.NashvilleHouse
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHouse a
JOIN PortfolioProject.dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHouse a
JOIN PortfolioProject.dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Memecah Alamat menjadi Kolom Individu (Alamat, Kota, Negara Bagian)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHouse
--kondisi : alamat properti tidak NULL
--kondisi : ururtkan berdasarkan PercellID


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
 ,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHouse


ALTER TABLE NashvilleHouse
add PropertySplitAddress Nvarchar(255);
update NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHouse
add PropertySplitCity Nvarchar(255);
update NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


select * from PortfolioProject.dbo.NashvilleHouse

-------------------------------------------------------------------------------------------------------------

select OwnerAddress from PortfolioProject.dbo.NashvilleHouse

--Membagi Alamat Owner menjadi  bagian yaitu Address, City, State
select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHouse


--Membuat kolom baru = OwnerSplitAddress
ALTER TABLE NashvilleHouse
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


--Membuat kolom baru = OwnerSplitCity
ALTER TABLE NashvilleHouse
Add OwnerSplitCity Nvarchar(255);

update NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


--Membuat kolom baru = OwnerSplitState
ALTER TABLE NashvilleHouse
Add OwnerSplitState Nvarchar(255);

update NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * from PortfolioProject.dbo.NashvilleHouse


-----------------------------------------------------------------

--Merubah Y dan N menjadi Yes dan No pada "Sold as Vacant"

--Cek data
select SoldAsVacant from PortfolioProject.dbo.NashvilleHouse

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHouse
group by SoldAsVacant
order by 2



select SoldAsVacant
, CASE when SoldAsvacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsvacant
	   END
from PortfolioProject.dbo.NashvilleHouse



update NashvilleHouse
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
						END
from PortfolioProject.dbo.NashvilleHouse


-----------------------------------------------------------------

--Mengahapus duplikasi data

--Cek duplikasi Data
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHouse
--order by ParcellID
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress



--Menghapus Data Duplikat
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHouse
)
DELETE 
from RowNumCTE
where row_num > 1

-----------------------------------------------------------------

--Menghapus kolom yang tidak diperlukan

select * from PortfolioProject.dbo.NashvilleHouse

ALTER TABLE PortfolioProject.dbo.NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHouse
DROP COLUMN SaleDate



-----------------------------------------------------------------

--Mengisi nilai NULL

--cek data yang mengandul NULL
select LegalReference
from PortfolioProject.dbo.NashvilleHouse
where LegalReference is null --terdapat 6 nilai NULL

--isi nilai NULL
select distinct LegalReference from PortfolioProject.dbo.NashvilleHouse