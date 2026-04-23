CREATE TABLE IF NOT EXISTS Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Vendor (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(150) NOT NULL,
    is_npo_partner BOOLEAN DEFAULT FALSE,
    location_type VARCHAR(50),
    sustainability_score INT CHECK (sustainability_score <= 100)
);

CREATE TABLE IF NOT EXISTS Product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    brand VARCHAR(100),
    category_id INT REFERENCES Category(category_id)
);

CREATE TABLE IF NOT EXISTS Price_Listing (
    listing_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Product(product_id),
    vendor_id INT REFERENCES Vendor(vendor_id),
    current_stock_status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Price_History (
    history_id SERIAL PRIMARY KEY,
    listing_id INT REFERENCES Price_Listing(listing_id),
    recorded_price DECIMAL(10,2),
    recorded_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Price_History (
    history_id SERIAL PRIMARY KEY,
    listing_id INT REFERENCES Price_Listing(listing_id),
    recorded_price DECIMAL(10,2),
    recorded_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    impact_preference VARCHAR(50),
    gender VARCHAR(50),
    ip_address VARCHAR(50)
);

--CREATE TABLE IF NOT EXISTS Users (
--     user_id SERIAL PRIMARY KEY,
--     user_name VARCHAR(100) NOT NULL,
--     email VARCHAR(150) UNIQUE,
--     impact_preference VARCHAR(50),
--     gender VARCHAR(50),
--     ip_address VARCHAR(50)
-- );

INSERT INTO Category (category_name) VALUES
('Fair Trade Coffee'),
('Ethical Apparel'),
('Organic Produce');

INSERT INTO Vendor (vendor_name, is_npo_partner, location_type, sustainability_score) VALUES
('East Bay Community Garden', TRUE, 'Local', 95),
('San Jose Ethical Apparel', FALSE, 'Local', 82),
('Global Fair Trade Hub', TRUE, 'Online', 88),
('The Sustainable Pantry', TRUE, 'Local', 91),
('Hayward Eco-Refill Station', FALSE, 'Local', 75),
('Oakland Artisan Collective', TRUE, 'Local', 89),
('Green-Tech Solutions', FALSE, 'Online', 65),
('Thrift & Thrive NPO', TRUE, 'Local', 98),
('Pacific Organic Co-op', FALSE, 'Local', 84),
('Kindness Coffee Project', TRUE, 'Online', 93);

INSERT INTO Product (product_name, brand, category_id) VALUES
('Dark Roast Whole Bean', 'Kindness Coffee', 1),
('Hemp Blend T-Shirt', 'Eco-Threads', 2),
('Organic Tomatoes', 'East Bay Farms', 3),
('Single Origin Espresso', 'Fair-Trade Roasts', 1),
('Recycled Cotton Tote', 'Oakland Collective', 2);

INSERT INTO Price_Listing (product_id, vendor_id, current_stock_status) VALUES
(1, 1, 'In Stock'),
(2, 2, 'In Stock'),
(3, 3, 'In Stock'),
(4, 4, 'In Stock'),
(5, 5, 'In Stock');


--price history - from python

INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 46.68, '2026-04-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 43.25, '2026-04-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 43.64, '2026-03-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 44.13, '2026-03-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 44.59, '2026-02-21 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 39.06, '2026-02-06 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 43.13, '2026-01-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 42.01, '2026-01-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 42.1, '2025-12-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 46.63, '2025-12-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 38.82, '2025-11-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 38.34, '2025-11-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 43.52, '2025-10-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 43.97, '2025-10-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 45.71, '2025-09-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 46.25, '2025-09-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 41.29, '2025-08-25 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 41.02, '2025-08-10 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 42.73, '2025-07-26 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (1, 45.18, '2025-07-11 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 40.37, '2026-04-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 43.67, '2026-04-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 37.2, '2026-03-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 41.57, '2026-03-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 38.46, '2026-02-21 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 42.66, '2026-02-06 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 39.37, '2026-01-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 37.51, '2026-01-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 41.28, '2025-12-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 43.57, '2025-12-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 40.37, '2025-11-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 41.99, '2025-11-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 43.34, '2025-10-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 41.76, '2025-10-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 41.09, '2025-09-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 43.54, '2025-09-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 36.94, '2025-08-25 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 40.85, '2025-08-10 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 38.07, '2025-07-26 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (2, 40.52, '2025-07-11 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 11.08, '2026-04-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.2, '2026-04-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.51, '2026-03-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.51, '2026-03-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.68, '2026-02-21 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.08, '2026-02-06 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 9.81, '2026-01-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 9.91, '2026-01-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.39, '2025-12-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.88, '2025-12-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 11.39, '2025-11-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 11.15, '2025-11-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.67, '2025-10-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.57, '2025-10-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 11.35, '2025-09-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.45, '2025-09-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.34, '2025-08-25 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 9.82, '2025-08-10 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 11.28, '2025-07-26 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (3, 10.5, '2025-07-11 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 37.32, '2026-04-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 33.3, '2026-04-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.76, '2026-03-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 33.17, '2026-03-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 31.63, '2026-02-21 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 33.15, '2026-02-06 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.04, '2026-01-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 32.79, '2026-01-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 36.12, '2025-12-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 32.43, '2025-12-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.93, '2025-11-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.06, '2025-11-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.14, '2025-10-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 37.79, '2025-10-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 36.59, '2025-09-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 33.57, '2025-09-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 37.04, '2025-08-25 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 32.19, '2025-08-10 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 35.93, '2025-07-26 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (4, 37.42, '2025-07-11 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.65, '2026-04-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.36, '2026-04-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.81, '2026-03-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.44, '2026-03-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.22, '2026-02-21 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.39, '2026-02-06 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 15.19, '2026-01-22 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 15.62, '2026-01-07 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.8, '2025-12-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.71, '2025-12-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.18, '2025-11-23 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.46, '2025-11-08 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 14.64, '2025-10-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 13.82, '2025-10-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 15.84, '2025-09-24 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 13.82, '2025-09-09 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.38, '2025-08-25 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 15.52, '2025-08-10 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 16.25, '2025-07-26 15:32:27');
INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES (5, 13.77, '2025-07-11 15:32:27');
--- END OF SQL ---


--verification

SELECT 
    p.product_name, 
    ph.recorded_at, 
    ph.recorded_price
FROM Price_History ph
JOIN Price_Listing pl ON ph.listing_id = pl.listing_id
JOIN Product p ON pl.product_id = p.product_id
ORDER BY p.product_name, ph.recorded_at ASC;


--users 

insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (1, 'vlove0', 'mconn0@last.fm', 'NPO-First', 'Male', '57.50.37.250');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (2, 'gmaccombe1', 'jjanaway1@vinaora.com', 'Local-Only', 'Genderqueer', '128.145.137.19');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (3, 'blyman2', 'iwitchell2@google.ru', 'Local-Only', 'Male', '163.199.147.29');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (4, 'cmcdarmid3', 'hszubert3@walmart.com', 'Sustainability-First', 'Male', '152.82.46.167');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (5, 'oormston4', 'ebouchier4@stanford.edu', 'Local-Only', 'Female', '112.166.222.97');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (6, 'kjiranek5', 'astapford5@spotify.com', 'Price-First', 'Female', '219.2.246.233');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (7, 'cpunchard6', 'jschubert6@trellian.com', 'Local-Only', 'Genderqueer', '69.212.28.164');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (8, 'vhowsam7', 'bcriple7@merriam-webster.com', 'Price-First', 'Female', '249.122.178.53');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (9, 'dtremmil8', 'rreadett8@nps.gov', 'Price-First', 'Female', '181.74.140.232');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (10, 'ebinnes9', 'jheigl9@ftc.gov', 'Local-Only', 'Male', '199.106.242.195');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (11, 'ccorisha', 'comaileya@people.com.cn', 'Price-First', 'Male', '99.251.71.5');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (12, 'blongmateb', 'abarlassb@omniture.com', 'Local-Only', 'Male', '205.194.56.116');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (13, 'mbeacockc', 'askittlesc@theatlantic.com', 'Local-Only', 'Genderqueer', '92.27.175.237');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (14, 'mzylberdikd', 'rmckennyd@addtoany.com', 'Sustainability-First', 'Genderqueer', '177.138.163.172');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (15, 'dbrydone', 'hfretsone@discovery.com', 'Local-Only', 'Female', '104.67.167.171');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (16, 'ckyteleyf', 'ehusselbeef@dailymotion.com', 'Sustainability-First', 'Female', '191.217.145.129');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (17, 'lmathisong', 'fsullivang@wikispaces.com', 'Sustainability-First', 'Female', '179.133.57.181');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (18, 'rhurdh', 'noggerh@eepurl.com', 'Sustainability-First', 'Male', '150.27.69.155');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (19, 'ljopei', 'phallihanei@hao123.com', 'Price-First', 'Female', '137.213.233.238');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (20, 'celdridgej', 'hheintzj@ft.com', 'Local-Only', 'Male', '139.185.15.174');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (21, 'lwreifordk', 'kpitcockk@time.com', 'Sustainability-First', 'Male', '155.216.104.63');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (22, 'bgonsalol', 'jporkerl@washingtonpost.com', 'Price-First', 'Female', '53.49.227.34');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (23, 'cskalam', 'lromaynem@cam.ac.uk', 'Sustainability-First', 'Male', '205.165.193.164');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (24, 'jroomesn', 'jblaisen@free.fr', 'Price-First', 'Male', '82.71.67.141');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (25, 'fmallingo', 'adunlopo@about.com', 'NPO-First', 'Female', '44.18.117.19');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (26, 'erushfordp', 'fcoddringtonp@amazon.co.jp', 'Price-First', 'Male', '22.154.225.125');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (27, 'ldewenq', 'bleheudeq@biblegateway.com', 'NPO-First', 'Female', '127.1.219.148');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (28, 'kbromellr', 'avasiliur@artisteer.com', 'Sustainability-First', 'Male', '225.212.87.37');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (29, 'rchanderss', 'pghilardis@discovery.com', 'Price-First', 'Female', '159.249.8.109');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (30, 'lramsayt', 'sdeclerct@dailymail.co.uk', 'Price-First', 'Male', '136.199.176.13');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (31, 'fantonelliniu', 'ajacquestu@mozilla.org', 'NPO-First', 'Genderqueer', '93.189.24.198');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (32, 'lmattekv', 'emackrellv@google.com.hk', 'Sustainability-First', 'Male', '143.176.66.164');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (33, 'klampetw', 'wbentew@answers.com', 'Local-Only', 'Male', '61.244.207.26');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (34, 'dbirkinx', 'jbluemanx@arizona.edu', 'NPO-First', 'Genderfluid', '12.32.48.35');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (35, 'slovelessy', 'jshortany@networkadvertising.org', 'NPO-First', 'Male', '149.204.232.55');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (36, 'tminesz', 'sbudnkz@yale.edu', 'Sustainability-First', 'Polygender', '235.175.137.98');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (37, 'ascrivinor10', 'chosby10@columbia.edu', 'Price-First', 'Male', '177.112.119.115');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (38, 'sstreet11', 'ahelleckas11@fotki.com', 'Sustainability-First', 'Male', '141.159.72.150');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (39, 'osavatier12', 'ajelf12@sfgate.com', 'NPO-First', 'Female', '165.80.100.106');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (40, 'pgelland13', 'sspurrier13@ft.com', 'Sustainability-First', 'Male', '78.100.36.214');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (41, 'sosgood14', 'nmasters14@vimeo.com', 'Local-Only', 'Female', '237.26.187.143');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (42, 'balderman15', 'mmccaghan15@1und1.de', 'Sustainability-First', 'Female', '102.106.239.85');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (43, 'aforestel16', 'ptutchener16@ibm.com', 'Price-First', 'Non-binary', '227.158.146.100');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (44, 'flowey17', 'yblacket17@photobucket.com', 'NPO-First', 'Male', '193.224.219.216');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (45, 'vderell18', 'acomsty18@gnu.org', 'NPO-First', 'Male', '116.197.76.65');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (46, 'kinker19', 'mzmitrovich19@qq.com', 'Price-First', 'Female', '196.51.154.215');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (47, 'mglasbey1a', 'drudeforth1a@opensource.org', 'Sustainability-First', 'Polygender', '149.105.159.144');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (48, 'asimonnot1b', 'onaris1b@dyndns.org', 'Price-First', 'Male', '193.40.13.101');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (49, 'chorribine1c', 'araine1c@sina.com.cn', 'Sustainability-First', 'Male', '59.106.155.161');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (50, 'krubertis1d', 'ldillway1d@auda.org.au', 'NPO-First', 'Male', '77.183.225.123');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (51, 'cgrishanov1e', 'tcornill1e@usa.gov', 'NPO-First', 'Agender', '236.202.124.233');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (52, 'nwildsmith1f', 'nmadison1f@newsvine.com', 'Price-First', 'Male', '213.190.28.105');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (53, 'dmurcott1g', 'rmarvelley1g@miibeian.gov.cn', 'Sustainability-First', 'Male', '47.77.196.100');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (54, 'hscarratt1h', 'tgeorgiades1h@cpanel.net', 'Price-First', 'Female', '196.187.135.140');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (55, 'dsparke1i', 'bstanislaw1i@soundcloud.com', 'Price-First', 'Female', '42.119.181.1');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (56, 'awyrall1j', 'cdesesquelle1j@fc2.com', 'Sustainability-First', 'Male', '11.75.104.121');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (57, 'omongin1k', 'sbumpass1k@printfriendly.com', 'Price-First', 'Male', '202.75.243.133');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (58, 'mmitchelhill1l', 'astaff1l@exblog.jp', 'Local-Only', 'Female', '250.226.150.4');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (59, 'yconachie1m', 'scarlsson1m@wikimedia.org', 'Price-First', 'Male', '180.152.123.236');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (60, 'apulham1n', 'gwoollcott1n@vistaprint.com', 'Price-First', 'Female', '50.134.245.42');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (61, 'tbaildon1o', 'gillesley1o@vk.com', 'NPO-First', 'Male', '107.7.247.140');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (62, 'qmosdell1p', 'gveschambes1p@ted.com', 'Sustainability-First', 'Polygender', '181.38.32.223');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (63, 'eglasscoe1q', 'anewman1q@scientificamerican.com', 'Sustainability-First', 'Female', '78.128.57.46');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (64, 'ttheseira1r', 'efeltham1r@unc.edu', 'Local-Only', 'Male', '128.250.241.196');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (65, 'lkenaway1s', 'emacpadene1s@ebay.com', 'Sustainability-First', 'Male', '51.30.146.197');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (66, 'btrownson1t', 'anern1t@cisco.com', 'Price-First', 'Male', '115.218.39.99');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (67, 'ckuhnert1u', 'qmoakler1u@auda.org.au', 'NPO-First', 'Female', '12.37.233.231');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (68, 'ggillebride1v', 'tscorthorne1v@theatlantic.com', 'Price-First', 'Female', '109.59.101.110');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (69, 'bstribling1w', 'galsford1w@privacy.gov.au', 'Price-First', 'Genderqueer', '133.66.249.91');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (70, 'ealejo1x', 'tdane1x@free.fr', 'Sustainability-First', 'Female', '105.72.136.144');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (71, 'jfranscioni1y', 'mgumly1y@nhs.uk', 'NPO-First', 'Female', '171.144.142.154');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (72, 'rpreon1z', 'jairs1z@mayoclinic.com', 'NPO-First', 'Female', '235.180.168.190');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (73, 'lvalentetti20', 'torred20@1688.com', 'Price-First', 'Male', '35.17.78.179');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (74, 'ylakin21', 'bleethem21@spotify.com', 'Local-Only', 'Female', '37.97.58.172');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (75, 'vcordrey22', 'mspriggs22@people.com.cn', 'NPO-First', 'Male', '84.54.70.162');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (76, 'llugard23', 'bbambury23@reddit.com', 'Local-Only', 'Female', '169.198.200.170');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (77, 'mmartinon24', 'ransett24@ucsd.edu', 'Local-Only', 'Female', '69.115.192.170');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (78, 'ekleiner25', 'apuckham25@admin.ch', 'Sustainability-First', 'Male', '255.198.158.162');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (79, 'aeades26', 'mhassett26@wikipedia.org', 'Local-Only', 'Male', '102.229.157.165');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (80, 'lclaisse27', 'kreiners27@com.com', 'Sustainability-First', 'Female', '158.220.153.225');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (81, 'hdomico28', 'dhannant28@ox.ac.uk', 'NPO-First', 'Male', '217.209.189.100');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (82, 'amacon29', 'tlayzell29@bluehost.com', 'Price-First', 'Female', '240.101.36.252');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (83, 'arawsthorne2a', 'amcleese2a@yahoo.com', 'NPO-First', 'Female', '102.128.147.216');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (84, 'rpercival2b', 'cmalt2b@zimbio.com', 'Sustainability-First', 'Male', '185.11.200.211');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (85, 'orolfi2c', 'pwallsam2c@google.co.uk', 'Local-Only', 'Male', '84.119.195.177');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (86, 'samesbury2d', 'dthireau2d@ucsd.edu', 'Local-Only', 'Female', '140.62.193.106');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (87, 'aeastmead2e', 'mmcilwrick2e@google.com', 'Sustainability-First', 'Male', '150.163.76.182');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (88, 'mkeneleyside2f', 'wpipping2f@bigcartel.com', 'Price-First', 'Female', '125.95.60.26');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (89, 'ctynemouth2g', 'pnuttey2g@nydailynews.com', 'NPO-First', 'Female', '223.255.11.17');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (90, 'cbuswell2h', 'gdemaria2h@nymag.com', 'Sustainability-First', 'Female', '26.43.16.115');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (91, 'amcgruar2i', 'ggresly2i@histats.com', 'Price-First', 'Female', '179.134.197.223');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (92, 'dpersehouse2j', 'osimek2j@4shared.com', 'Price-First', 'Female', '212.72.123.130');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (93, 'mdenty2k', 'hbransden2k@nytimes.com', 'Price-First', 'Female', '192.55.102.248');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (94, 'malbury2l', 'rturpie2l@java.com', 'NPO-First', 'Male', '115.119.83.151');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (95, 'ddefau2m', 'rsalsbury2m@bloomberg.com', 'Sustainability-First', 'Female', '173.79.41.43');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (96, 'jtrussell2n', 'vgrieves2n@toplist.cz', 'Local-Only', 'Female', '213.93.149.58');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (97, 'afasse2o', 'ezylbermann2o@huffingtonpost.com', 'NPO-First', 'Male', '24.61.226.19');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (98, 'mdezamudio2p', 'rcorradino2p@wikipedia.org', 'Local-Only', 'Female', '72.139.0.100');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (99, 'svanstone2q', 'kmacallam2q@hexun.com', 'Price-First', 'Male', '201.172.22.119');
insert into users (user_id, user_name, email, impact_preference , gender, ip_address) values (100, 'jcaswall2r', 'abendson2r@gov.uk', 'Sustainability-First', 'Female', '3.39.13.30');


SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM Users));




