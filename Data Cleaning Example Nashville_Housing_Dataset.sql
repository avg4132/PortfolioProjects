--Cleaning Data in SQL Queries--

Select*
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format--

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Table--

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is NULL

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

--Where ParcelID's are the same, fill in null values with same info from non-null entries using Self Join--
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is NULL

--Breaking out Property Address into Individual Columns (Address, City)--

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID

Select Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
	, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

ALTER Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select*
From PortfolioProject.dbo.NashvilleHousing

----Breaking out Owner Address into Individual Columns (Address, City)--

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select Parsename(Replace(OwnerAddress, ',', '.'), 3)
, Parsename(Replace(OwnerAddress, ',', '.'),2)
, Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

--Add new queries to table--

Alter Table NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);

 Update NashvilleHousing
  Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
  Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
 Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
  Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field--

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant

Select SoldAsVacant
,	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END
--Verify update worked--	
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant

------------------------------------------------------------------------------------------------------

--Removing the Duplicates--

Select*,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From NashvilleHousing
Order By ParcelID


--Create CTE
WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1

--To verify duplicates gone, use Select* in CTE table where row_num > 1--
-----------------------------------------------------------------------------------------

--Remove Unneeded Columns--

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

------------------------------------------------------------------------------------------- 
