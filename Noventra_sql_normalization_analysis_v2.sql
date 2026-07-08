
-- ============================================================
-- Noventra E-Commerce | SQL Normalization & Analysis
-- ============================================================

-- ============================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================

CREATE DATABASE Noventra_Ecommerce_;
USE Noventra_Ecommerce_;

-- ============================================================
-- SECTION 2: RAW DATA TABLE (Unnormalized staging layer)
-- ============================================================

CREATE TABLE store_data
(
    order_id       VARCHAR(50),
    order_date     DATE,
    ship_date      DATE,
    ship_mode      VARCHAR(100),
    customer_name  VARCHAR(200),
    segment        VARCHAR(100),
    customer_age   INT,
    state          VARCHAR(200),
    country        VARCHAR(200),
    market         VARCHAR(200),
    region         VARCHAR(200),
    category       VARCHAR(200),
    sub_category   VARCHAR(200),
    product_name   VARCHAR(255),
    unit_price     VARCHAR(50), 
    quantity       VARCHAR(50),
    discount       VARCHAR(50),   
    order_priority VARCHAR(50)
);

-- ============================================================
-- SECTION 3: BULK INSERT
-- ============================================================

set dateformat dmy;

BULK INSERT store_data
FROM 'C:\Users\Aditya\Desktop\SuperStoreOrders - SuperStoreOrders 3.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    MAXERRORS       = 1000,
    TABLOCK
);

-- ============================================================
-- SECTION 4: DATA QUALITY CHECK
-- (Secondary null validation after Excel cleaning)
-- ============================================================