-- The "Ethical Savings" Insight
--This query finds products from NPO Partners 
--that are actually cheaper than the average market price.
--This proves you don't have to spend more to be ethical.

SELECT 
    p.product_name, 
    v.vendor_name, 
    ph.recorded_price,
    ROUND(AVG(ph.recorded_price) OVER(PARTITION BY p.product_id), 2) as avg_market_price
FROM Price_History ph
JOIN Price_Listing pl ON ph.listing_id = pl.listing_id
JOIN Product p ON pl.product_id = p.product_id
JOIN Vendor v ON pl.vendor_id = v.vendor_id
WHERE v.is_npo_partner = TRUE
ORDER BY ph.recorded_price ASC;

--2. The "Local Hero" Analysis
--This query identifies the top-rated local vendors in the East Bay/San Jose region based on their sustainability scores.

SELECT 
    vendor_name, 
    location_type, 
    sustainability_score
FROM Vendor
WHERE location_type = 'Local' 
AND sustainability_score > 85
ORDER BY sustainability_score DESC;

--3. The User Engagement Summary
--This provides a breakdown of what your 100 users actually care about, which helps with "Target Stakeholder" reporting.

SELECT 
    impact_preference, 
    COUNT(*) as total_users,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Users), 1) as percentage
FROM Users
GROUP BY impact_preference
ORDER BY total_users DESC;


