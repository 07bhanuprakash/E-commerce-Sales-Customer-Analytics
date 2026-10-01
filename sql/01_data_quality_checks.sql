
-- ============================================================
-- PROJECT: E-Commerce Sales and Customer Analytics
-- DATABASE: Olist E-Commerce Dataset
-- FILE: Data Quality Checks and Validation
-- PURPOSE: Identify duplicates, NULL values, and
--          referential integrity issues.
-- ============================================================


-- ============================================================
-- 1. CUSTOMER DATA QUALITY CHECKS
-- ============================================================

-- Check duplicate customer_id values
SELECT customer_id, COUNT(*) AS duplicate_count
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check customers associated with multiple records
SELECT customer_unique_id, COUNT(*) AS record_count
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;

-- Check NULL customer_unique_id values
SELECT *
FROM olist_customers_dataset
WHERE customer_unique_id IS NULL; 

-- Check NULL customer_id values
SELECT *
FROM olist_customers_dataset
WHERE customer_id IS NULL;


-- ============================================================
-- 2. GEOLOCATION DATA VALIDATION
-- ============================================================

-- Inspect primary key information
SHOW KEYS FROM olist_geolocation_dataset
WHERE Key_name = 'PRIMARY';

-- Check the number of records per ZIP code prefix
SELECT geolocation_zip_code_prefix,
       COUNT(*) AS record_count
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix
ORDER BY record_count DESC;


-- ============================================================
-- 3. ORDER ITEMS DATA QUALITY CHECKS
-- ============================================================

-- Check sellers appearing in multiple order items
SELECT seller_id, COUNT(*) AS record_count
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Inspect primary key information
SHOW KEYS FROM olist_order_items_dataset
WHERE Key_name = 'PRIMARY';

-- Inspect indexes
SHOW INDEX FROM olist_order_items_dataset;


-- ============================================================
-- 4. PAYMENT DATA VALIDATION
-- ============================================================

-- Check orders with multiple payment records
SELECT order_id, COUNT(*) AS payment_count
FROM olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check NULL payment values
SELECT COUNT(*) AS null_payment_count
FROM olist_order_payments_dataset
WHERE payment_value IS NULL;

-- Inspect and remove an existing index, if required
-- Verify dependencies before executing this operation.
-- ALTER TABLE olist_order_payments_dataset
-- DROP INDEX payment_idx;


-- ============================================================
-- 5. ORDER REVIEW DATA QUALITY CHECKS
-- ============================================================

-- Check orders with multiple review records
SELECT order_id, COUNT(*) AS review_count
FROM olist_order_reviews_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check NULL review response timestamps
SELECT *
FROM olist_order_reviews_dataset
WHERE review_answer_timestamp IS NULL;

-- Review table structure:
-- review_id, order_id, review_score,
-- review_comment_title, review_comment_message,
-- review_creation_date, review_answer_timestamp


-- ============================================================
-- 6. ORDER DATA VALIDATION
-- ============================================================

-- Check customers associated with multiple orders
SELECT customer_id, COUNT(*) AS order_count
FROM olist_orders_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Inspect primary key information
SHOW KEYS FROM olist_orders_dataset
WHERE Key_name = 'PRIMARY';

-- Investigate missing timestamps by order status
SELECT
    order_status,
    COUNT(*) AS total_orders,
    COUNT(order_approved_at) AS approved_timestamp_count,
    COUNT(order_delivered_carrier_date) AS carrier_timestamp_count,
    COUNT(order_delivered_customer_date) AS delivered_timestamp_count
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY order_status;


-- ============================================================
-- 7. SELLER DATA QUALITY CHECKS
-- ============================================================

-- Check duplicate seller IDs
SELECT seller_id, COUNT(*) AS duplicate_count
FROM olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 8. PRODUCT CATEGORY TRANSLATION VALIDATION
-- ============================================================

-- Inspect product table structure
SHOW CREATE TABLE olist_products_dataset;

-- Inspect category translation table structure
SHOW CREATE TABLE product_category_name_translation;

-- Check duplicate category names in translation table
SELECT product_category_name, COUNT(*) AS duplicate_count
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- Check NULL category names in translation table
SELECT *
FROM product_category_name_translation
WHERE product_category_name IS NULL;

-- Count translation table records
SELECT COUNT(*) AS total_translation_records
FROM product_category_name_translation;

-- Count distinct non-NULL product categories
SELECT COUNT(DISTINCT product_category_name) AS distinct_categories
FROM olist_products_dataset
WHERE product_category_name IS NOT NULL;

-- Identify product categories without a translation
SELECT DISTINCT p.product_category_name
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- Investigate a category name
SELECT *
FROM product_category_name_translation
WHERE product_category_name LIKE '%portateis%';

-- Add a foreign key only after validating the data
-- and confirming the referenced column has a suitable key.
-- ALTER TABLE olist_products_dataset
-- ADD CONSTRAINT category_name_fk
-- FOREIGN KEY (product_category_name)
-- REFERENCES product_category_name_translation (product_category_name);


-- ============================================================
-- 9. STAGING TABLE: ORDER REVIEWS
-- ============================================================

-- Create a staging copy of the review dataset
-- Run only if the staging table does not already exist.
-- CREATE TABLE stg_orders_review AS
-- SELECT * FROM olist_order_reviews_dataset;

-- Enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Replace NULL review titles in staging table
UPDATE stg_orders_review
SET review_comment_title = 'No_Title'
WHERE review_comment_title IS NULL;

-- Replace NULL review comments in staging table
UPDATE stg_orders_review
SET review_comment_message = 'No_Comment'
WHERE review_comment_message IS NULL;


-- ============================================================
-- 10. STAGING TABLE: PRODUCTS
-- ============================================================

-- Create a staging copy of the product dataset
-- Run only if the staging table does not already exist.
-- CREATE TABLE stg_product AS
-- SELECT * FROM olist_products_dataset;

-- Inspect missing product categories
SELECT *
FROM stg_product
WHERE product_category_name IS NULL;

-- Disable safe update mode if required for the update
SET SQL_SAFE_UPDATES = 0;

-- Replace missing product categories in staging table
UPDATE stg_product
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;

-- Verify the update
SELECT *
FROM stg_product
WHERE product_category_name = 'unknown';


-- ============================================================
-- END OF DATA QUALITY CHECKS
-- ============================================================