SELECT
    SUM(CASE WHEN order_id       IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_date     IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN ship_date      IS NULL THEN 1 ELSE 0 END) AS ship_date_nulls,
    SUM(CASE WHEN ship_mode      IS NULL THEN 1 ELSE 0 END) AS ship_mode_nulls,
    SUM(CASE WHEN customer_name  IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN segment        IS NULL THEN 1 ELSE 0 END) AS segment_nulls,
    SUM(CASE WHEN customer_age   IS NULL THEN 1 ELSE 0 END) AS customer_age_nulls,
    SUM(CASE WHEN state          IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN country        IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN market         IS NULL THEN 1 ELSE 0 END) AS market_nulls,
    SUM(CASE WHEN region         IS NULL THEN 1 ELSE 0 END) AS region_nulls,
    SUM(CASE WHEN category       IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN sub_category   IS NULL THEN 1 ELSE 0 END) AS sub_category_nulls,
    SUM(CASE WHEN product_name   IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN unit_price     IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
    SUM(CASE WHEN quantity       IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN discount       IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
    SUM(CASE WHEN order_priority IS NULL THEN 1 ELSE 0 END) AS order_priority_nulls
FROM store_data;

SELECT * FROM store_data;

-- ============================================================
-- SECTION 5: NORMALIZED DIMENSION & FACT TABLES (3NF)
-- ============================================================

-- Customers dimension

CREATE TABLE customers
(
    customer_id      INT IDENTITY(10001,1) PRIMARY KEY,
    customer_name    VARCHAR(50),
    customer_segment VARCHAR(20),
    customer_age     INT
);

-- Products dimension

CREATE TABLE products
(
    product_id          INT IDENTITY(50001,1) PRIMARY KEY,
    product_name        VARCHAR(200),
    product_subcategory VARCHAR(30),
    product_category    VARCHAR(30)
);

-- Locations dimension

CREATE TABLE locations
(
    location_id INT IDENTITY(1234,1) PRIMARY KEY,
    region      VARCHAR(80),
    country     VARCHAR(80),
    state       VARCHAR(80),
    market      VARCHAR(80)
);

-- Dates dimension

CREATE TABLE dates
(
    date_value   DATE PRIMARY KEY,
    year         INT,
    quarter      VARCHAR(2),
    month_name   VARCHAR(20),
    month_number INT,
    day_name     VARCHAR(20),
    day_number   INT
);

-- Orders fact table

CREATE TABLE orders
(
    order_line_id  INT IDENTITY(1,1) PRIMARY KEY, -- surrogate PK; order_id repeats across line items
    order_id       VARCHAR(20),
    order_date     DATE,
    ship_date      DATE,
    delivery_days  INT,
    ship_mode      VARCHAR(20),
    order_priority VARCHAR(20),
    customer_id    INT,
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    product_id INT,
        FOREIGN KEY (product_id)  REFERENCES products(product_id),
    location_id INT,
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
    unit_price     DECIMAL(10,2), 
    quantity       INT,
    discount       DECIMAL(5,4),  
    revenue        DECIMAL(12,2)  -- unit_price * quantity * (1 - discount)
);

-- ============================================================
-- SECTION 6: POPULATE NORMALIZED TABLES FROM RAW DATA
-- ============================================================

-- Products
INSERT INTO products (product_name, product_subcategory, product_category)
SELECT DISTINCT product_name, sub_category, category
FROM store_data;

-- Customers
INSERT INTO customers (customer_name, customer_segment, customer_age)
SELECT DISTINCT customer_name, segment, customer_age
FROM store_data;

-- Locations
INSERT INTO locations (region, country, state, market)
SELECT DISTINCT region, country, state, market
FROM store_data;

-- Dates: generate one row per calendar day for the dataset range (2011-2014)
DECLARE @StartDate DATE = '2011-01-01';
DECLARE @EndDate   DATE = '2014-12-31';
WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dates (date_value) VALUES (@StartDate);
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;

UPDATE dates
SET
    year         = YEAR(date_value),
    month_number = MONTH(date_value),
    month_name   = DATENAME(MONTH,   date_value),
    quarter      = CONCAT('Q', DATEPART(QUARTER, date_value)),
    day_number   = DAY(date_value),
    day_name     = DATENAME(WEEKDAY, date_value);

-- Orders (fact): resolve FK lookups, clean discount, calculate revenue

INSERT INTO orders
(
    order_id, order_date, ship_date, delivery_days, ship_mode, order_priority,
    customer_id, product_id, location_id, unit_price, quantity, discount, revenue
)
SELECT
    sd.order_id,
    sd.order_date,
    sd.ship_date,
    DATEDIFF(DAY, sd.order_date, sd.ship_date) AS delivery_days,
    sd.ship_mode,
    sd.order_priority,
    c.customer_id,
    p.product_id,
    l.location_id,
    CAST(sd.unit_price AS DECIMAL(10,2)) AS unit_price,
    CAST(sd.quantity AS INT) AS quantity,
    CAST(REPLACE(sd.discount, '%', '') AS DECIMAL(5,2)) / 100 AS discount,
    CAST(sd.unit_price AS DECIMAL(10,2))
    * CAST(sd.quantity AS INT)
    * (1 - CAST(REPLACE(sd.discount, '%', '') AS DECIMAL(5,2)) / 100) AS revenue
FROM store_data AS sd
JOIN customers AS c
    ON  c.customer_name    = sd.customer_name
    AND c.customer_segment = sd.segment
    AND c.customer_age     = sd.customer_age
JOIN products AS p
    ON  p.product_name        = sd.product_name
    AND p.product_category    = sd.category
    AND p.product_subcategory = sd.sub_category
JOIN locations AS l
    ON  l.region  = sd.region
    AND l.country = sd.country
    AND l.state   = sd.state
    AND l.market  = sd.market;

-- Verification
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM locations;
SELECT * FROM dates;
SELECT * FROM orders;

-- ============================================================
-- SECTION 7: INDEXES FOR QUERY PERFORMANCE
-- ============================================================

CREATE INDEX idx_order_product_id  ON orders(product_id);
CREATE INDEX idx_order_customer_id ON orders(customer_id);
CREATE INDEX idx_order_location_id ON orders(location_id);
CREATE INDEX idx_order_order_date ON orders(order_date);   
CREATE INDEX idx_product_category ON products(product_category);
CREATE INDEX idx_region ON locations(region);    


-- Verify indexes

SELECT
    t.name  AS table_name,
    i.name  AS index_name,
    i.type_desc AS index_type,
    i.is_primary_key,
    i.is_unique
FROM sys.indexes AS i
JOIN sys.tables  AS t ON i.object_id = t.object_id
WHERE i.index_id > 0
ORDER BY t.name, i.name;

-- ============================================================
-- SECTION 8: ANALYTICAL VIEWS
-- ============================================================

-- View 1: Product Performance (Top 25 products by revenue)

CREATE VIEW vw_product_performance AS
WITH product_summary AS
(
    SELECT
        DENSE_RANK() OVER (ORDER BY SUM(o.revenue) DESC) AS product_rank,
        p.product_name,
        p.product_subcategory,
        p.product_category,
        SUM(o.quantity)               AS total_quantity_sold,
        FORMAT(SUM(o.revenue), 'N0')  AS total_revenue,
        COUNT(DISTINCT o.order_id)    AS total_orders_placed
    FROM products AS p
    JOIN orders   AS o ON p.product_id = o.product_id
    GROUP BY p.product_name, p.product_subcategory, p.product_category
)
SELECT * FROM product_summary
WHERE product_rank <= 25;

SELECT * FROM vw_product_performance;

-----------------------------------------------------------------

-- View 2: Customer Segment & Age Group Insights

CREATE VIEW vw_customer_segment_insights AS
WITH csi AS
(
    SELECT
        DENSE_RANK() OVER (ORDER BY SUM(o.revenue) DESC) AS segment_rank,
        c.customer_segment,
        CASE
            WHEN c.customer_age < 25 THEN 'Under 25 (Gen Z)'
            WHEN c.customer_age BETWEEN 25 AND 40 THEN '25-40 (Millennial)'
            WHEN c.customer_age BETWEEN 41 AND 60 THEN '41-60 (Gen X)'
            ELSE '60+ (Senior)'
        END AS age_group,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        FORMAT(SUM(o.revenue), 'N0') AS total_revenue,
        AVG(o.revenue) AS average_order_value
    FROM customers AS c
    JOIN orders    AS o ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_segment,
        CASE
            WHEN c.customer_age < 25 THEN 'Under 25 (Gen Z)'
            WHEN c.customer_age BETWEEN 25 AND 40 THEN '25-40 (Millennial)'
            WHEN c.customer_age BETWEEN 41 AND 60 THEN '41-60 (Gen X)'
            ELSE '60+ (Senior)'
        END
)
SELECT * FROM csi WHERE segment_rank <= 10;

SELECT * FROM vw_customer_segment_insights;

-----------------------------------------------------------------

-- View 3: Shipping & Logistics Efficiency

CREATE VIEW vw_shipping_logistics AS
WITH sl AS
(
    SELECT
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT order_id) DESC) AS rank,
        ship_mode,
        order_priority,
        AVG(delivery_days) AS average_delivery_days,
        MAX(delivery_days) AS max_delivery_days,
        FORMAT(COUNT(DISTINCT order_id), 'N0') AS total_shipments
    FROM orders
    GROUP BY ship_mode, order_priority
)
SELECT * FROM sl WHERE rank <= 10;

