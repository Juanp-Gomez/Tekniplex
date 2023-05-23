  with
all_fields as(
SELECT DISTINCT 
  ENTITY,
  EXTRACT(year FROM date(Transaction_Date) ) AS Year,
  EXTRACT(MONTH FROM date(Transaction_Date) ) AS month,
  Customer_ID,
  Customer_Name, 
  Customer_location,
  Customer_Group_Master_Account as cust_group, 
  End_Market,
  Intercompany_Transaction_Tagging,
  SKU, 
  Unit_of_Measurement, 
  Product__Description, 
  Product__Class, 
  Product_Type, 
  Primary_Substrate_fix,
  currency,
  sum(Quantity) as quantity,
  sum(Sales_Amount) as sales,
  sum(Material) as Standard_Material,
  sum(Laor)as Standard_Labor,
  sum(OH)as Standard_OH,

FROM(
  select *,
  first_value(primary_substrate_) over(partition by SKU order by EXTRACT(MONTH FROM date(Transaction_Date) ) desc) as Primary_Substrate_fix,
  from`responsive-gist-387019.tekniplex.20230523_176_FY2023` )

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)

,final_176_FY23 as(
  select 
  concat( entity, '-Gronau, DEU') as Entity,
  'Integrated Performance Solutions' as Business_Unit,
  'Sealing' as Plant_Business_line,
  cast(year as integer) as Year,
  cast(month as integer)as Month,
  concat(Year, Month) as concat,
  2023 as FY,
  SKU as SKU,
  product__description as Description,
  Customer_ID,
  cust_group as Customer_Group_Master_Account,
  Customer_name,
  Customer_Location,
  Product__Class as Product_Class,
  Product_Type,
  Primary_Substrate_fix as Primary_Substrate_,
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
  ((Standard_material + standard_labor + standard_OH )/TC) as Sum_of_costs,
  (standard_material/TC) as Raw_Material_USD,
  (standard_labor/TC) as Operating_Cost__including_Direct_Labor__USD,
  (standard_OH/ TC) as Indirect_Cost__including_OH__USD,
  ((sales/TC)) as Sales_USD_w_discount, -- discounts already included
  null as Sum_of_costs__Adjustado_,
  null as Raw_Material_USD__Adjustado_,
  null as Operating_Cost__including_Direct_Labor__USD__Adjustado_,
  null as Indirect_Cost__including_OH__USD__Adjustado_,
  null as Discount_Rebate_Amount,
  null as Return_Tagging

from(select *,
case when safe_cast(month as string)= '1' then 1.0222718
  when safe_cast(month as string) = '2' then 1.028073
  when safe_cast(month as string) = '3' then 1.0325446
  when safe_cast(month as string) = '4' then 1.0386896 
  when safe_cast(month as string) = '7' then 1.0193565
  when safe_cast(month as string) = '8' then 1.0156959
  when safe_cast(month as string) = '9' then 1.0073204
  when safe_cast(month as string) = '10' then 1.0010185
  when safe_cast(month as string) = '11' then 1.0049640
  when safe_cast(month as string) = '12' then 1.0136194
  
  end as TC

  from all_fields

)
)

select * from final_176_FY23
