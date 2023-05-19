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

,discount_fields as (  
SELECT distinct 
  ENTITY,
  FY as Year,
  safe_cast(LEFT(Transaction_Date, 2) as float64) as month,
  Customer_Name, 
  SKU, 
  currency,
  sum(Sales_Amount) as Sales_2,
  sum(Return) as return,
  sum(Cash_Discount),
  sum(Rebate),
  sum(Net_Sales)
Transaction_Date FROM `responsive-gist-387019.tekniplex.172_discounts` 
group by 
1,2,3,4,5,6)

,final_172 as(
select
a.*,
b.Sales_2,
b.return,
b.cash_discount,
b.rebate,
b.net_sales
from all_fields a
left join discount_fields b on a.entity=b.entity 
 and a.year=b.year 
  and safe_cast(a.month as string) = safe_cast(b.month as string)
 and a.sku= b.sku
  and a.customer_name= b.customer_name
)

select * from all_fields
