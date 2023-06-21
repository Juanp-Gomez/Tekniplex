with all_fields as(
select distinct
entity as entity_code,
case when entity = 5101 then '5101 - MD'
    when entity = 5250 then '5250 - PPC'
        end as entity_name,
business_unit,
case when entity = 5101 then 'Plastic/paper'
    when entity = 5250 then 'Plastic'
        end as Plant_Business_main_line,
FY,
Year,
transaction_date as t_date,
_Month as Month,
Customer_ID,
Customer_name,
Customer_location_f2 as customer_location, 
Customer_GroupMaster_Account as cust_group,
SKU,
product__description as sku_description,
'' as product_line,
Product__class as product_class,
Product_type,
primary_substrate_ as primary_substrate,
end_market,
channel,
Intercompany,
Trim(upper(Unit_of_Measurement)) as un_of_measurement,
SUM(quantity) AS quantity,
SUM(Sales_Amount) AS sales,
Sum(Standard_Cost) AS Standard_Cost,  
SUM(Cost_Raw_Material) AS Standard_Material,
SUM(Direct_labor) AS Standard_Labor,
SUM(Indirect_Cost) AS Standard_OH,
sum(DiscountRebate_Amount) as discount_rebate,
sum(Return_Tagging) as return_tagging,
sum(Variations_Raw_Material) as variation_RM,
sum(Variations_Raw_Operation) as variation_RO,
case when year = 2022 and _month = 5 then 0.0002572
      when year = 2022 and _month = 6 then 0.0002572
      when year = 2022 and _month = 7 then 0.0002287
      when year = 2022 and _month = 8 then 0.00023
      when year = 2022 and _month = 9 then 0.0002284
      when year = 2022 and _month = 10 then 0.0002239
      when year = 2022 and _month = 11 then 0.0002194
      when year = 2022 and _month = 12 then 0.0002175
      when year = 2023 and _month = 1 then 0.0002168
      when year = 2023 and _month = 2 then 0.0002157
      when year = 2023 and _month = 3 then 0.000215

      end as TC
from ( select *,
case when Intercompany_Transaction_Tagging = '0' then ''
    when Intercompany_Transaction_Tagging = '#N/A' then ''
    when Intercompany_Transaction_Tagging is null then ''
    when Intercompany_Transaction_Tagging = 'Interco.' then '1'
    when Intercompany_Transaction_Tagging = 'INTERCOMPANY  ' then '1'
    end as Intercompany,
    first_value(customer_location) over(partition by customer_ID order by customer_location desc ) as customer_location_f2,
    FROM `responsive-gist-387019.tekniplex.20230526_FY23_MD_PPC`
)
 
 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
 order by 1
),

final_md_ppc as(select 
entity_code,
entity_name,
Plant_Business_main_line,
year,
month,
FY,
date(concat(year,'-',month,'-','01')) as t_date_f,
t_date, -- esta fecha de factura no es con la que se cuenta en el estado financiera ya que las facturas se confirmaban cuando el cliente recogia el pedido o se confirmaba la transaccion
Customer_ID,
Customer_Name,
customer_location,
cust_group,
SKU,
first_value(sku_description) over(partition by SKU order by sku_description desc ) as sku_description,
---- Homologation
case when primary_substrate = 'PAPER'then 'paper'
    when primary_substrate = 'PET' then 'plastic'
    when primary_substrate = 'PE' then 'plastic'
    when primary_substrate = 'PP' then 'plastic'
    when primary_substrate = 'PS' then 'plastic'
    when primary_substrate = 'ALUMINUM (FOIL)' then 'aluminio'
    when primary_substrate = 'OTHER' then 'Other_CP'
    when primary_substrate = 'SPECIALTY RESINS - BIODEGRADABLE' then 'Other_CP'
    when primary_substrate = 'N/A' then 'n/a'
    else 'Other_CP'
        end as Product_line,
---- End
product_class,
Product_Type,
primary_substrate,
End_Market,
channel,
---- Homologation
lower(product_class) as Product_Class_Homologated,
---- End
'N/A' as Product_Type_Homologated,
primary_substrate as Primary_Substrate_Homologated,
end_market as End_Market_Homologated,
first_value(Intercompany) over(partition by customer_ID order by Intercompany desc ) as Intercompany,
Un_of_Measurement as UN_of_measurement,
round(Quantity,2) as quantity,
null as Sum_of_units,
null as Kg_sales,
round((sales*tc),2) as Sales_USD,
Round((COALESCE(Standard_material*tc, 0) + COALESCE(standard_labor*tc, 0) + COALESCE(standard_OH*tc, 0) ),2) as sum_of_costs_USD,
Round((standard_material*tc),2) as Raw_Material_USD,
Round((standard_labor*tc),2) as Operating_Cost_including_dl_USD,
Round((standard_OH*tc),2) as Indirect_Cost_including_OH__USD,
Round((coalesce(sales*tc,0) + coalesce(discount_rebate*tc,0) + coalesce(Return_Tagging*tc,0)),2) as Sales_USD_w_discount,-- validar esta suma
null as Sum_of_costs_adj,
null as Raw_Material_USD_adj,
null as Operating_Cost_including_Direct_Labor_USD_adj,
null as Indirect_Cost_including_OH_USD_adj,
discount_rebate as discount_rebate,
Return_Tagging as return_tagging,
round ((variation_rm*tc),2) as variation_rm,
round ((variation_ro*tc),2) as variation_ro,


from all_fields
)

/*select * from final_md_ppc
where month in (10, 11, 12, 1 ,2 ,3)
*/

/*select Entity_name, sku, sku_description, product_class, Primary_Substrate, intercompany, 
sum(Sales_USD_w_discount) as Sales,
sum(Sum_of_costs_usd) as Costs, 
sum(Raw_Material_USD) as Raw_Mat, 
sum(Operating_Cost_including_Dl_USD) as Operating_cost,
sum(Indirect_Cost_including_OH__USD) as Ind_Cost,
sum(Variation_rm) as VarRM,
sum(Variation_ro) as VarOP,


from final_md_ppc 
where month in (10, 11, 12, 1 ,2 ,3)

group by 1,2,3,4,5,6

*/

/*select entity_name, Customer_ID,
Customer_Name,
Customer_location,
intercompany, 
sum(Sales_USD_w_discount) as Sales,
sum(Sum_of_costs_usd) as Costs, 
sum(Raw_Material_USD) as Raw_Mat, 
sum(Operating_Cost_including_Dl_USD) as Operating_cost,
sum(Indirect_Cost_including_OH__USD) as Ind_Cost,
sum(Variation_rm) as VarRM,
sum(Variation_ro) as VarOP,


from final_md_ppc 
where month in (10, 11, 12, 1 ,2 ,3)

group by 1,2,3,4,5
*/
