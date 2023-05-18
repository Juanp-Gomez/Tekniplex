with
all_fields as(
SELECT DISTINCT 
  ENTITY,
  EXTRACT(year FROM date(Transaction_Date) ) AS Year,
  EXTRACT(MONTH FROM date(Transaction_Date) ) AS month,
  Customer_ID,
  Customer_Name, 
  Customer_Group_Master_Account as cust_group, 
  End_Market,
  SKU, 
  Unit_of_Measurement, 
  Product__Description, 
  Product__Class, 
  Product_Type, 
  Primary_Substrate_, 
  currency,
  sum(Quantity) as quantity,
  sum(Sales_Amount) as sales,
  sum(Standard_Material) as Standard_Material,
  sum(Standard_Labor)as Standard_Labor,
  sum(Standard_Overhead)as Standard_OH
 
FROM `responsive-gist-387019.tekniplex.172_FY2023`

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14)

select * from all_fields
