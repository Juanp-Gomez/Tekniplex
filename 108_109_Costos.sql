With all_fields as(
SELECT DISTINCT
  Entity as entity_code,
  CASE WHEN ENTITY = 108 THEN '108-Wenatchee - WA (KFC)'
  WHEN ENTITY = 109 THEN '109-Yakima - WA (WPI)'
          END AS Entity,
  EXTRACT(YEAR FROM DATE(transaction_date)) AS year,
  EXTRACT(MONTH FROM DATE(transaction_date)) AS month,
  CASE 
       WHEN transaction_date >= '2021-07-01' AND transaction_date <= '2022-06-30' then 2022
       WHEN transaction_date >= '2022-07-01' AND transaction_date <= '2023-06-30' then 2023
          END AS FY,
  Customer_ID,
  Customer_Name,
  Customer_Group_Master_Account AS cust_group,
  Customer_Location,
  Intercompany_Transaction_Tagging,
  End_Market,
  SKU,
  Trim(upper(Unit_of_Measurement)) as unit_of_measurement,
  Product__Description,
  Product__class as product_class,
     case when Product__Class = '10x White' then 'egg cartons' 
  when Product__Class = '11x White' then 'egg cartons'
  when Product__Class = '10x Treated' then 'egg cartons'
  when Product__Class = '11x Treated' then 'egg cartons'
  when Product__Class = 'MISC' then 'Other CP'
  when Product__Class = 'NEEDLES' then 'Other CP'
  when Product__Class = 'Pear Wrap Sales' then 'Other CP'
  when Product__Class = 'Vegetable/Misc.' then 'Other CP'
  when Product__Class = 'Apple Wrap Sales' then 'Other CP'
  when Product__Class = 'EURO SALES TO AVO CUSTOMERS' then 'Other CP'
  when Product__Class = 'FREIGHT RECOVERY WINE MULTI BAGGED' then 'Other CP'
  when Product__Class = 'Miscellaneous' then 'Other CP'
  when Product__Class = '10x Green' then 'Produce Tray'
  when Product__Class = '11x Green' then 'Produce Tray'
  when Product__Class = 'EURO TRAYS' then 'Produce Tray'
  when Product__Class = 'WINE TRAYS' then 'Produce Tray'
  when Product__Class = 'AVOCADO TRAYS' then 'Produce Tray'
        else 'TBD'
  end as product_class_H, 
/*   -- falta todavia homologar muchos productos -- WINE OTHER, WINE MULTI W,FILLER FLAT CAPS,FILLER FLAT TRAYS,WINE 1 & 2 BOTTLE,WINE MULTI BAGGED,CELL PACK EURO TRAYS,CONSUMER PRODUCT TRAYS,WINE - PURCHASED MAGNUM,WINE SPARKLING 3 BOTTLE,WINE 1 & 2 BOTTLE BAGGED,PALLET SURCHARGE - WINE OTHER,PALLET SURCHARGE - WINE MULTI W,PALLET SURCHARGE - FILLER FLAT CAPS,FILLER FLAT CAPS - EMATEC PALLETIZED,PALLET SURCHARGE - FILLER FLAT TRAYS,PALLET SURCHARGE - PURPLE EURO TRAYS,PALLET SURCHARGE - WINE 1 & 2 BOTTLE,PALLET SURCHARGE - WINE MULTI BAGGED,FILLER FLAT TRAYS - EMATEC PALLETIZED,PALLET SURCHARGE - CELL PACK EURO TRAYS,PALLET SURCHARGE - STANDARD APPLE TRAYS,PALLET SURCHARGE - CONSUMER PRODUCT TRAYS,PALLET SURCHARGE - WINE SPARKING 3 BOTTLE,PALLET SURCHARGE - WINE 1 & 2 BOTTLE BAGGED */
  Product_Type,
  Primary_Substrate_,
  SUM(round(quantity,1)) AS quantity,
  SUM(round(Sales_Amount,1)) AS sales,
  Sum(round(Standard_Cost,1)) AS Standard_Cost,
  sum(round(Raw_material,1)) as Raw_Material,
  sum(round(indirect_cost_incl_oh,1)) as indirect_cost_incl_oh,
  sum(round(operating_cost_incl_dl,1)) as operating_cost_incl_dl

FROM `responsive-gist-387019.tekniplex.06062023_108_107`
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

,final_108_109 as(SELECT 
   entity_code as entity_code,
   'Fresh Foods Solutions'as Business_unit,
   'Fiber' as Plant_Business_line,
   FY,
   date(concat(year,'-',month,'-','01')) as transaction_date,
   Customer_ID,
   Customer_Name as Customer_Name,
   Customer_Location,
   cust_group as cust_group,
    SKU,
    product__description as sku_escription,
  case when product_class_H = 'egg cartons' then 'fiber'
        when product_class_H = 'Other CP' then 'Other CP'
            else 'TBD'
            end as Product_line, -- Pendiente para hacer completa la homologacion
  product_class,
  Product_Type,
  Primary_Substrate_,
  End_Market,
  product_class_H, 
/*   -- falta todavia homologar muchos productos -- WINE OTHER, WINE MULTI W,FILLER FLAT CAPS,FILLER FLAT TRAYS,WINE 1 & 2 BOTTLE,WINE MULTI BAGGED,CELL PACK EURO TRAYS,CONSUMER PRODUCT TRAYS,WINE - PURCHASED MAGNUM,WINE SPARKLING 3 BOTTLE,WINE 1 & 2 BOTTLE BAGGED,PALLET SURCHARGE - WINE OTHER,PALLET SURCHARGE - WINE MULTI W,PALLET SURCHARGE - FILLER FLAT CAPS,FILLER FLAT CAPS - EMATEC PALLETIZED,PALLET SURCHARGE - FILLER FLAT TRAYS,PALLET SURCHARGE - PURPLE EURO TRAYS,PALLET SURCHARGE - WINE 1 & 2 BOTTLE,PALLET SURCHARGE - WINE MULTI BAGGED,FILLER FLAT TRAYS - EMATEC PALLETIZED,PALLET SURCHARGE - CELL PACK EURO TRAYS,PALLET SURCHARGE - STANDARD APPLE TRAYS,PALLET SURCHARGE - CONSUMER PRODUCT TRAYS,PALLET SURCHARGE - WINE SPARKING 3 BOTTLE,PALLET SURCHARGE - WINE 1 & 2 BOTTLE BAGGED */
  'n/a' as Product_Type_Homologated,
  '' as Primary_Substrate_Homologated,
  end_market as End_Market_Homologated,
  Intercompany_Transaction_Tagging,
  Unit_of_Measurement as UN_of_measurement,
  round(Quantity,2) as quantity,
  null as Sum_of_Units,
  null as Kg_sales,
  round(sales,1) as Sales_USD,
  Round(Standard_cost,1) as Sum_of_costs,
  ROund(raw_material, 1) Raw_Material_USD,
  Round(operating_cost_incl_dl,1) as Operating_Cost_including_Direct_Labor_USD,
  Round(indirect_cost_incl_oh,1) as Indirect_Cost_including_OH_USD,
  Round(sales,1) as Sales_USD_w_discount,
   null as Sum_of_costs_adj,
   null as Raw_Material_USD_adj,
   null as Operating_Cost_including_Direct_Labor_USD_adj,
   null as Indirect_Cost_including_OH_USD_adj,
   null as Discount_Rebate_Amount,
   null as Return_Tagging

    from all_fields
     order by 1
)

select * from final_108_109