SELECT * FROM vw_shipping_logistics;

-----------------------------------------------------------------

-- View 4: Monthly Revenue with MoM Growth

CREATE VIEW vw_monthly_revenue AS
WITH monthly_analysis AS
(
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(o.revenue) AS total_revenue
    FROM dates  AS d
    JOIN orders AS o ON d.date_value = o.order_date
    GROUP BY d.year, d.month_number, d.month_name
)
SELECT
    year,
    month_name,
    total_revenue,
    ISNULL(LAG(total_revenue) OVER (ORDER BY year, month_number), 0) AS previous_month_revenue,
    ISNULL(CAST(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY year, month_number)) * 100.0)
        / NULLIF(LAG(total_revenue) OVER (ORDER BY year, month_number), 0)
    AS DECIMAL(10,2)), 0) AS [mom_growth_%]
FROM monthly_analysis;

-- Useing ORDER BY in querying the view (not allowed inside view definition in SQL Server)

SELECT * FROM vw_monthly_revenue ORDER BY year ;

-----------------------------------------------------------------

-- View 5: Yearly Revenue with YoY Growth

CREATE VIEW vw_yearly_revenue AS
WITH yearly_sales AS
(
    SELECT
        d.year,
        SUM(o.revenue) AS total_revenue
    FROM orders AS o
    JOIN dates  AS d ON o.order_date = d.date_value
    GROUP BY d.year
)
SELECT
    year,
    FORMAT(total_revenue, 'N0') AS total_revenue,
    ISNULL(FORMAT(LAG(total_revenue) OVER (ORDER BY year), 'N0'), '0') AS previous_year_revenue,
    CONCAT(ISNULL(CAST(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY year)) * 100.0)
        / NULLIF(LAG(total_revenue) OVER (ORDER BY year), 0)
    AS DECIMAL(10,2)), 0), '%') AS yoy_growth
FROM yearly_sales;

SELECT * FROM vw_yearly_revenue ORDER BY year;

-----------------------------------------------------------------

-- View 6: Customer Lifetime Value (CLV)

