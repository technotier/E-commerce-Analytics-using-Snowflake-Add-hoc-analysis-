-- dim_products created
create table analytics_schema.dim_products as 
with product_cte as (
select
id as product_id,
category_id,
trim(product_name) as product_name,
sale_price::decimal(10, 2) as sale_price,
cost_price::decimal(10, 2) as cost_price,
(sale_price - cost_price)::decimal(10, 2) as profit_amount,
round((sale_price - cost_price) * 100.0 / nullif(sale_price, 0), 2) as profit_amount_pct,
stock_quantity,
/* stock status */
case 
    when stock_quantity <= 0 then 'Out of Stock'
    when stock_quantity < 10 then 'Very Low'
    when stock_quantity < 25 then 'Low'
    when stock_quantity < 50 then 'Medium'
    when stock_quantity < 100 then 'Moderate'
    else 'High Stock'
end as stock_status,
/* price segment */
case 
    when sale_price >= 1000 then 'Luxury'
    when sale_price >= 800 then 'Premium'
    when sale_price >= 500 then 'High'
    when sale_price >= 250 then 'In Budget'
    when sale_price >= 100 then 'Economy'
    else 'Low Price'
end as price_segment
from 
raw_schema.products
)
select
category_id,
product_id,
product_name,
sale_price,
cost_price,
profit_amount,
profit_amount_pct,
/* margin category */
case 
    when profit_amount_pct > 75 then 'Very High'
    when profit_amount_pct > 50 then 'High Margin'
    when profit_amount_pct > 25 then 'Moderate'
    when profit_amount_pct > 10 then 'Medium'
    when profit_amount_pct >= 0 then 'Low Margin'
    else 'Negative Margin'
end as margin_category,
stock_quantity,
stock_status,
price_segment,
current_timestamp as loaded_at
from 
product_cte;
