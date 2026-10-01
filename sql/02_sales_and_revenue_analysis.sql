-- 1. KPI: Total Revenue (in Millions)

SELECT
    CONCAT(ROUND(SUM(price) / 1000000, 2), ' M') AS revenue
FROM olist_order_items_dataset;


-- 2. KPI: Total Orders

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_order_items_dataset;


-- 3. KPI: Total Unique Customers

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset;


-- 4. KPI: Average Order Value (AOV)

SELECT
    ROUND(
        SUM(price) / COUNT(DISTINCT order_id),
        2
    ) AS AOV
FROM olist_order_items_dataset;


-- 5. Monthly Revenue Trend

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
    ROUND(SUM(i.price), 2) AS revenue
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o
    ON i.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY purchase_month;


-- 6. Month-over-Month Revenue Growth

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
        SUM(i.price) AS revenue
    FROM olist_order_items_dataset i
    JOIN olist_orders_dataset o
        ON i.order_id = o.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

revenue_comparison AS (
    SELECT
        purchase_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY purchase_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    purchase_month,
    ROUND(revenue, 2) AS current_month_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY purchase_month;


-- ============================================================
-- SECTION 2: PRODUCT CATEGORY ANALYSIS
-- ============================================================

-- 7. Top 5 Product Categories by Revenue

SELECT
    p.product_category_name,
    ROUND(SUM(i.price), 2) AS revenue
FROM olist_order_items_dataset i
JOIN stg_product p
    ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 5;


-- 8. Top 5 Product Categories by Number of Orders

SELECT
    p.product_category_name,
    COUNT(DISTINCT i.order_id) AS total_orders
FROM olist_order_items_dataset i
JOIN stg_product p
    ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC
LIMIT 5;


-- 9. Top 5 Individual Products by Revenue

SELECT
    i.product_id,
    ROUND(SUM(i.price), 2) AS revenue
FROM olist_order_items_dataset i
JOIN stg_product p
    ON i.product_id = p.product_id
GROUP BY i.product_id
ORDER BY revenue DESC
LIMIT 5;


-- 10. Top 10 Individual Products by Revenue

SELECT
    i.product_id,
    ROUND(SUM(i.price), 2) AS revenue
FROM olist_order_items_dataset i
JOIN stg_product p
    ON i.product_id = p.product_id
GROUP BY i.product_id
ORDER BY revenue DESC
LIMIT 10;
