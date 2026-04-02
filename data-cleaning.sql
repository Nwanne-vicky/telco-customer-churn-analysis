Create Database TelcoAnalytics;

Select *
From dbo.TelcoCustomerChurn

Select Count(*)
From TelcoCustomerChurn

Select *
From Dbo.TelcoCustomerChurn
Where TotalCharges is Null

Select Count(*) As Row_Count
From Dbo.TelcoCustomerChurn
Where TotalCharges is Null

SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TelcoCustomerChurn'
  AND TABLE_SCHEMA = 'dbo';


  --Cleaning dataset

  Update dbo.TelcoCustomerChurn
  Set PaymentMethod = Replace(PaymentMethod, '(automatic)','')
  where PaymentMethod like '%(automatic)%'

  --Updating the right dataTypes

  Alter Table dbo.TelcoCustomerChurn
  Alter Column TotalCharges Decimal(10,2)

  Alter Table dbo.TelcoCustomerChurn
  Alter Column MonthlyCharges Decimal(10,2)

  
  Alter Table dbo.TelcoCustomerChurn
  Alter Column tenure int

  --Checking for dublicates and trimming dataset

SELECT customerID, COUNT(*) AS duplicate_count
FROM dbo.TelcoCustomerChurn
GROUP BY customerID
HAVING COUNT(*) > 1;

UPDATE dbo.TelcoCustomerChurn
SET 
    customerID = LTRIM(RTRIM(customerID)),
    PaymentMethod = LTRIM(RTRIM(PaymentMethod)),
    Contract = LTRIM(RTRIM(Contract));


  --Gender Category
  Select Distinct gender
  From dbo.TelcoCustomerChurn

  --Subscription model
  select Distinct Contract
  from dbo.TelcoCustomerChurn

  --Billing Behavior
  Select Distinct PaymentMethod
  From dbo.TelcoCustomerChurn

  --Customer lifecycle
  Select min(tenure), max(tenure)
  From dbo.TelcoCustomerChurn

 --Pricing Baseline
 Select Min(MonthlyCharges), Max(MonthlyCharges)
 From dbo.TelcoCustomerChurn

 Select Cast(AVG(MonthlyCharges) as Decimal(10,2)) As AvgMonthlyCharges
 From dbo.TelcoCustomerChurn

 --Churn Flag: creating numerical churn to enable aggregation

 Alter Table dbo.TelcoCustomerChurn
 Add ChurnFlag int

 update dbo.TelcoCustomerChurn
 set ChurnFlag = CASE When Churn = 'yes' then 1 
 Else 0 
 End
 
 Select Churn, ChurnFlag
 from dbo.TelcoCustomerChurn

 --Lifecycle Segmentation
 Alter Table dbo.TelcoCustomerChurn
 Add tenure_group nvarchar(50)

 Update dbo.TelcoCustomerChurn
 set tenure_group = CASE 
 when tenure <= 12 then '0 - 12 months'
 when tenure <= 24 then '12 - 24 months'
 when tenure <= 36 then '24 - 48months'
 else '48+ months'
 end

 select Top 30
 tenure, tenure_group
 from dbo.TelcoCustomerChurn

 --CUSTOMER SEGMENTATION

--customer by contract
select Contract, Count(*) As Customers
from dbo.TelcoCustomerChurn
group by Contract
order by Customers Desc

--Customer by paymentMethod
Select PaymentMethod, Count(*) As Customers
From dbo.TelcoCustomerChurn
group by PaymentMethod
order by Customers Desc

--Customer by Tenure_Group
Select tenure_group, count(*) As Customers
From dbo.TelcoCustomerChurn
group by tenure_group
order by Customers Desc

--Customer by gender
select gender, count(*) As Customers
from dbo.TelcoCustomerChurn
group by gender
order by Customers Desc

--Customer by SeniorCitizen
select SeniorCitizen, Count(*) As Customers
From dbo.TelcoCustomerChurn
group by SeniorCitizen
Order by Customers Desc

--Revenue analysis
--Total monthly revenue
Select Sum(MonthlyCharges) As TotalMonthlyRevenue
From dbo.TelcoCustomerChurn


--Revenue by gender
select gender, Sum(MonthlyCharges)
From dbo.TelcoCustomerChurn
group by gender
Order by Sum(MonthlyCharges) Desc

--Revenue by contract
select Contract, Sum(MonthlyCharges)
From dbo.TelcoCustomerChurn
group by Contract
Order by Sum(MonthlyCharges) Desc

