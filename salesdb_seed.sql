-- salesdb_seed.sql
-- Adapted from the schema pattern in Sajjad Rahman's DEV article
-- "Building a Sales Database in PostgreSQL — Schema, Data & JOIN Examples"
-- https://dev.to/sajjadrahman56/building-a-sales-database-in-postgresql-schema-data-join-examples-33l8
--
-- This script creates and populates a simple sales database with:
--   * 3 employees
--   * 5 customers
--   * 10 products
--   * 200 transactions (orders)
--
-- Usage:
--   psql -d your_database -f salesdb_seed.sql

BEGIN;

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- PRODUCTS
CREATE TABLE products (
    productid    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name TEXT NOT NULL,
    category     TEXT,
    price        NUMERIC(12,2) NOT NULL CHECK (price >= 0)
);

-- CUSTOMERS
CREATE TABLE customers (
    customerid   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname    TEXT NOT NULL,
    lastname     TEXT NOT NULL,
    country      TEXT,
    score        INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0)
);

-- EMPLOYEES (self-referencing manager)
CREATE TABLE employees (
    employeeid   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname    TEXT NOT NULL,
    lastname     TEXT NOT NULL,
    department   TEXT,
    birthdate    DATE,
    gender       VARCHAR(10),
    salary       NUMERIC(12,2) CHECK (salary >= 0),
    managerid    BIGINT,
    CONSTRAINT fk_manager
        FOREIGN KEY (managerid)
        REFERENCES employees(employeeid)
        ON DELETE SET NULL
);

-- ORDERS
CREATE TABLE orders (
    orderid       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    productid     BIGINT NOT NULL,
    customerid    BIGINT NOT NULL,
    salespersonid BIGINT,
    orderdate     DATE NOT NULL,
    shipdate      DATE,
    orderstatus   TEXT NOT NULL,
    shipaddress   TEXT,
    billaddress   TEXT,
    quantity      INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    sales         NUMERIC(14,2) NOT NULL CHECK (sales >= 0),
    creationtime  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    CONSTRAINT fk_orders_product
        FOREIGN KEY (productid)
        REFERENCES products(productid)
        ON DELETE RESTRICT,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customerid)
        REFERENCES customers(customerid)
        ON DELETE RESTRICT,
    CONSTRAINT fk_orders_salesperson
        FOREIGN KEY (salespersonid)
        REFERENCES employees(employeeid)
        ON DELETE SET NULL
);

CREATE INDEX idx_orders_productid ON orders(productid);
CREATE INDEX idx_orders_customerid ON orders(customerid);
CREATE INDEX idx_orders_salespersonid ON orders(salespersonid);
CREATE INDEX idx_employees_managerid ON employees(managerid);
CREATE INDEX idx_orders_orderdate ON orders(orderdate);

-- Seed master data ----------------------------------------------------------

INSERT INTO products (product_name, category, price) VALUES
('Widget',       'Gadgets',      19.99),
('Gizmo',        'Gadgets',      29.50),
('Chair',        'Furniture',   120.00),
('Desk',         'Furniture',   250.00),
('Laptop',       'Electronics', 899.99),
('Mouse',        'Electronics',  25.99),
('Keyboard',     'Electronics',  49.99),
('Headphones',   'Audio',        79.00),
('Smartwatch',   'Wearables',   199.99),
('Sofa',         'Furniture',   599.00);

INSERT INTO customers (firstname, lastname, country, score) VALUES
('Alice', 'Anderson', 'USA',    87),
('Bob',   'Brown',    'USA',    72),
('Carol', 'Clark',    'UK',     95),
('David', 'Davis',    'Canada', 67),
('Eve',   'Evans',    'Germany',92);

-- Insert manager first so reports can reference employeeid = 1
INSERT INTO employees (firstname, lastname, department, birthdate, gender, salary, managerid) VALUES
('Sam',  'Smith', 'Sales', '1988-05-20', 'M', 65000.00, NULL),
('Jill', 'Jones', 'Sales', '1990-09-10', 'F', 47000.00, 1),
('Peter','Parker','Sales', '1992-01-15', 'M', 44000.00, 1);

