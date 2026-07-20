/*
======================================================================
Quality Checks
======================================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy,
	and standardization across the 'silver' layer. It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid date ranges and orders.
	- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading Silver Layer.
======================================================================
*/

-- ================================================================
-- Loading Silver Layer
-- ================================================================
EXEC silver.load_silver;


-- ================================================================
-- Checking 'silver.crm_customers'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.crm_customers;

-- Check for NULLs and Duplicate in Primary Key
-- Expected Result: No Results
SELECT 
	customer_id,
	customer_unique_id,
	COUNT(*)
FROM silver.crm_customers
GROUP BY customer_id, customer_unique_id
HAVING COUNT(*) > 1 OR customer_id IS NULL OR customer_unique_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	customer_id
FROM silver.crm_customers
WHERE customer_id != TRIM(customer_id);

SELECT 
	customer_unique_id
FROM silver.crm_customers
WHERE customer_unique_id != TRIM(customer_unique_id);

SELECT 
	customer_zip_code_prefix 
FROM silver.crm_customers
WHERE customer_zip_code_prefix != TRIM(customer_zip_code_prefix);

SELECT 
	customer_city 
FROM silver.crm_customers
WHERE customer_city != TRIM(customer_city);

SELECT 
	customer_state
FROM silver.crm_customers
WHERE customer_state != TRIM(customer_state);

-- Data Standardization & Consistency
SELECT DISTINCT
	customer_state
FROM silver.crm_customers;

SELECT DISTINCT
	customer_city
FROM silver.crm_customers;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Bronze and Silver layers.
SELECT COUNT(*) FROM bronze.crm_customers;
SELECT COUNT(*) FROM silver.crm_customers;


-- ================================================================
-- Checking 'silver.crm_order_reviews'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.crm_order_reviews;

-- Check for NULLs and Duplicate in Primary Key
-- Expected Result: No Results
SELECT 
	review_id,
	order_id,
	COUNT(*)
FROM silver.crm_order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1 OR review_id IS NULL OR order_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	review_id
FROM silver.crm_order_reviews
WHERE review_id != TRIM(review_id);

SELECT 
	order_id
FROM silver.crm_order_reviews
WHERE order_id != TRIM(order_id);

SELECT 
	review_comment_title 
FROM silver.crm_order_reviews
WHERE review_comment_title != TRIM(review_comment_title);

SELECT 
	review_comment_message 
FROM silver.crm_order_reviews
WHERE review_comment_message != TRIM(review_comment_message);

-- Data Standardization & Consistency
-- Check for Invalid Review Scores
-- Expected Result: Review scores should be between 1 and 5.
SELECT DISTINCT
	review_score
FROM silver.crm_order_reviews;

-- Check for Invalid Date Values
-- Expected Result: No invalid or illogical timestamps.
SELECT 
	MAX(review_answer_timestamp),
	MIN(review_answer_timestamp),
	MAX(review_creation_date),
	MIN(review_creation_date)
FROM silver.crm_order_reviews;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Bronze and Silver layers.
SELECT COUNT(*) FROM bronze.crm_order_reviews;
SELECT COUNT(*) FROM silver.crm_order_reviews;


-- ================================================================
-- Checking 'silver.erp_category_name_translation'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.erp_category_name_translation;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	product_category_name
FROM silver.erp_category_name_translation
WHERE product_category_name != TRIM(product_category_name);

SELECT 
	product_category_name_english
FROM silver.erp_category_name_translation
WHERE product_category_name_english != TRIM(product_category_name_english);

-- Data Standardization & Consistency
SELECT DISTINCT
	product_category_name
FROM silver.erp_category_name_translation;

SELECT DISTINCT
	product_category_name_english
FROM silver.erp_category_name_translation;

-- Checking Record Count Consistency
SELECT COUNT(*) FROM bronze.erp_category_name_translation;
SELECT COUNT(*) FROM silver.erp_category_name_translation;
-- Note:
/* 
	The Bronze layer contains duplicate records for 'home_appliances' and 'casa_conforto',
	resulting in an original row count of 69.
	The Silver layer includes two additional translation records for 'pc_gamer' and 
	'portateis_cozinha_e_preparadores_de_alimentos' that were missing English translations in the source dataset, 
	as well as an additional 'Unknown' category for data warehouse completeness.
*/

