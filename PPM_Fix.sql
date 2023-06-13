with
all_fields as(
SELECT DISTINCT 
  ENTITY,
  Year,
  month,
  Business_Unit,
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
  sum(Raw_Material) as Standard_Material,
  sum(Direct_Labor)as Standard_Labor,
  sum(Indirect_Cost)as Standard_OH,
  sum(Discount_Rebate_Amount) as Discount_Rebate_Amount,
  sum(Return_Tagging) as _Return_Tagging_,
  sum(Raw_Material_Var) as Variacion_Raw_Material,
  sum(Variations_X_Operation) as Variation_X_Operation
FROM(
  select *,
  first_value(primary_substrate_) over(partition by SKU order by EXTRACT(MONTH FROM date(Transaction_Date) ) desc) as Primary_Substrate_fix,
  from `responsive-gist-387019.tekniplex.20230523_PPM_FY2023`)

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
)



,final_PPM_FY23 as(
  select 
  concat( entity, '-PPMex') as Entity,
  Business_Unit,
  'Plastic' as Plant_Business_line,
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
  (sales*TC) as Sales_USD,
  ((COALESCE(Standard_material, 0) + COALESCE(standard_labor, 0) + COALESCE(standard_OH, 0) )*TC) as Sum_of_costs,
  (standard_material*TC) as Raw_Material_USD,
  (standard_labor*TC) as Operating_Cost__including_Direct_Labor__USD,
  (standard_OH* TC) as Indirect_Cost__including_OH__USD,
  ((coalesce(sales, 0) - COALESCE(Discount_Rebate_Amount, 0) - COALESCE(_Return_Tagging_, 0)) *TC) as Sales_USD_w_discount, 
  null as Sum_of_costs__Adjustado_,
  null as Raw_Material_USD__Adjustado_,
  null as Operating_Cost__including_Direct_Labor__USD__Adjustado_,
  null as Indirect_Cost__including_OH__USD__Adjustado_,
  null as Discount_Rebate_Amount,
  null as Return_Tagging,
  Variacion_Raw_Material*tc as Variacion_Raw_Material ,
  Variation_X_Operation*tc Variation_X_Operation,
  coalesce(Variacion_Raw_Material,0) * tc +coalesce(Variation_X_Operation,0)* tc as Total_variation

from(select *,
case when safe_cast(month as string)= '1' then 0.0504556
  when safe_cast(month as string) = '2' then 0.0508411
  when safe_cast(month as string) = '3' then 0.0511990
  when safe_cast(month as string) = '4' then 0.0515845 
  when safe_cast(month as string) = '7' then 0.0487700
  when safe_cast(month as string) = '8' then 0.0492148
  when safe_cast(month as string) = '9' then 0.0494254
  when safe_cast(month as string) = '10' then 0.0495673
  when safe_cast(month as string) = '11' then 0.0499194
  when safe_cast(month as string) = '12' then 0.0501051
  
  end as TC

  from all_fields
)
)

select sum(Variacion_Raw_Material) from final_PPM_FY23 
where FY = 2023