--Revenue by paymentMethod
select PaymentMethod, Sum(MonthlyCharges)
From dbo.TelcoCustomerChurn
group by PaymentMethod
Order by Sum(MonthlyCharges) Desc

--Revenue by tenure group
select tenure_group, Sum(MonthlyCharges)
From dbo.TelcoCustomerChurn
group by tenure_group
Order by Sum(MonthlyCharges) Desc  

--Revenue by Senior Citizen and non-Senior citizen
select SeniorCitizen, Sum(MonthlyCharges)
From dbo.TelcoCustomerChurn
group by SeniorCitizen
Order by Sum(MonthlyCharges) Desc 

--Revenue by Churn
Select churn, Sum(MonthlyCharges)
from dbo.TelcoCustomerChurn
group by Churn
Order by Sum(MonthlyCharges) Desc

--ARPU ANALYSIS (Average monthlyCharges)
select Cast(AVG(MonthlyCharges) As decimal(10,2))
from dbo.TelcoCustomerChurn

--ARPU BY Contract

Select Contract, 
Count(*) as Customers,
Cast(AVG(MonthlyCharges) As decimal(10,2)) As ARPU,
Cast(Sum(MonthlyCharges) As decimal(10,2)) As Total_Revenue
from dbo.TelcoCustomerChurn
group by Contract
Order by ARPU Desc

--ARPU BY PaymentMethod

Select PaymentMethod, 
Count(*) as Customers,
Cast(AVG(MonthlyCharges) As decimal(10,2)) As ARPU,
Cast(Sum(MonthlyCharges) As decimal(10,2)) As Total_Revenue
From dbo.TelcoCustomerChurn
group by PaymentMethod
order by ARPU Desc

--ARPU BY Tenure group
Select tenure_group,
Count(*) as Customers,
Cast(AVG(MonthlyCharges) As decimal(10,2)) As ARPU,
Cast(Sum(MonthlyCharges) As decimal(10,2)) As Total_Revenue
From dbo.TelcoCustomerChurn
group by tenure_group
order by ARPU Desc

--Churn Analysis


Select churn,
count(*) As Customers,
Cast(Count(*)*100.0/(Select Count(*)
From dbo.TelcoCustomerChurn) As decimal(10,2)) As Percentage
From dbo.TelcoCustomerChurn
group by churn
Order by count(*);


--Churn by Contract
Select Contract, count(*) As Customers,
Sum(ChurnFLag) As ChurnCustomers,
Cast(Count(*)*100.0/(Select Count(*) From dbo.TelcoCustomerChurn) As decimal(10,2)) As Percentage
From dbo.TelcoCustomerChurn
group by Churn, contract
Order by Contract;

Select Contract,
count(*) As Customers,
Sum(Case when ChurnFlag = 1 then 1 else 0 End) As ChurnCustomers,
Cast(Sum(Case when ChurnFlag = 1 then 1 else 0 End)*100.0/Count(*) As decimal(10,2)) As Percentage
From dbo.TelcoCustomerChurn
group by contract
Order by Contract

--Churn by PaymentMethod
Select PaymentMethod,
count(*) As Customers,
Sum(Case when ChurnFlag = 1 then 1 else 0 End) As ChurnCustomers,
Cast(Sum(Case when ChurnFlag = 1 then 1 else 0 End)*100.0/Count(*) As decimal(10,2)) As Percentage
From dbo.TelcoCustomerChurn
group by PaymentMethod
Order by PaymentMethod

--churn by tenure group
Select tenure_group,
count(*) As Customers,
Sum(Case when ChurnFlag = 1 then 1 else 0 End) As ChurnCustomers,
Cast(Sum(Case when ChurnFlag = 1 then 1 else 0 End)*100.0/Count(*) As decimal(10,2)) As Percentage
From dbo.TelcoCustomerChurn
group by tenure_group
Order by tenure_group

--Churn vs non-churn ARPU
select Churn,
Cast(Avg(MonthlyCharges) As decimal(10,2)) As ARPU
From dbo.TelcoCustomerChurn
Group by Churn
Order by ARPU DESC


SELECT 
    Churn,
    COUNT(*) AS Total_Customers,
    CAST(AVG(MonthlyCharges) AS DECIMAL(10,2)) AS ARPU,
    CAST(SUM(MonthlyCharges) AS DECIMAL(10,2)) AS Total_Revenue
FROM dbo.TelcoCustomerChurn
GROUP BY Churn;

--Revenue at risk
Select 
Cast(Sum(MonthlyCharges) As decimal(10,2)) As RevenueAtRisk
From dbo.TelcoCustomerChurn
Where Churn = 'Yes'


