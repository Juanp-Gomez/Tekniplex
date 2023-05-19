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
  Primary_Substrate_fix,
  currency,
  sum(Quantity) as quantity,
  sum(Sales_Amount) as sales,
  sum(Standard_Material) as Standard_Material,
  sum(Standard_Labor)as Standard_Labor,
  sum(Standard_Overhead)as Standard_OH
 
FROM(
  select *,
  first_value(primary_substrate_) over(partition by SKU order by EXTRACT(MONTH FROM date(Transaction_Date) ) desc) as Primary_Substrate_fix,
  from`responsive-gist-387019.tekniplex.172_FY2023`)

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
  sum(Cash_Discount) as cash_discount,
  sum(Rebate) as rebate,
  sum(Net_Sales) as net_sales
 FROM `responsive-gist-387019.tekniplex.172_discounts` 
group by 
1,2,3,4,5,6)


/*,join_disc as(
select
a.*,
b.*
from all_fields a
full outer join discount_fields b on a.entity=b.entity 
  and a.year=b.year 
  and safe_cast(a.month as string) = safe_cast(b.month as string)
  and a.sku= b.sku
  and a.customer_name= b.customer_name
)*/


,join_disc as(
select
a.*,
b.return,
b.cash_discount,
b.rebate,
b.net_sales,
case when safe_cast(a.month as string)= '1' then 1.0222718
  when safe_cast(a.month as string) = '2' then 1.028073
  when safe_cast(a.month as string) = '3' then 1.0325446
  end as TC
from all_fields a
left join discount_fields b on a.entity=b.entity 
  and a.year=b.year 
  and safe_cast(a.month as string) = safe_cast(b.month as string)
  and a.sku= b.sku
  and a.customer_name= b.customer_name
)

,final_172_FY23 as(
  select 
  concat( entity, '-Belgium Dispensing') as Entity,
  'Integrated Performance Solutions' as Business_Unit,
  'Dispensing' as Plant_Business_line,
  cast(year as integer) as Year,
  cast(month as integer)as Month,
  concat(Year, Month) as concat,
  2023 as FY,
  SKU as SKU,
  product__description as Description,
  Customer_ID,
  cust_group as Customer_Group_Master_Account,
  Customer_name,
  null as Customer_Location,
  Product__Class as Product_Class,
  Product_Type,
  Primary_Substrate_fix as Primary_Substrate_,
  End_Market,
  null as Product_line,
  null as Product_Class__Homologated_,
  null as Product_Type__Homologated_,
  null as Primary_Substrate__Homologated_,
  null as End_Market__Homologated_,
  null as Negocio_Intercompany_Transaction_Tagging,
  Quantity,
  Unit_of_Measurement as UN_of_Measurement,
  null as Sum_of_Units____,
  null as Kg_sales,
  (sales/TC) as Sales_USD,
  ((Standard_material + standard_labor + standard_OH )/TC) as Sum_of_costs,
  (standard_material/TC) as Raw_Material_USD,
  (standard_labor/TC) as Operating_Cost__including_Direct_Labor__USD,
  (standard_OH/ TC) as Indirect_Cost__including_OH__USD,
  (net_sales/TC) as Sales_USD_w_discount,
  null as Sum_of_costs__Adjustado_,
  null as Raw_Material_USD__Adjustado_,
  null as Operating_Cost__including_Direct_Labor__USD__Adjustado_,
  null as Indirect_Cost__including_OH__USD__Adjustado_,
  (cash_discount+rebate) as Discount_Rebate_Amount,
  (return) as Return_Tagging

from join_disc
)

select * from final_172_FY23
