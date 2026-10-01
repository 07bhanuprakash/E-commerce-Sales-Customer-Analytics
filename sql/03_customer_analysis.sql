-- 1. Total Unique Customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM olist_customers_dataset;

-- 2. Number of Orders per Unique Customer
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

-- 3. One-Time vs. Repeat Customers
with customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_order_counts
GROUP BY customer_type;

-- 4. Repeat Customer Rate
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    INNER JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percentage
FROM customer_order_counts;
-- 5. Top 10 Customers by Revenue
SELECT
    c.customer_unique_id,
    ROUND(SUM(i.price), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset i
    ON o.order_id = i.order_id
GROUP BY c.customer_unique_id
ORDER BY total_revenue DESC
LIMIT 10;

-- 6. Monthly New Customers
WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE(o.order_purchase_timestamp)) AS first_purchase_date
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    DATE_FORMAT(first_purchase_date, '%Y-%m') AS purchase_month,
    COUNT(*) AS new_customers
FROM customer_first_purchase
GROUP BY DATE_FORMAT(first_purchase_date, '%Y-%m')
ORDER BY purchase_month;

-- 7. Customer Revenue by State
SELECT
    c.customer_state,
    ROUND(SUM(i.price), 2) AS total_revenue,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset i
    ON o.order_id = i.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;
