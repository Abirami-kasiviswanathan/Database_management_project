--Show every column for all stores
select *
From retail.categories;

--list only the customer ID, first name, last name, and email for all customers.
SELECT customer_id, first_name, last_name, email
FROM retail.customers;

--4 Find the unique store IDs that appear in the orders table.
SELECT DISTINCT store_id
FROM retail.orders
ORDER BY store_id;

-- 5 Find the Seattle store record by exact store name.
Select product_id, product_name, category_id
from retail.products
where products.category_id = 2;

--Find online stores whose store ID is greater than 5.
select *
from retail.stores
where is_online = true
and store_id > 5;

--Show products priced between 25 and 50.
SELECT product_id, product_name, base_price
FROM retail.products
WHERE base_price BETWEEN 25 AND 50;

--Show orders placed during January 2026

select *
from retail.orders 
where order_date between '2026-01-01' and '2026-01-31';

 --Find products in categories 1, 2, or 4.
select *
from retail.products
where category_id in (1,2,4);

-- or one more way to do above
select *
from retail.products
where category_id =1 or category_id=2 or category_id=4;


--Find products whose names start with Cordless.
select product_id, product_name
from retail.products
where product_name like '%Cordless%';

-- Return the first 10 products for a quick preview.
SELECT product_id, product_name, base_price
FROM retail.products
ORDER BY product_id
LIMIT 10;


--Calculate the per-unit dollar margin for each product.
SELECT product_id,
product_name, base_price, cost,
base_price - cost AS unit_margin
FROM retail.products;

--how phone numbers, but replace missing values with Not Provided
SELECT customer_id,
first_name,
last_name,
COALESCE(phone, 'Not Provided') AS phone_display
FROM retail.customers;

-- what is the total revenue captured in order items
select avg (total_amount) as total_revenue
FROM retail.order_items;

-- Count customers by primary store.
SELECT primary_store_id,
COUNT(*) AS customer_count
FROM retail.customers
GROUP BY primary_store_id;

--   sum inventory records by store and product
SELECT store_id, product_id, SUM(stock_level)
FROM retail.inventory
WHERE store_id = 3
GROUP BY store_id, product_id
HAVING SUM(stock_level) < 50;

-- where is used on orignal table to filter and having is used to filter the result


--List products with their category names.
SELECT p.product_id,
p.product_name,
c.category_name
FROM retail.products p
INNER JOIN retail.categories c
ON p.category_id = c.category_id;