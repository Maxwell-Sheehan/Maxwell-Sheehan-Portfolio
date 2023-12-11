
--formats our date into Year/Month/day

select SaleDateConverted, CONVERT(date,SaleDate)
from Projects.dbo.Housing

update Housing
set SaleDate = convert(date,SaleDate) 

Alter Table Housing
add SaleDateConverted Date;

update Housing
set SaleDateConverted = convert(date,saledate) 

--Finds and clears null values in property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Projects.dbo.Housing a 
join Projects.dbo.Housing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Projects.dbo.Housing a 
join Projects.dbo.Housing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]

--This could be removed now that It's been updated but I wanna leave it in to demonstrate how it occured

Select *
from Projects.dbo.Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1)  as Address ,
SUBSTRING(PropertyAddress,  CHARINDEX( ',', PropertyAddress) +1, Len(propertyaddress))  as Address 
from Projects.dbo.Housing


Alter Table Housing
add PropertySplitAddress NvarChar(255);

update Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1)  
--This does two things first we notice that the property address is seperated by the city by ',' and that's teh only place this character comes up so we filter our property address by
--this character and go -1 since it's our last value, then from there we can use the same logic to seperate our city by +1 which is our next lines
Alter Table Housing
add PropertySplitCity NvarChar(255);

update Housing
set PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX( ',', PropertyAddress) +1, Len(propertyaddress)) 

select OwnerAddress
from Projects.dbo.Housing

--This is how we are able to find our owner value and seperate them into smaller chunks, replace requires a period so we change from comma to period and then are able to parse.
select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.' ), 1)
from Projects.dbo.Housing

--before we tested our function to see if it worked this is us actually adding the columns

Alter Table Housing
add OwnerSplitAddress NvarChar(255);

update Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Alter Table Housing
add OwnerSplitCity NvarChar(255);

update Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

Alter Table Housing
add OwnerSplitState NvarChar(255);

update Housing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Projects.dbo.Housing

--This is just unifying the data before there was Yes, Y for yes and No, N for no this finds the count of both and then just converts it all to one form to make it simpler

Update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


with RowNumCte as(
select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
					uniqueid
					) row_num
			
			
from Projects.dbo.Housing
--order by ParcelID
)
Delete
from RowNumCte
where row_num >1

-- this function set up was the process of finding dulpliated data and then removing it so what became delete was orgionally just sorting by anything that meet the conditions

select *
from Projects.dbo.Housing

alter table Projects.dbo.Housing
--drop column saledate // this was the process of droping from our data set the redunt values we had after removing them or simplifying them since now we have duplicate columns showing the same info