--streamlit

CREATE OR REPLACE VIEW dashboard_main_metrics AS
SELECT 
    p.product_name,
    p.brand,
    c.category_name,
    v.vendor_name,
    v.sustainability_score,
    v.is_npo_partner,
    v.location_type, -- This was the missing piece!
    ph.recorded_price AS current_price,
    ph.recorded_at AS last_updated
FROM Product p
JOIN Category c ON p.category_id = c.category_id
JOIN Price_Listing pl ON p.product_id = pl.product_id
JOIN Vendor v ON pl.vendor_id = v.vendor_id
JOIN (
    SELECT listing_id, recorded_price, recorded_at,
           ROW_NUMBER() OVER(PARTITION BY listing_id ORDER BY recorded_at DESC) as rn
    FROM Price_History
) ph ON pl.listing_id = ph.listing_id
WHERE ph.rn = 1;

--
SELECT * FROM dashboard_main_metrics;


--analysing user preference 

CREATE OR REPLACE VIEW user_preference_summary AS
SELECT 
    impact_preference, 
    COUNT(*) as total_users,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Users), 2) as percentage
FROM Users
GROUP BY impact_preference
ORDER BY total_users DESC;


-- 1. The SQL View (The Logic)
--First, run this in pgAdmin to create the "Impact Gap" logic. This calculates the average price difference between NPO partners and regular vendors.

