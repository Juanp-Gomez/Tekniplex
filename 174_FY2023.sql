-- 174 Italy 

with 
all_fields as (
SELECT  
  ENTITY,
  Business_Unit,
  fy,
  FY AS Year,
  Month,
  Customer_ID,
  Customer_Name, 
  Customer_Group_Master_Account, 
  Customer_Location,
  Intercompany_Transaction_Tagging,
  End_Market,
  SKU, 
  Unit_of_Measurement, 
  Product__Description, 
  Product__Class, 
  Product_Type, 
  Primary_Substrate_,
  currency,
  case when month = 1 then 1.0222718
  when month = 2 then 1.028073
  when month = 3 then 1.0325446
  end as TC,
  sum(Quantity) as quantity,
  sum(Sales_Amount) as sales,
  sum(Standard_Material) as Standard_Material,
  sum(Standard_Labor)as Standard_Labor,
  sum(Standard_Overhead)as Standard_OH,
  sum(Discount_Rebate_Amount) as Discount_Rebate_Amount,
  sum( cast(Return_Tagging as float64)) as Return_Tagging
FROM 
(select
*,
case when LEFT(Transaction_Date, 3)='ene' then 1
  when LEFT(Transaction_Date, 3)='feb' then 2
  when LEFT(Transaction_Date, 3)='mar' then 3
  end as month

from `responsive-gist-387019.tekniplex.05192023_FY2023Q3_174` 
)
group by
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
)

,final_174 as(
select 
  concat( entity, '-Gaggiano, ITA') as Entity,
  Business_Unit,
  'Dispensing' as Plant_Business_line,
  Year,
  Month,
  concat(Year, Month) as concat,
  FY,
  SKU as SKU,
  product__description as Description,
  Customer_ID,
  Customer_Group_Master_Account,
  Customer_name,
  Customer_Location,
  Product__Class as Product_Class,
  Product_Type,
  Primary_Substrate_,
  End_Market,
  null as Product_line,
  null as Product_Class__Homologated_,
  null as Product_Type__Homologated_,
  null as Primary_Substrate__Homologated_,
  null as End_Market__Homologated_,
  Intercompany_Transaction_Tagging as Negocio_Intercompany_Transaction_Tagging,
  Quantity,
  Unit_of_Measurement as UN_of_Measurement,
  null as Sum_of_Units____,
  null as Kg_sales,
  (sales/TC) as Sales_USD,
 ((COALESCE(Standard_material, 0) + COALESCE(standard_labor, 0) + COALESCE(standard_OH, 0) )/TC) as Sum_of_costs,
  (standard_material/TC) as Raw_Material_USD,
  (standard_labor/TC) as Operating_Cost__including_Direct_Labor__USD,
  (standard_OH/ TC) as Indirect_Cost__including_OH__USD,
  ((sales-discount_rebate_amount)/TC) as Sales_USD_w_discount,
  null as Sum_of_costs__Adjustado_,
  null as Raw_Material_USD__Adjustado_,
  null as Operating_Cost__including_Direct_Labor__USD__Adjustado_,
  null as Indirect_Cost__including_OH__USD__Adjustado_,
  Discount_Rebate_Amount,
  Return_Tagging

from all_fields
)

select * from final_174
