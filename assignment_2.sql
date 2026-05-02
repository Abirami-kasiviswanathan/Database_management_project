 --List products and stock levels for store 6 where stock level is less than or equal to 50. 
 select product_id, stock_level, store_id
 from retail.inventory
 where store_id = 6 and stock_level <= 50 ;

 --List product names with their category and product type for products that are a Set (Have Set in their name). Sort alphabetically by product name. (1.5 pts)
select p.product_name, c.category_name , pt.type_name
from retail.products p 
join retail.product_types pt on p.type_id = pt.type_id 
join retail.categories c on p.category_id = c.category_id
where product_name LIKE '%Set%' 
order by p.product_name;

-- Order line items in Redmond store between Jan 1 and Jan 15, 2025 for POWER TOOLS.
select retail.order_items.*
from retail.order_items 
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
join retail.orders ON retail.order_items.order_id = retail.orders.order_id
JOIN retail.stores ON retail.orders.store_id = retail.stores.store_id
JOIN retail.categories ON retail.products.category_id = retail.categories.category_id
where  retail.stores.store_name ilike '%redmond%' and orders.order_date between'2025-01-01' and'2025-01-15' and 
retail.categories.category_name ILIKE '%power tools%';

--Inventory in store 3 with stock > 3000 and ELECTRICAL category. (2pts)
SELECT retail.products.* 
FROM retail.products
join retail.inventory on retail.products.product_id = retail.inventory.product_id
join retail.categories on retail.products.category_id = retail.categories.category_id
where retail.inventory.store_id = 3 and retail.inventory.stock_level >3000 and retail.categories.category_name ilike '%electrical%';


--Total sales by store and category. (2pts)
SELECT retail.stores.store_name,  retail.categories.category_name, 
SUM(retail.order_items.total_amount) AS total_sales
FROM retail.order_items 
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories  ON retail.products.category_id = retail.categories.category_id
JOIN retail.stores  ON retail.order_items.store_id = retail.stores.store_id
GROUP BY retail.stores.store_name, retail.categories.category_name
ORDER BY retail.stores.store_name ASC, total_sales DESC;


--Store-category combinations with sales >3000000. (3pts)

SELECT retail.stores.store_name, retail.categories.category_name, 
SUM(retail.order_items.total_amount) AS total_sales
FROM retail.order_items
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories  ON retail.products.category_id = retail.categories.category_id
JOIN retail.stores  ON retail.order_items.store_id = retail.stores.store_id
GROUP BY retail.stores.store_name, retail.categories.category_name
HAVING SUM(retail.order_items.total_amount) >3000000;

--Store-category with sales >1000000 and at least 10000 line items. (3pts)
SELECT 
    retail.stores.store_name, 
    retail.categories.category_name, 
    SUM(retail.order_items.total_amount) AS total_sales,
    COUNT(retail.order_items.order_item_id) AS line_item_count
FROM retail.order_items
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories ON retail.products.category_id = retail.categories.category_id
JOIN retail.stores ON retail.order_items.store_id = retail.stores.store_id
GROUP BY retail.stores.store_name, retail.categories.category_name
HAVING SUM(retail.order_items.total_amount) > 1000000 
   AND COUNT(retail.order_items.order_item_id) >= 10000;