CREATE VIEW vw_customer_lifetime_value AS
WITH customer_clv AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.revenue) AS lifetime_value,
        AVG(o.revenue) AS average_order_value
    FROM customers AS c
    JOIN orders    AS o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment
)
SELECT
    DENSE_RANK() OVER (ORDER BY lifetime_value DESC) AS customer_rank,
    customer_name,
    customer_segment,
    total_orders,
    FORMAT(lifetime_value,'N0') AS lifetime_value,
    FORMAT(average_order_value, 'N0') AS average_order_value
FROM customer_clv;

SELECT * FROM vw_customer_lifetime_value ORDER BY customer_rank;

-----------------------------------------------------------------

-- View 7: Repeat Purchase Analysis by Segment

CREATE VIEW vw_repeat_purchase_analysis AS
WITH customer_counts AS
(
    SELECT
        o.customer_id,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders    AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_segment
)
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS single_buyers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
         AS DECIMAL(5,2)) AS [repeat_customer_rate_%]
FROM customer_counts
GROUP BY customer_segment;

SELECT * FROM vw_repeat_purchase_analysis ORDER BY [repeat_customer_rate_%] DESC;

-----------------------------------------------------------------

-- View 8: RFM Customer Segmentation.
-- Scoring logic (4 = best quartile, 1 = worst quartile):
--   R score: lower recency days = customer purchased recently = score 4
--   F score: higher order count = purchases more often     = score 4
--   M score: higher total spend = higher value customer    = score 4

