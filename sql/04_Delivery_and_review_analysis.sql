-- ============================================================
-- SECTION 1: DELIVERY ANALYSIS
-- ============================================================

-- 1. Average Delivery Time by Year

SELECT
    YEAR(order_purchase_timestamp) AS purchase_year,
    ROUND(
        AVG(DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )),
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY purchase_year;


-- 2. Late Delivery Rate by Year

WITH delivery_status AS (
    SELECT
        YEAR(order_purchase_timestamp) AS purchase_year,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On Time'
        END AS delivery_status
    FROM olist_orders_dataset
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_status = 'delivered'
)
SELECT
    purchase_year,
    COUNT(*) AS total_delivered_orders,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate_percentage
FROM delivery_status
GROUP BY purchase_year
ORDER BY purchase_year;


-- ============================================================
-- SECTION 2: CUSTOMER REVIEW ANALYSIS
-- ============================================================

-- 3. Distribution of Review Scores

SELECT
    review_score,
    COUNT(*) AS score_distribution
FROM stg_orders_review
GROUP BY review_score
ORDER BY review_score DESC;


-- 4. Overall Average Customer Review Score

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM stg_orders_review;


-- 5. Average Review Score by Delivery Status

-- Restrict to delivered orders with valid delivery dates.

SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(*) AS review_count
FROM olist_orders_dataset o
JOIN stg_orders_review r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;
