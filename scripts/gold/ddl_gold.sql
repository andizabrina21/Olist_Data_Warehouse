/*
 ===============================================================================
 DDL Script: Create Gold Views
 ===============================================================================
 Script Purpose:
 	This script creates views for the Gold layer in the data warehouse.
 	The Gold Layer represents the final dimension and fact tables (Star Schema)
 	
 	Each view performs transformations and combines data from the Silver Layer
 	to produce a clean, enriched, and business-ready dataset.
 
 USAGE:
 	- These views can be queried directly for analytics and reporting.
  ==============================================================================
 */

-- ==============================================================================
-- Create Dimension: gold.dim_customers
-- ==============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;

CREATE VIEW gold.dim_customers AS

WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM silver.crm_customers c
    LEFT JOIN silver.erp_orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_location AS
(
    SELECT
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS customer_lat,
        AVG(geolocation_lng) AS customer_lng
    FROM silver.scm_geolocation
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    ROW_NUMBER() OVER (ORDER BY cc.customer_id) AS customer_key,
    cc.customer_id,
    cc.customer_unique_id,
    CASE
        WHEN COALESCE(co.total_orders, 0) > 1 THEN 'Repeat User'
        ELSE 'Single User'
    END AS customer_type,
    cc.customer_city,
    cc.customer_state,
	CASE 
		WHEN cc.customer_state IN ('GO','MT','DF','MS') THEN 'Central-West'
		WHEN cc.customer_state IN ('ES','MG','RJ','SP') THEN 'Southeast'
		WHEN cc.customer_state IN ('PR','RS','SC') THEN 'South'
		WHEN cc.customer_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Northeast'
		WHEN cc.customer_state IN ('AC','AP','AM','PA','RO','RR','TO') THEN 'North'
		ELSE 'unknown'
	END AS customer_region,
    cl.customer_lat,
    cl.customer_lng
FROM silver.crm_customers cc
LEFT JOIN customer_orders co
    ON cc.customer_unique_id = co.customer_unique_id
LEFT JOIN customer_location cl
    ON cc.customer_zip_code_prefix = cl.geolocation_zip_code_prefix;

-- ==============================================================================
-- Create Dimension: gold.dim_products
-- ==============================================================================
IF OBJECT_ID('gold.dim_products', 'v') IS NOT NULL
	DROP VIEW gold.dim_products;

CREATE VIEW gold.dim_products AS

WITH lookup_clean AS
(
    -- Dedupe the translation table in case of dirty/duplicate rows,
    -- and normalize casing/whitespace on the join key
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM(product_category_name))) AS product_category_name_clean,
        LOWER(LTRIM(RTRIM(product_category_name_english))) AS product_category_name_english_clean
    FROM silver.erp_category_name_translation
),
product_base AS
(
    SELECT
        ep.product_id AS product_id,
        lcnt.product_category_name_english_clean AS product_subcategory
    FROM silver.erp_products ep
    LEFT JOIN lookup_clean lcnt
        ON LOWER(LTRIM(RTRIM(ep.product_category_name))) = lcnt.product_category_name_clean
)
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    product_subcategory,
    CASE
        WHEN product_subcategory IN (
            'fashion_shoes',
            'fashion_bags_accessories',
            'fashion_male_clothing',
            'fashio_female_clothing',
            'fashion_childrens_clothes',
            'fashion_sport',
            'fashion_underwear_beach',
            'luggage_accessories'
        ) THEN 'Fashion'
        WHEN product_subcategory IN (
            'electronics',
            'telephony',
            'computers',
            'computers_accessories',
            'tablets_printing_image',
            'gaming_pc',
            'consoles_games',
            'audio',
            'fixed_telephony',
            'cine_photo'
        ) THEN 'Electronics & Technology'
        WHEN product_subcategory IN (
            'furniture_decor',
            'furniture_bedroom',
            'furniture_living_room',
            'kitchen_dining_laundry_garden_furniture',
            'office_furniture',
            'furniture_mattress_and_upholstery',
            'home_comfort',
            'bed_bath_table',
            'housewares',
            'signaling_and_security',
            'security_and_services'
        ) THEN 'Home & Living'
        WHEN product_subcategory IN (
            'home_appliances',
            'kitchen_appliances',
            'small_appliances',
            'small_appliances_home_oven_and_coffee',
            'air_conditioning'
        ) THEN 'Home Appliances'
        WHEN product_subcategory IN (
            'health_beauty',
            'perfumery'
        ) THEN 'Beauty & Health'
        WHEN product_subcategory IN (
            'sports_leisure',
            'garden_tools'
        ) THEN 'Sports & Outdoor'
        WHEN product_subcategory IN (
            'books_general_interest',
            'books_technical',
            'books_imported',
            'cds_dvds_musicals',
            'dvds_blu_ray',
            'stationery',
            'music'
        ) THEN 'Books & Media'
        WHEN product_subcategory IN (
            'food',
            'drinks',
            'la_cuisine',
            'food_drink'
        ) THEN 'Food & Beverage'
        WHEN product_subcategory IN (
            'baby',
            'toys',
            'pet_shop',
            'diapers_and_hygiene'
        ) THEN 'Baby, Toys & Pet'
        WHEN product_subcategory IN (
            'home_construction',
            'costruction_tools_tools',
            'costruction_tools_garden',
            'construction_tools_lights',
            'construction_tools_safety',
            'construction_tools_construction',
            'agro_industry_and_commerce',
            'industry_commerce_and_business',
            'auto'
        ) THEN 'Construction & Industrial'
        WHEN product_subcategory IN (
            'watches_gifts',
            'art',
            'arts_and_craftmanship',
            'musical_instruments',
            'flowers',
            'party_supplies',
            'christmas_supplies',
            'cool_stuff'
        ) THEN 'Gifts, Arts & Lifestyle'
        WHEN product_subcategory IN (
            'unknown',
            'market_place'
        ) THEN 'Other'
        ELSE 'Other'
    END AS product_category
