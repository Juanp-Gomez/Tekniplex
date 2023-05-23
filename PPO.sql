with
all_fields as(
SELECT DISTINCT 
  ENTITY,
  Year,
  right(FY, 4) as FY,
  _Month as month,
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
  sum(Raw_Material_Cost) as Standard_Material,
  sum(Direct_Labor)as Standard_Labor,
  sum(Overhead)as Standard_OH,
  sum(Discount_Rebate_Amount) as Discount_Rebate_Amount,
  sum(Return_Tagging) as _Return_Tagging_,
  sum(WIP_MAT) as Total_variation
FROM(
  select *,
  first_value(primary_substrate_) over(partition by SKU order by EXTRACT(MONTH FROM date(Transaction_Date) ) desc) as Primary_Substrate_fix,
  from `responsive-gist-387019.tekniplex.20230523_PPO`)

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)



,final_PPO as(
  select 
  concat( entity, '-PPO') as Entity,
  case when lower(left(sku,1)) = 'a' then 'Arizona'
  when lower(left(sku,1)) = 'o' then 'Virginia'
  else 'Comercializados-Otros' 
  end as Split,
  Business_Unit,
  'Plastic' as Plant_Business_line,
  cast(year as integer) as Year,
  cast(month as integer)as Month,
  concat(Year, Month) as concat,
  FY,
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
  (sales) as Sales_USD,
  ((COALESCE(Standard_material, 0) + COALESCE(standard_labor, 0) + COALESCE(standard_OH, 0) )) as Sum_of_costs,
  (standard_material) as Raw_Material_USD,
  (standard_labor) as Operating_Cost__including_Direct_Labor__USD,
  (standard_OH) as Indirect_Cost__including_OH__USD,
  ((coalesce(sales,0) - COALESCE(Discount_Rebate_Amount, 0) - COALESCE(_Return_Tagging_, 0))) as Sales_USD_w_discount, 
  null as Sum_of_costs__Adjustado_,
  null as Raw_Material_USD__Adjustado_,
  null as Operating_Cost__including_Direct_Labor__USD__Adjustado_,
  null as Indirect_Cost__including_OH__USD__Adjustado_,
  Discount_Rebate_Amount,
  _Return_Tagging_,
  null as Variacion_Raw_Material,
  null as Variation_X_Operation,
  Total_variation

from all_fields
)
select * from final_PPO

