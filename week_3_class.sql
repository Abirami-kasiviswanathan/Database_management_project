1.
SELECT retail.categories.category_name, 
SUM(retail.order_items.total_amount) AS total_sales
FROM retail.order_items 
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories ON retail.products.category_id = retail.categories.category_id
GROUP BY retail.categories.category_name
ORDER BY total_sales desc
LIMIT 10;

-- 2. How revenue varies across different stores
SELECT retail.stores.store_name,  retail.categories.category_name, 
SUM(retail.order_items.total_amount) AS total_sales
FROM retail.order_items 
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories  ON retail.products.category_id = retail.categories.category_id
JOIN retail.stores  ON retail.order_items.store_id = retail.stores.store_id
GROUP BY retail.stores.store_name, retail.categories.category_name
ORDER BY retail.stores.store_name ASC, total_sales DESC;

--3. 
SELECT retail.stores.store_name, 
    retail.categories.category_name, 
    SUM(retail.order_items.total_amount) AS total_sales
FROM retail.order_items 
JOIN retail.products ON retail.order_items.product_id = retail.products.product_id
JOIN retail.categories ON retail.products.category_id = retail.categories.category_id
JOIN retail.stores ON retail.order_items.store_id = retail.stores.store_id
GROUP BY retail.stores.store_name, retail.categories.category_name
ORDER BY total_sales ASC
LIMIT 10;