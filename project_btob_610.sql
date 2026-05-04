-- EthiTrack B2B Procurement Database Setup
-- Run this full script in PostgreSQL before starting the Streamlit app.

-- CLEAN RESET
DROP VIEW IF EXISTS view_price_volatility CASCADE;
DROP VIEW IF EXISTS view_npo_substitution_opportunities CASCADE;
DROP VIEW IF EXISTS view_supply_chain_risk CASCADE;
DROP VIEW IF EXISTS view_efficiency_leaders CASCADE;
DROP VIEW IF EXISTS dashboard_main_metrics CASCADE;
DROP VIEW IF EXISTS view_procurement_analytics CASCADE;
DROP VIEW IF EXISTS npo_impact_gap CASCADE;

DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Price_History CASCADE;
DROP TABLE IF EXISTS Price_Listing CASCADE;
DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS Vendor CASCADE;
DROP TABLE IF EXISTS Category CASCADE;

-- TABLES
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Vendor (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(150) NOT NULL,
    is_npo_partner BOOLEAN DEFAULT FALSE,
    location_type VARCHAR(50) CHECK (location_type IN ('Local', 'Online')),
    sustainability_score INT CHECK (sustainability_score BETWEEN 0 AND 100),
    certification_status VARCHAR(100),
    lead_time_days INT CHECK (lead_time_days >= 0),
    social_impact_category VARCHAR(100)
);

CREATE TABLE Product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    brand VARCHAR(100),
    category_id INT NOT NULL REFERENCES Category(category_id)
);

CREATE TABLE Price_Listing (
    listing_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES Product(product_id),
    vendor_id INT NOT NULL REFERENCES Vendor(vendor_id),
    current_stock_status VARCHAR(50)
);

CREATE TABLE Price_History (
    history_id SERIAL PRIMARY KEY,
    listing_id INT NOT NULL REFERENCES Price_Listing(listing_id),
    recorded_price DECIMAL(10,2) CHECK (recorded_price > 0),
    recorded_at TIMESTAMP NOT NULL
);

-- CATEGORIES
INSERT INTO Category (category_name) VALUES
('Fair Trade Coffee'),
('Ethical Apparel'),
('Organic Produce'),
('Reusable Goods'),
('Eco Cleaning');

-- PROCUREMENT-FOCUSED VENDORS
INSERT INTO Vendor
(vendor_name, is_npo_partner, location_type, sustainability_score, certification_status, lead_time_days, social_impact_category)
VALUES
('East Bay Community Garden', TRUE, 'Local', 95, 'USDA Organic, B-Corp', 3, 'Food Security'),
('San Jose Ethical Apparel', FALSE, 'Local', 82, 'Fair Trade', 5, 'Worker Equity'),
('Global Fair Trade Hub', TRUE, 'Online', 88, 'Fair Trade, Rainforest Alliance', 10, 'Smallholder Farmers'),
('The Sustainable Pantry', TRUE, 'Local', 91, 'USDA Organic', 2, 'Youth Education'),
('Hayward Eco-Refill Station', FALSE, 'Local', 75, 'B-Corp', 1, 'Waste Reduction'),
('Oakland Artisan Collective', TRUE, 'Local', 89, 'Fair Trade, B-Corp', 4, 'Local Arts & Jobs'),
('Green-Tech Solutions', FALSE, 'Online', 65, NULL, 7, 'Clean Energy'),
('Thrift & Thrive NPO', TRUE, 'Local', 98, 'B-Corp, Thrift Certified', 2, 'Reforestation'),
('Pacific Organic Co-op', FALSE, 'Local', 84, 'USDA Organic', 3, 'Regenerative Farming'),
('Kindness Coffee Project', TRUE, 'Online', 93, 'Fair Trade, Rainforest Alliance', 8, 'Women Empowerment'),
('Bay Area Responsible Supply', FALSE, 'Local', 87, 'B-Corp', 4, 'Responsible Sourcing'),
('Community Roots Wholesale', TRUE, 'Local', 90, 'USDA Organic, Fair Trade', 3, 'Community Development');

-- PRODUCTS
INSERT INTO Product (product_name, brand, category_id) VALUES
('Dark Roast Whole Bean', 'Kindness Coffee', 1),
('Hemp Blend T-Shirt', 'Eco-Threads', 2),
('Organic Tomatoes', 'East Bay Farms', 3),
('Single Origin Espresso', 'Fair-Trade Roasts', 1),
('Recycled Cotton Tote', 'Oakland Collective', 4);