CREATE VIEW vw_rfm_segmentation AS
WITH rfm_raw AS
(
    SELECT
        o.customer_id,
        c.customer_name,
        DATEDIFF(DAY, MAX(o.order_date), '2014-12-31') AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(o.revenue) AS monetary
    FROM orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
),
rfm_scores AS
(
    SELECT
        customer_id,
        customer_name,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency   ASC)  AS r_score, -- low recency days = recently active = 4
        NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary  DESC) AS m_score
    FROM rfm_raw
),
rfm_labelled AS
(
    SELECT *,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score = 4 AND f_score = 1 THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 1 THEN 'Hibernating'
            ELSE 'Regular Customers'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT * FROM rfm_labelled;

SELECT * FROM vw_rfm_segmentation ORDER BY monetary DESC;

-- ============================================================
-- SECTION 9: BUSINESS ANALYSIS QUERIES (Ad-hoc)
-- ============================================================

-- Executive KPI Summary

SELECT
    FORMAT(SUM(revenue),               'N0') AS aggregate_company_revenue,
    FORMAT(COUNT(DISTINCT order_id),   'N0') AS total_order_count,
    FORMAT(SUM(quantity),              'N0') AS gross_units_sold,
    FORMAT(COUNT(DISTINCT customer_id),'N0') AS unique_active_customers,
    FORMAT(AVG(revenue),               'N0') AS average_order_value,
    AVG(delivery_days)                        AS avg_days_to_ship
FROM orders;

-----------------------------------------------------------------

-- Shipping Delay Analysis

SELECT
    l.market,
    o.ship_mode,
    o.order_priority,
    COUNT(DISTINCT o.order_id) AS total_shipments,
    AVG(o.delivery_days) AS avg_days_to_ship,
    MAX(o.delivery_days) AS max_days_to_ship,
    SUM(CASE WHEN o.delivery_days > 5 THEN 1 ELSE 0 END) AS delayed_shipments_count,
    CAST(SUM(CASE WHEN o.delivery_days > 5 THEN 1 ELSE 0 END) * 100.0
         / COUNT(DISTINCT o.order_id) AS DECIMAL(10,2)) AS [delay_rate_%]
FROM orders    AS o
JOIN locations AS l ON o.location_id = l.location_id
GROUP BY l.market, o.ship_mode, o.order_priority
ORDER BY delayed_shipments_count DESC;

-----------------------------------------------------------------

-- Regional Growth Analysis (YoY by Market and Region)

WITH regional_sales AS
(
    SELECT
        l.market,
        l.region,
        d.year,
        SUM(o.revenue) AS revenue
    FROM orders    AS o
    JOIN locations AS l ON o.location_id = l.location_id
    JOIN dates     AS d ON o.order_date  = d.date_value
    GROUP BY l.market, l.region, d.year
)
SELECT
    market,
    region,
    year,
    FORMAT(revenue, 'N0') AS current_year_revenue,
    FORMAT(ISNULL(LAG(revenue) OVER (PARTITION BY market, region ORDER BY year), 0), 'N0') AS previous_year_revenue,
    CONCAT(ISNULL(CAST(
        ((revenue - LAG(revenue) OVER (PARTITION BY market, region ORDER BY year)) * 100.0)
        / NULLIF(LAG(revenue) OVER (PARTITION BY market, region ORDER BY year), 0)
    AS DECIMAL(10,2)), 0), '%') AS regional_yoy_growth
FROM regional_sales
ORDER BY regional_yoy_growth DESC;

-- ============================================================
-- SECTION 10: STORED PROCEDURES
-- ============================================================

-- Stored Procedure 1: Full order history for a given customer

CREATE PROCEDURE sp_customer_history
    @customer_id INT
AS
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        p.product_name,
        o.quantity,
        o.revenue
    FROM orders   AS o
    JOIN products AS p ON o.product_id = p.product_id
    WHERE o.customer_id = @customer_id
    ORDER BY o.order_date;
END;

EXEC sp_customer_history 10001;

-----------------------------------------------------------------

-- Stored Procedure 2: Sales summary between two dates

CREATE PROCEDURE sp_sales_between_dates
    @start_date DATE,
    @end_date   DATE
AS
BEGIN
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(revenue)             AS total_revenue,
        SUM(quantity)            AS total_quantity
    FROM orders
    WHERE order_date BETWEEN @start_date AND @end_date;
END;

EXEC sp_sales_between_dates '2012-01-01', '2012-12-31';

-----------------------------------------------------------------

-- Stored Procedure 3: Customer churn analysis

CREATE PROCEDURE sp_customer_churn_analysis
    @days INT
AS
BEGIN
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        MAX(o.order_date)                               AS last_order_date,
        DATEDIFF(DAY, MAX(o.order_date), '2014-12-31') AS days_since_last_order,
        SUM(o.revenue)                                  AS lifetime_revenue
    FROM customers AS c
    JOIN orders    AS o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment
    HAVING DATEDIFF(DAY, MAX(o.order_date), '2014-12-31') >= @days
    ORDER BY lifetime_revenue DESC;
END;

EXEC sp_customer_churn_analysis 90;

-- ============================================================
-- SECTION 11: AUDIT TABLE & TRIGGERS
-- ============================================================

--captures every INSERT, UPDATE, DELETE on the orders table

CREATE TABLE order_audit
(
    audit_id    INT IDENTITY(1,1) PRIMARY KEY,
    order_id    VARCHAR(20),
    action_type VARCHAR(10),
    action_date DATETIME DEFAULT GETDATE()
);

-- Insert trigger

CREATE TRIGGER trg_orders_insert ON orders
AFTER INSERT AS
BEGIN
    INSERT INTO order_audit (order_id, action_type)
    SELECT order_id, 'INSERT' FROM inserted;
END;

-- Update trigger

CREATE TRIGGER trg_orders_update ON orders
AFTER UPDATE AS
BEGIN
    INSERT INTO order_audit (order_id, action_type)
    SELECT order_id, 'UPDATE' FROM inserted;
END;

-- Delete trigger

CREATE TRIGGER trg_orders_delete ON orders
AFTER DELETE AS
BEGIN
    INSERT INTO order_audit (order_id, action_type)
    SELECT order_id, 'DELETE' FROM deleted;
END;

-- ============================================================
-- SECTION 12: TRIGGER VERIFICATION (Development only)
-- ============================================================

-- Test INSERT trigger

INSERT INTO orders
(order_id, order_date, ship_date, delivery_days, ship_mode, order_priority,
 product_id, location_id, customer_id, unit_price, quantity, discount, revenue)

VALUES
('TEST001', '2014-12-30', '2015-01-02', 3, 'Standard Class', 'Medium',
 50001, 1234, 10001, 100.00, 2, 0.0000, 200.00);

 ----------------------------------------------------------------------------

-- Test UPDATE trigger

UPDATE orders
SET revenue = 500.00
WHERE order_id = 'TEST001';

-----------------------------------------------------------------------------

-- Test DELETE trigger (also cleans up the test row from orders)

DELETE FROM orders
WHERE order_id = 'TEST001';

-----------------------------------------------------------------------------

-- Verify audit trail (expect exactly 3 rows: INSERT, UPDATE, DELETE)

SELECT * FROM order_audit;