FROM product_base;

 -- ==============================================================================
-- Create Dimension: gold.dim_sellers
-- ==============================================================================

IF OBJECT_ID('gold.dim_sellers', 'V') IS NOT NULL
    DROP VIEW gold.dim_sellers;

CREATE VIEW gold.dim_sellers AS

WITH seller_revenue AS
(
    SELECT
        seller_id,
        SUM(price) AS total_revenue
    FROM silver.erp_order_items
    GROUP BY seller_id
),
seller_rank AS
(
    SELECT
        seller_id,
        total_revenue,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_group
    FROM seller_revenue
),
seller_location AS
(
    SELECT
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS seller_lat,
        AVG(geolocation_lng) AS seller_lng
    FROM silver.scm_geolocation
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    ROW_NUMBER() OVER (ORDER BY ls.seller_id) AS seller_key,
    ls.seller_id,
    ls.seller_city,
    ls.seller_state,
	CASE 
		WHEN seller_state IN ('GO','MT','DF','MS') THEN 'Central-West'
		WHEN seller_state IN ('ES','MG','RJ','SP') THEN 'Southeast'
		WHEN seller_state IN ('PR','RS','SC') THEN 'South'
		WHEN seller_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Northeast'
		WHEN seller_state IN ('AC','AP','AM','PA','RO','RR','TO') THEN 'North'
		ELSE 'unknown'
	END AS seller_region,
    COALESCE(sr.total_revenue, 0) AS total_revenue,
    CASE
        WHEN sr.revenue_group = 1 THEN 'High Performer'
        WHEN sr.revenue_group IN (2, 3) THEN 'Medium Performer'
        ELSE 'Low Performer'
    END AS seller_segment,
    sl.seller_lat,
    sl.seller_lng
FROM silver.scm_sellers ls
LEFT JOIN seller_rank sr
    ON ls.seller_id = sr.seller_id
LEFT JOIN seller_location sl
    ON ls.seller_zip_code_prefix = sl.geolocation_zip_code_prefix;

-- ==============================================================================
-- Create Dimension: gold.fact_order_items
-- ==============================================================================
IF OBJECT_ID('gold.fact_order_items', 'v') IS NOT NULL
    DROP VIEW gold.fact_order_items;

CREATE VIEW gold.fact_order_items AS
SELECT
	--keys
    eoi.order_id,
    eoi.order_item_id,
    dc.customer_unique_id,
    dc.customer_key,
    dp.product_key,
    ds.seller_key,
    --order atributes
    COALESCE(eo.order_status, 'unknown') AS order_status,
    eo.order_purchase_timestamp,
    eo.order_delivered_carrier_date,
    eo.order_estimated_delivery_date,
    eo.order_delivered_customer_date,
    --financial measures
    eoi.shipping_limit_date,
    eoi.price,
    eoi.freight_value,
    COALESCE(pay.payment_type, 'unknown') AS payment_type,
    --delivery performances
    CASE
        WHEN eo.order_purchase_timestamp IS NULL
          OR eo.order_delivered_customer_date IS NULL THEN NULL
        ELSE DATEDIFF(DAY, eo.order_purchase_timestamp, eo.order_delivered_customer_date)
    END AS days_to_delivery,
    CASE
        WHEN eo.order_estimated_delivery_date IS NULL
          OR eo.order_delivered_customer_date IS NULL THEN NULL
        ELSE DATEDIFF(DAY, eo.order_estimated_delivery_date, eo.order_delivered_customer_date)
    END AS days_late,
    CASE
        WHEN eo.order_purchase_timestamp IS NULL
          OR eoi.shipping_limit_date IS NULL THEN NULL
        ELSE DATEDIFF(DAY, eo.order_purchase_timestamp, eoi.shipping_limit_date)
    END AS days_to_ship_limit,
    CASE
        WHEN eo.order_delivered_carrier_date IS NULL
          OR eoi.shipping_limit_date IS NULL THEN NULL  -- unknown, not 0
        WHEN eo.order_delivered_carrier_date
             > eoi.shipping_limit_date THEN 1
        ELSE 0
    END AS is_late_shipment,
    --review
    cor.review_id,
    cor.review_score,
    CASE 
	  WHEN review_score >= 4 THEN 'Positive'
	  WHEN review_score = 3 THEN 'Neutral'
	  WHEN review_score <= 2 THEN 'Negative'
	  ELSE 'n/a'
	END AS review_category
FROM silver.erp_order_items eoi
LEFT JOIN silver.erp_orders eo
    ON eoi.order_id = eo.order_id
LEFT JOIN gold.dim_customers dc
    ON eo.customer_id = dc.customer_id
LEFT JOIN gold.dim_products dp
    ON eoi.product_id = dp.product_id
LEFT JOIN gold.dim_sellers ds
    ON eoi.seller_id = ds.seller_id
LEFT JOIN (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY review_answer_timestamp DESC
            ) AS rn
        FROM silver.crm_order_reviews
    ) r
    WHERE rn = 1
) cor ON eoi.order_id = cor.order_id
LEFT JOIN (
    SELECT
        order_id,
        payment_type,
        payment_value,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC
        ) AS rn
    FROM silver.erp_order_payments
) pay
    ON eoi.order_id = pay.order_id
   AND pay.rn = 1
WHERE eo.order_status IS NOT NULL;