-- MULTIPLE VENDORS PER PRODUCT
INSERT INTO Price_Listing (product_id, vendor_id, current_stock_status) VALUES
(1, 10, 'In Stock'),
(1, 3, 'In Stock'),
(1, 4, 'In Stock'),
(1, 11, 'In Stock'),
(2, 2, 'In Stock'),
(2, 6, 'In Stock'),
(2, 8, 'Limited Stock'),
(2, 11, 'In Stock'),
(3, 1, 'In Stock'),
(3, 4, 'In Stock'),
(3, 9, 'In Stock'),
(3, 12, 'In Stock'),
(4, 10, 'In Stock'),
(4, 3, 'In Stock'),
(4, 11, 'In Stock'),
(4, 4, 'Limited Stock'),
(5, 6, 'In Stock'),
(5, 8, 'In Stock'),
(5, 2, 'In Stock'),
(5, 5, 'Limited Stock');

-- PRICE HISTORY
WITH base_prices(listing_id, base_price) AS (
    VALUES
    (1, 44.00), (2, 42.50), (3, 46.00), (4, 43.25),
    (5, 39.00), (6, 41.50), (7, 38.75), (8, 40.25),
    (9, 10.50), (10, 11.25), (11, 10.00), (12, 10.75),
    (13, 35.50), (14, 34.25), (15, 36.00), (16, 37.25),
    (17, 15.00), (18, 14.50), (19, 16.25), (20, 13.75)
),
price_dates(recorded_at, multiplier) AS (
    VALUES
    ('2026-01-15 10:00:00'::timestamp, 0.98),
    ('2026-02-15 10:00:00'::timestamp, 1.01),
    ('2026-03-15 10:00:00'::timestamp, 1.00),
    ('2026-04-22 10:00:00'::timestamp, 1.03)
)
INSERT INTO Price_History (listing_id, recorded_price, recorded_at)
SELECT
    bp.listing_id,
    ROUND((bp.base_price * pd.multiplier)::numeric, 2),
    pd.recorded_at
FROM base_prices bp
CROSS JOIN price_dates pd
ORDER BY bp.listing_id, pd.recorded_at;

-- VIEW 1: MAIN DASHBOARD DATA
CREATE OR REPLACE VIEW dashboard_main_metrics AS
WITH latest_price AS (
    SELECT
        listing_id,
        recorded_price,
        recorded_at,
        ROW_NUMBER() OVER (
            PARTITION BY listing_id
            ORDER BY recorded_at DESC
        ) AS rn
    FROM Price_History
)
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    v.vendor_id,
    v.vendor_name,
    v.sustainability_score,
    v.is_npo_partner,
    v.location_type,
    v.certification_status,
    v.lead_time_days,
    v.social_impact_category,
    pl.current_stock_status,
    lp.recorded_price AS current_price,
    lp.recorded_at AS last_updated
FROM Product p
JOIN Category c ON p.category_id = c.category_id
JOIN Price_Listing pl ON p.product_id = pl.product_id
JOIN Vendor v ON pl.vendor_id = v.vendor_id
JOIN latest_price lp ON pl.listing_id = lp.listing_id AND lp.rn = 1;

-- VIEW 2: PROCUREMENT ANALYTICS
CREATE OR REPLACE VIEW view_procurement_analytics AS
WITH latest_price AS (
    SELECT
        listing_id,
        recorded_price,
        recorded_at,
        ROW_NUMBER() OVER (
            PARTITION BY listing_id
            ORDER BY recorded_at DESC
        ) AS rn
    FROM Price_History
),
market_avg AS (
    SELECT
        pl.product_id,
        ROUND(AVG(ph.recorded_price), 2) AS avg_market_price
    FROM Price_Listing pl
    JOIN Price_History ph ON pl.listing_id = ph.listing_id
    GROUP BY pl.product_id
)
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    v.vendor_id,
    v.vendor_name,
    v.is_npo_partner,
    v.location_type,
    v.sustainability_score,
    v.certification_status,
    v.lead_time_days,
    v.social_impact_category,
    pl.current_stock_status,
    lp.recorded_price AS current_price,
    ma.avg_market_price,
    ROUND(
        (v.sustainability_score * 0.40)
        + CASE WHEN v.location_type = 'Local' THEN 15 ELSE 0 END
        + CASE WHEN v.is_npo_partner = TRUE THEN 15 ELSE 0 END
        + CASE WHEN v.certification_status IS NOT NULL THEN 10 ELSE 0 END
        + CASE
            WHEN v.lead_time_days <= 2 THEN 10
            WHEN v.lead_time_days <= 5 THEN 7
            WHEN v.lead_time_days <= 8 THEN 4
            ELSE 1
          END
        + CASE
            WHEN lp.recorded_price <= ma.avg_market_price THEN 10
            ELSE GREATEST(
                0,
                10 - (((lp.recorded_price - ma.avg_market_price) / ma.avg_market_price) * 20)
            )
          END,
        2
    ) AS supplier_fit_score,
    CASE
        WHEN v.location_type = 'Local' THEN 120
        ELSE 0
    END AS annual_co2_saved_kg_per_1000_units,
    CASE
        WHEN v.is_npo_partner = TRUE THEN 5000
        ELSE 1000
    END AS community_impact_per_1000_units
