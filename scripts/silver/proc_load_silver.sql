/*
 ===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
 ===============================================================================
 Script Purpose:
 	This stored procedure performs the ETL (Extract, Transform, Load) process to
 	populate the 'silver' schema tables from the 'bronze' schema.
 	Actions Performs:
 	- Truncates Silver Tables.
 	- Insert transformedd and cleansed data from Bronze into silver tables.
 	
 Parameters:
 	None.
 		This stored procedure does not accept any parameters or return any values.
 
Usage Example:
	EXEC silver.load_bronze;
  ==============================================================================
 */

-- ==========================================CUSTOMERS TABLE ====================================================--
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================'
		PRINT 'Loading Silver Layer';
		PRINT '================================================'
		
		PRINT '================================================'
		PRINT 'Loading CRM Tables';
		PRINT '================================================'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_customers';
		TRUNCATE TABLE silver.crm_customers;
		PRINT '>> Inserting Data Into: silver.crm_customers';
		INSERT INTO silver.crm_customers(
			customer_id,
		    customer_unique_id,
		    customer_zip_code_prefix,
		    customer_city,
		    customer_state
		)
		SELECT 
			customer_id,
		    customer_unique_id,
		    customer_zip_code_prefix,
		    LOWER(customer_city),
		    customer_state
		FROM bronze.crm_customers;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		--=============================================== ORDER REVIEWS TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_order_reviews';
		TRUNCATE TABLE silver.crm_order_reviews;
		PRINT '>> Inserting Data Into: silver.crm_order_reviews';
		INSERT INTO silver.crm_order_reviews(
			review_id, 
			order_id, 
			review_score, 
			review_comment_title, 
			review_comment_message, 
			review_creation_date, 
			review_answer_timestamp
		)
		SELECT
			review_id,
			order_id,
			TRY_CAST(review_score AS INT),
			LOWER(TRIM(review_comment_title)) AS review_comment_title,
			LOWER(
			    CASE
			        WHEN RIGHT(RTRIM(review_comment_message), 1) = '"'
			        THEN LEFT(RTRIM(review_comment_message), LEN(RTRIM(review_comment_message)) - 1)
			        ELSE review_comment_message
			    END
			) AS review_comment_message,
			TRY_CAST(review_creation_date AS DATETIME),
    		TRY_CAST(review_answer_timestamp AS DATETIME)
		FROM bronze.crm_order_reviews;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		PRINT '================================================'
		PRINT 'Loading ERP Tables';
		PRINT '================================================'
		
		--=============================================== ORDER ITEMS TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_order_items';
		TRUNCATE TABLE silver.erp_order_items;
		PRINT '>> Inserting Data Into: silver.erp_order_items';
		INSERT INTO silver.erp_order_items(
			order_id, 
			order_item_id, 
			product_id, 
			seller_id, 
			shipping_limit_date, 
			price, 
			freight_value
		)
		SELECT
			order_id, 
			order_item_id, 
			product_id, 
			seller_id, 
			shipping_limit_date, 
			price, 
			freight_value
		FROM (
		    SELECT 
		    	order_id, 
		    	order_item_id, 
		    	product_id, 
		    	seller_id, 
		    	CASE
				    WHEN shipping_limit_date = '2020-02-05 03:30:51.000'
				        THEN '2017-03-23 03:30:51.000'
				
				    WHEN shipping_limit_date = '2020-02-03 20:23:22.000'
				        THEN '2017-03-21 19:23:22.000'
				
				    WHEN shipping_limit_date = '2020-04-09 22:35:08.000'
				        THEN '2017-05-30 22:28:36.000'
				    ELSE shipping_limit_date
				END AS shipping_limit_date, 
		    	price, 
		    	freight_value,
		        ROW_NUMBER() OVER (PARTITION BY order_id, product_id, seller_id ORDER BY shipping_limit_date DESC) AS flag_last
		    FROM bronze.erp_order_items
		    WHERE order_id IS NOT NULL AND product_id IS NOT NULL AND seller_id IS NOT NULL
		)t
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		--=============================================== ORDER PAYMENTS TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_order_payments';
		TRUNCATE TABLE silver.erp_order_payments;
		PRINT '>> Inserting Data Into: silver.erp_order_payments';
		INSERT INTO silver.erp_order_payments(
			order_id, 
			payment_sequential, 
			payment_type, 
			payment_installments, 
			payment_value
		)
		SELECT
			order_id, 
			payment_sequential, 
			payment_type, 
			payment_installments, 
			payment_value
		FROM bronze.erp_order_payments eop;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		--=============================================== ORDERS TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_orders';
		TRUNCATE TABLE silver.erp_orders;
		PRINT '>> Inserting Data Into: silver.erp_orders';
		INSERT INTO silver.erp_orders(
			order_id, 
			customer_id, 
			order_status, 
			order_purchase_timestamp, 
			order_approved_at, 
			order_delivered_carrier_date, 
			order_delivered_customer_date, 
			order_estimated_delivery_date
		)
		SELECT 
			order_id, 
			customer_id, 
			order_status, 
			order_purchase_timestamp, 
			order_approved_at, 
			order_delivered_carrier_date, 
			order_delivered_customer_date, 
			order_estimated_delivery_date
		FROM bronze.erp_orders
		WHERE NOT (
			order_status = 'delivered'
			AND order_delivered_customer_date IS NULL
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		--=============================================== PRODUCTS TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_products';
		TRUNCATE TABLE silver.erp_products;
		PRINT '>> Inserting Data Into: silver.erp_products';
		INSERT INTO silver.erp_products(
			product_id, 
			product_category_name, 
			product_name_length, 
			product_description_length, 
			product_photos_qty, 
			product_weight_g, 
			product_length_cm, 
			product_height_cm, 
			product_width_cm
		)
		SELECT 
			product_id, 
			COALESCE(
				CASE
					WHEN product_category_name = 'casa_conforto_2' THEN 'casa_conforto'
					WHEN product_category_name = 'eletrodomesticos_2' THEN 'eletrodomesticos'
					ELSE product_category_name
				END,
			'unknown') AS product_category_name,
			product_name_lenght AS product_name_length , 
			product_description_lenght AS product_description_length, 
			product_photos_qty, 
			CASE
				WHEN product_weight_g = 0 THEN NULL
				ELSE product_weight_g
			END AS product_weight_g,
			product_length_cm, 
			product_height_cm, 
			product_width_cm
		FROM bronze.erp_products;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		--=============================================== TRANSLATE CAT_NAME TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_category_name_translation';
		TRUNCATE TABLE silver.erp_category_name_translation;
		PRINT '>> Inserting Data Into: silver.erp_category_name_translation';
		INSERT INTO silver.erp_category_name_translation (
		    product_category_name,
		    product_category_name_english
		)
		SELECT
		    product_category_name,
		    CASE
		        WHEN REPLACE(product_category_name_english, NCHAR(13), '') = 'home_confort' THEN 'home_comfort'
		        ELSE REPLACE(product_category_name_english, NCHAR(13), '')
		    END AS product_category_name_english
		FROM bronze.erp_category_name_translation
		WHERE REPLACE(product_category_name_english, NCHAR(13), '') NOT IN ('home_appliances_2', 'home_comfort_2')
		UNION ALL
		SELECT 'unknown', 'unknown'
		UNION ALL
		SELECT 'pc_gamer', 'gaming_pc'
		UNION ALL
		SELECT 'portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_appliances';
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		PRINT '================================================'
		PRINT 'Loading scm Tables';
		PRINT '================================================'
		
		--=============================================== GEOLOCATION TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.scm_geolocation';
		TRUNCATE TABLE silver.scm_geolocation;
		PRINT '>> Inserting Data Into: silver.scm_geolocation';

		WITH clean_geolocation AS (
		    SELECT 
		        geolocation_zip_code_prefix,
		        geolocation_lat,
		        geolocation_lng,
		        CASE 
		            WHEN LOWER(LTRIM(RTRIM(geolocation_city))) = 'rj' THEN 'rio de janeiro'
		            WHEN LOWER(LTRIM(RTRIM(geolocation_city))) = 'sp' THEN 'sao paulo'
		            WHEN LOWER(LTRIM(RTRIM(geolocation_city))) IN ('saopaulo', 'sao paulo') THEN 'sao paulo'
		            ELSE LOWER(LTRIM(RTRIM(geolocation_city)))
		        END AS geolocation_city,
		        CASE
		            WHEN LOWER(LTRIM(RTRIM(geolocation_state))) = 'rio de janeiro, brasil,rj'
		                THEN 'RJ'
		            ELSE UPPER(LTRIM(RTRIM(geolocation_state)))
		        END AS geolocation_state
		    FROM bronze.scm_geolocation
		),
		location_avg AS (
		    SELECT
		        geolocation_zip_code_prefix,
		        AVG(geolocation_lat) AS geolocation_lat,
		        AVG(geolocation_lng) AS geolocation_lng
		    FROM clean_geolocation
		    GROUP BY geolocation_zip_code_prefix
		),
		city_rank AS (
		    SELECT
		        geolocation_zip_code_prefix,
		        geolocation_city,
		        ROW_NUMBER() OVER (
		            PARTITION BY geolocation_zip_code_prefix
		            ORDER BY COUNT(*) DESC, geolocation_city
		        ) AS rn
		    FROM clean_geolocation
		    GROUP BY
		        geolocation_zip_code_prefix,
		        geolocation_city
		),
		state_rank AS (
		    SELECT
		        geolocation_zip_code_prefix,
		        geolocation_state,
		        ROW_NUMBER() OVER (
		            PARTITION BY geolocation_zip_code_prefix
		            ORDER BY COUNT(*) DESC, geolocation_state
		        ) AS rn
		    FROM clean_geolocation
		    GROUP BY
		        geolocation_zip_code_prefix,
		        geolocation_state
		)
		
		INSERT INTO silver.scm_geolocation (
		    geolocation_zip_code_prefix,
		    geolocation_lat,
		    geolocation_lng,
		    geolocation_city,
		    geolocation_state
		)
		
		SELECT
		    l.geolocation_zip_code_prefix,
		    l.geolocation_lat,
		    l.geolocation_lng,
		    c.geolocation_city,
		    s.geolocation_state
		FROM location_avg l
		JOIN city_rank c
		    ON l.geolocation_zip_code_prefix = c.geolocation_zip_code_prefix
		    AND c.rn = 1
		JOIN state_rank s
		    ON l.geolocation_zip_code_prefix = s.geolocation_zip_code_prefix
		    AND s.rn = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		--=============================================== SELLER TABLE ===============================================----
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.scm_sellers';
		TRUNCATE TABLE silver.scm_sellers;
		PRINT '>> Inserting Data Into: silver.scm_sellers';
		INSERT INTO silver.scm_sellers(
			seller_id, 
			seller_zip_code_prefix, 
			seller_city, 
			seller_state
		)
		SELECT 
			seller_id, 
			seller_zip_code_prefix, 
			TRIM(seller_city) AS seller_city, 
			seller_state
		FROM bronze.scm_sellers;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		SET @batch_end_time = GETDATE();
		PRINT '================================================'
		PRINT 'Loading Silver Layer is Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================'
		
	END TRY
	BEGIN CATCH
		PRINT '================================================'
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================'
	END CATCH
END