CREATE OR REPLACE VIEW npo_impact_gap AS
SELECT 
    v.is_npo_partner,
    ROUND(AVG(ph.recorded_price), 2) as avg_price
FROM Vendor v
JOIN Price_Listing pl ON v.vendor_id = pl.vendor_id
JOIN Price_History ph ON pl.listing_id = ph.listing_id
GROUP BY v.is_npo_partner;


-- fix 

-- 1. Create the User Summary View
CREATE OR REPLACE VIEW user_preference_summary AS
SELECT 
    impact_preference, 
    COUNT(*) as total_users,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Users), 2) as percentage
FROM Users
GROUP BY impact_preference
ORDER BY total_users DESC;

-- 2. Create the NPO Gap View
CREATE OR REPLACE VIEW npo_impact_gap AS
SELECT 
    v.is_npo_partner,
    ROUND(AVG(ph.recorded_price), 2) as avg_price
FROM Vendor v
JOIN Price_Listing pl ON v.vendor_id = pl.vendor_id
JOIN Price_History ph ON pl.listing_id = ph.listing_id
GROUP BY v.is_npo_partner;

--STEP 5: Create your views for the Streamlit dashboard
CREATE OR REPLACE VIEW user_preference_summary AS
SELECT 
    impact_preference, 
    COUNT(*) as total_users,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Users), 2) as percentage
FROM Users
GROUP BY impact_preference
ORDER BY total_users DESC;