FROM Price_Listing pl
JOIN Product p ON pl.product_id = p.product_id
JOIN Category c ON p.category_id = c.category_id
JOIN Vendor v ON pl.vendor_id = v.vendor_id
JOIN latest_price lp ON pl.listing_id = lp.listing_id AND lp.rn = 1
JOIN market_avg ma ON p.product_id = ma.product_id;

-- VIEW 3: NPO VS COMMERCIAL GAP
CREATE OR REPLACE VIEW npo_impact_gap AS
SELECT
    is_npo_partner,
    COUNT(*) AS supplier_options,
    ROUND(AVG(current_price), 2) AS avg_current_price,
    ROUND(AVG(sustainability_score), 1) AS avg_sustainability_score,
    ROUND(AVG(lead_time_days), 1) AS avg_lead_time_days
FROM dashboard_main_metrics
GROUP BY is_npo_partner;

-- OPTIONAL ANALYSIS VIEW 1: IMPACT-COST CONFLICT
CREATE OR REPLACE VIEW view_efficiency_leaders AS
WITH latest_price AS (
    SELECT
        listing_id,
        recorded_price,
        ROW_NUMBER() OVER (
            PARTITION BY listing_id
            ORDER BY recorded_at DESC
        ) AS rn
    FROM Price_History
),
latest_supplier_prices AS (
    SELECT
        p.product_id,
        p.product_name,
        v.vendor_name,
        v.sustainability_score,
        lp.recorded_price,
        AVG(lp.recorded_price) OVER (PARTITION BY p.product_id) AS product_avg_price
    FROM Product p
    JOIN Price_Listing pl ON p.product_id = pl.product_id
    JOIN Vendor v ON pl.vendor_id = v.vendor_id
    JOIN latest_price lp ON pl.listing_id = lp.listing_id AND lp.rn = 1
)
SELECT
    product_name,
    vendor_name,
    sustainability_score,
    recorded_price,
    ROUND(product_avg_price - recorded_price, 2) AS savings_vs_avg
FROM latest_supplier_prices
WHERE sustainability_score > (SELECT AVG(sustainability_score) FROM Vendor)
  AND recorded_price < product_avg_price;

-- OPTIONAL ANALYSIS VIEW 2: SUPPLY CHAIN RELIABILITY RISK
CREATE OR REPLACE VIEW view_supply_chain_risk AS
SELECT
    social_impact_category,
    COUNT(vendor_id) AS vendor_count,
    ROUND(AVG(lead_time_days), 1) AS avg_lead_time,
    SUM(CASE WHEN lead_time_days > 5 THEN 1 ELSE 0 END) AS slow_vendor_count,
    ROUND(
        (SUM(CASE WHEN lead_time_days > 5 THEN 1 ELSE 0 END)::NUMERIC / COUNT(vendor_id)) * 100,
        1
    ) AS percent_at_risk
FROM Vendor
GROUP BY social_impact_category;

-- OPTIONAL ANALYSIS VIEW 3: NPO SUBSTITUTION OPPORTUNITIES
CREATE OR REPLACE VIEW view_npo_substitution_opportunities AS
SELECT
    p.product_name,
    v_comm.vendor_name AS current_commercial_source,
    v_npo.vendor_name AS suggested_npo_alternative,
    v_npo.social_impact_category,
    v_npo.sustainability_score AS potential_score_boost
FROM Product p
JOIN Price_Listing pl1 ON p.product_id = pl1.product_id
JOIN Vendor v_comm ON pl1.vendor_id = v_comm.vendor_id
JOIN Price_Listing pl2 ON p.product_id = pl2.product_id
JOIN Vendor v_npo ON pl2.vendor_id = v_npo.vendor_id
WHERE v_comm.is_npo_partner = FALSE
  AND v_npo.is_npo_partner = TRUE
  AND v_comm.vendor_id <> v_npo.vendor_id;

-- OPTIONAL ANALYSIS VIEW 4: PRICE VOLATILITY
CREATE OR REPLACE VIEW view_price_volatility AS
SELECT
    v.vendor_name,
    p.product_name,
    ROUND(AVG(ph.recorded_price), 2) AS average_price,
    ROUND(STDDEV(ph.recorded_price), 2) AS price_volatility_index,
    COUNT(ph.history_id) AS price_change_events
FROM Vendor v
JOIN Price_Listing pl ON v.vendor_id = pl.vendor_id
JOIN Product p ON pl.product_id = p.product_id
JOIN Price_History ph ON pl.listing_id = ph.listing_id
GROUP BY v.vendor_name, p.product_name
HAVING COUNT(ph.history_id) > 1;
