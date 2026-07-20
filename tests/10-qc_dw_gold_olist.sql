/*
======================================================================
Quality Checks
======================================================================
Script Purpose:
	This script performs various quality checks to validate the integrity, 
	consistency, and accuracy of the Gold Layer. These checks ensure:
	- Uniqueness of surrogate keys in dimension tables.
	- Referential integrity between fact and dimension table.
	- Validation of relationships in the data model for analytical purposes.

Usage Notes:
	- Investigate and resolve any discrepancies found during the checks.
======================================================================
*/


-- ================================================================
-- Checking 'gold.dim_customers'
-- ================================================================

-- View Table Contents
SELECT * FROM gold.dim_customers

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expected Result: No Results
SELECT 
	customer_key, 
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Silver and Gold layers.
SELECT COUNT(*) FROM gold.dim_customers;
SELECT COUNT(*) FROM silver.crm_customers;



-- ================================================================
-- Checking 'gold.dim_products'
-- ================================================================

-- View Table Contents
SELECT * FROM gold.dim_products

-- Check for Uniqueness of Product Key in gold.dim_customers
-- Expected Result: No Results
SELECT 
	product_key, 
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Silver and Gold layers.
SELECT COUNT(*) FROM gold.dim_products;
SELECT COUNT(*) FROM silver.erp_products;


-- ================================================================
-- Checking 'gold.dim_sellers'
-- ================================================================

-- View Table Contents
SELECT * FROM gold.dim_sellers;

-- Check for Uniqueness of Product Key in gold.dim_customers
-- Expected Result: No Results
SELECT 
	seller_key, 
	COUNT(*) AS duplicate_count
FROM gold.dim_sellers
GROUP BY seller_key
HAVING COUNT(*) > 1;

-- Checking Record Count Consistency
-- Expected Result: Same record count in both Silver and Gold layers.
SELECT COUNT(*) FROM gold.dim_sellers;
SELECT COUNT(*) FROM silver.scm_sellers;


-- ================================================================
-- Checking 'gold.fact_order_items'
-- ================================================================

-- View Table Contents
SELECT * FROM gold.fact_order_items;

-- Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_order_items foi
LEFT JOIN gold.dim_customers dc
ON  dc.customer_key = foi.customer_key
LEFT JOIN gold.dim_products dp 
ON dp.product_key = foi.product_key 
LEFT JOIN gold.dim_sellers ds 
ON ds.seller_key = foi.seller_key
WHERE ds.seller_key IS NULL OR dp.product_key IS NULL OR dc.customer_key IS NULL;