-- ================================================================
-- Checking 'silver.erp_order_items'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.erp_order_items;

-- Check for NULLs and Duplicate in Primary Key
-- Expected Result: No Results
SELECT 
	order_id,
	product_id,
	seller_id,
	COUNT(*)
FROM silver.erp_order_items
GROUP BY order_id, product_id, seller_id
HAVING COUNT(*) > 1 OR order_id IS NULL OR product_id IS NULL OR seller_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	order_id
FROM silver.erp_order_items
WHERE order_id != TRIM(order_id);

SELECT 
	product_id
FROM silver.erp_order_items
WHERE product_id != TRIM(product_id);

SELECT 
	seller_id
FROM silver.erp_order_items
WHERE seller_id != TRIM(seller_id);

-- Check for Invalid Date Values
-- Expected Result: No invalid or illogical timestamps.
SELECT 
	MAX(shipping_limit_date),
	MIN(shipping_limit_date)
FROM silver.erp_order_items;

-- Checking Record Count Consistency
SELECT COUNT(*) FROM bronze.erp_order_items;
SELECT COUNT(*) FROM silver.erp_order_items;
-- Note:
/*
	The Silver layer contains fewer records because only valid order items are retained.
	Records with missing order_id, seller_id, or product_id are excluded during the data cleaning process.
*/


-- ================================================================
-- Checking 'silver.erp_order_payments'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.erp_order_payments;

-- Check for NULLs and Duplicate Composite Primary Key
-- Expected Result: No Results
SELECT
    order_id,
    payment_sequential,
    COUNT(*)
FROM silver.erp_order_payments
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1
    OR order_id IS NULL
    OR payment_sequential IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	order_id
FROM silver.erp_order_payments
WHERE order_id != TRIM(order_id);

SELECT 
	payment_type 
FROM silver.erp_order_payments
WHERE payment_type != TRIM(payment_type);

-- Data Standardization & Consistency
SELECT DISTINCT
	payment_type 
FROM silver.erp_order_payments;

-- Check for Invalid Number
-- Expected Result: Positive Integer
SELECT DISTINCT
	payment_sequential
FROM silver.erp_order_payments;

SELECT DISTINCT
	payment_installments
FROM silver.erp_order_payments;

SELECT DISTINCT
	MIN(payment_value),
	MAX(payment_value)
FROM silver.erp_order_payments;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Bronze and Silver layers.
SELECT COUNT(*) FROM bronze.erp_order_payments;
SELECT COUNT(*) FROM silver.erp_order_payments;


-- ================================================================
-- Checking 'silver.erp_orders'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.erp_orders;

-- Check for NULLs and Duplicate Primary Key
-- Expected Result: No Results
SELECT 
	order_id,
	customer_id,
	COUNT(*)
FROM silver.erp_orders
GROUP BY order_id, customer_id
HAVING COUNT(*) > 1 OR order_id IS NULL OR customer_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	order_id
FROM silver.erp_orders
WHERE order_id != TRIM(order_id);

SELECT 
	customer_id
FROM silver.erp_orders
WHERE customer_id != TRIM(customer_id);

SELECT 
	order_status
FROM silver.erp_orders
WHERE order_status != TRIM(order_status);

-- Data Standardization & Consistency
SELECT DISTINCT
	order_status
FROM silver.erp_orders;

-- Check for Invalid Date Values
-- Expected Result: No invalid or illogical timestamps.
SELECT 
	MAX(order_purchase_timestamp),
	MIN(order_purchase_timestamp),
	MAX(order_approved_at),
	MIN(order_approved_at),
	MAX(order_delivered_carrier_date),
	MIN(order_delivered_carrier_date),
	MAX(order_delivered_customer_date),
	MIN(order_delivered_customer_date),
	MAX(order_estimated_delivery_date),
	MIN(order_estimated_delivery_date)
FROM silver.erp_orders;