-- Seed 200 orders -----------------------------------------------------------
-- We use generate_series so the script stays compact while still creating
-- realistic row-by-row transactional data.

SELECT setseed(0.314159);

INSERT INTO orders (
    productid,
    customerid,
    salespersonid,
    orderdate,
    shipdate,
    orderstatus,
    shipaddress,
    billaddress,
    quantity,
    sales,
    creationtime
)
SELECT
    product_choice.productid,
    customer_choice.customerid,
    employee_choice.employeeid,
    order_info.orderdate,
    CASE
        WHEN order_info.orderstatus IN ('shipped', 'delivered')
            THEN order_info.orderdate + ((gs.n % 5) + 1)
        ELSE NULL
    END AS shipdate,
    order_info.orderstatus,
    customer_choice.shipaddress,
    customer_choice.billaddress,
    qty.quantity,
    ROUND((product_choice.price * qty.quantity)::numeric, 2) AS sales,
    order_info.orderdate::timestamp
      + make_interval(hours => (gs.n % 9) + 8, mins => (gs.n * 7) % 60) AS creationtime
FROM generate_series(1, 200) AS gs(n)
CROSS JOIN LATERAL (
    SELECT ((gs.n - 1) % 10) + 1 AS productid,
           CASE ((gs.n - 1) % 10) + 1
               WHEN 1 THEN  19.99
               WHEN 2 THEN  29.50
               WHEN 3 THEN 120.00
               WHEN 4 THEN 250.00
               WHEN 5 THEN 899.99
               WHEN 6 THEN  25.99
               WHEN 7 THEN  49.99
               WHEN 8 THEN  79.00
               WHEN 9 THEN 199.99
               WHEN 10 THEN 599.00
           END::numeric(12,2) AS price
) AS product_choice
CROSS JOIN LATERAL (
    SELECT ((gs.n - 1) % 5) + 1 AS customerid,
           CASE ((gs.n - 1) % 5) + 1
               WHEN 1 THEN '123 Main St, Seattle, WA'
               WHEN 2 THEN '456 Oak Ave, Portland, OR'
               WHEN 3 THEN '78 Elm St, London, UK'
               WHEN 4 THEN '12 Maple Rd, Toronto, ON'
               WHEN 5 THEN '9 King Strasse, Berlin, DE'
           END AS shipaddress,
           CASE ((gs.n - 1) % 5) + 1
               WHEN 1 THEN '123 Main St, Seattle, WA'
               WHEN 2 THEN '456 Oak Ave, Portland, OR'
               WHEN 3 THEN '78 Elm St, London, UK'
               WHEN 4 THEN '12 Maple Rd, Toronto, ON'
               WHEN 5 THEN '9 King Strasse, Berlin, DE'
           END AS billaddress
) AS customer_choice
CROSS JOIN LATERAL (
    SELECT CASE
               WHEN gs.n % 10 IN (1,2,3,4) THEN 2
               WHEN gs.n % 10 IN (5,6,7)   THEN 3
               ELSE 1
           END AS employeeid
) AS employee_choice
CROSS JOIN LATERAL (
    SELECT ((gs.n % 4) + 1) AS quantity
) AS qty
CROSS JOIN LATERAL (
    SELECT
        (DATE '2025-01-01' + ((gs.n * 2) % 365)) AS orderdate,
        CASE
            WHEN gs.n % 10 IN (1,2,3,4,5) THEN 'shipped'
            WHEN gs.n % 10 IN (6,7)       THEN 'processing'
            WHEN gs.n % 10 = 8            THEN 'new'
            WHEN gs.n % 10 = 9            THEN 'delivered'
            ELSE 'cancelled'
        END AS orderstatus
) AS order_info;

COMMIT;

-- Optional verification queries ---------------------------------------------
-- SELECT COUNT(*) AS products_count  FROM products;
-- SELECT COUNT(*) AS customers_count FROM customers;
-- SELECT COUNT(*) AS employees_count FROM employees;
-- SELECT COUNT(*) AS orders_count    FROM orders;
