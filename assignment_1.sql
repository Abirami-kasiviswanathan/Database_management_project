
--Asignment
-- 1. Show all products that cost less than $50.
SELECT productid, price
FROM products
WHERE price<50
ORDER BY price;

-- 2. Find all customers whose last name is "Brown".
SELECT firstname, lastname
FROM customers
WHERE lastname = 'Brown';

-- 3. Show all orders made by customer ID 1 with sales greater than $78. (Hint use AND to combine filter conditions. For e.g.  the clause WHERE category ='Electronics' AND price >10 would retrieve products in electronics priced greater than $10)
select customerid, sales
from orders
where customerid = 1 AND sales >78;


-- 4. Top two customers based on score. (Hint: use LIMIT)
select *
from customers
order by score DESC
Limit 2;


-- 5. Sales employees (department sales) with salary greater than 50000.
SELECT *
FROM EMPLOYEES
where salary> 50000;