-- Checking Record Count Consistency
SELECT COUNT(*) FROM bronze.erp_orders;
SELECT COUNT(*) FROM silver.erp_orders;
-- Note:
/*
	The Silver layer contains fewer records because only valid delivered orders are retained.
	Orders with a status other than 'delivered' or with a NULL delivery timestamp are excluded 
	during the data cleaning process.
*/

-- ================================================================
-- Checking 'silver.erp_products'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.erp_products;

-- Check for NULLs and Duplicate Primary Key
-- Expected Result: No Results
SELECT 
	product_id, 
	COUNT(*)
FROM silver.erp_products
GROUP BY product_id 
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	product_id 
FROM silver.erp_products
WHERE product_id != TRIM(product_id);

SELECT 
	product_category_name 
FROM silver.erp_products
WHERE product_category_name != TRIM(product_category_name);

-- Check for Invalid Number
-- Expected Result: Positive Integer
SELECT 
	MAX(product_name_length),
	MIN(product_name_length),
	MAX(product_description_length),
	MIN(product_description_length),
	MAX(product_photos_qty),
	MIN(product_photos_qty),
	MAX(product_weight_g),
	MIN(product_weight_g),
	MAX(product_length_cm),
	MIN(product_length_cm),
	MAX(product_height_cm),
	MIN(product_height_cm),
	MAX(product_width_cm),
	MIN(product_width_cm)
FROM silver.erp_products;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Bronze and Silver layers.
SELECT COUNT(*) FROM bronze.erp_products;
SELECT COUNT(*) FROM silver.erp_products;


-- ================================================================
-- Checking 'silver.scm_geolocation'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.scm_geolocation;

-- Check for NULLs and Duplicate Primary Key
-- Expected Result: No Results
SELECT 
	geolocation_zip_code_prefix, 
	COUNT(*)
FROM silver.scm_geolocation
GROUP BY geolocation_zip_code_prefix 
HAVING COUNT(*) > 1 OR geolocation_zip_code_prefix IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	geolocation_city
FROM silver.scm_geolocation
WHERE geolocation_city != TRIM(geolocation_city);

SELECT 
	geolocation_state
FROM silver.scm_geolocation
WHERE geolocation_state != TRIM(geolocation_state);

-- Check for Invalid Number
-- Expected Result: Latitude and Longitude Values Should Fall within Valid Geographic Ranges.
-- Latitude between -90 and 90 & Longitude between -180 and 180;
SELECT 
	MAX(geolocation_lat),
	MIN(geolocation_lat),
	MAX(geolocation_lng),
	MIN(geolocation_lng)
FROM silver.scm_geolocation

-- Checking Record Count Consistency
SELECT COUNT(*) FROM bronze.scm_geolocation;
SELECT COUNT(*) FROM silver.scm_geolocation;
-- Note:
/*
	The Silver layer contains significantly fewer records because geolocation data
	is aggregated by ZIP code prefix. For each ZIP code prefix, the latitude and
	longitude values are averaged to produce a single representative location.
*/


-- ================================================================
-- Checking 'silver.scm_sellers'
-- ================================================================

-- View Table Contents
SELECT * FROM silver.scm_sellers;

-- Check for NULLs and Duplicate Primary Key
-- Expected Result: No Results
SELECT 
	seller_id, 
	COUNT(*)
FROM silver.scm_sellers
GROUP BY seller_id 
HAVING COUNT(*) > 1 OR seller_id IS NULL;

-- Check for Unwanted Spaces
-- Expected Result: No Results
SELECT 
	seller_city
FROM silver.scm_sellers
WHERE seller_city != TRIM(seller_city);

SELECT 
	seller_state
FROM silver.scm_sellers
WHERE seller_state != TRIM(seller_state);

-- Check for Invalid Number
-- Expected Result: Latitude and Longitude Values Should Fall within Valid Geographic Ranges.
-- Latitude between -90 and 90 & Longitude between -180 and 180;
SELECT 
	MAX(seller_zip_code_prefix),
	MIN(seller_zip_code_prefix)
FROM silver.scm_sellers;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Bronze and Silver layers.
SELECT COUNT(*) FROM bronze.scm_sellers;
SELECT COUNT(*) FROM silver.scm_sellers;
