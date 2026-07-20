/*
 ===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
 ===============================================================================
 Script Purpose:
 	This stored procedure loads data into the 'bronze' schema from external CSV files.
 	It performs the following actions:
 	- Truncates the bronze tables before loading data.
 	- Uses the `BULK INSERT` command to load data from CSV files to bronze tables.
 	
 Parameters:
 	None.
 		This stored procedure does not accept any parameters or return any values.
 
 
Usage Example:
	EXEC bronze.load_bronze;
  ==============================================================================
 */

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================'
		PRINT 'Loading Bronze Layer';
		PRINT '================================================'
		
		PRINT '================================================'
		PRINT 'Loading CRM Tables';
		PRINT '================================================'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_customers';
		TRUNCATE TABLE bronze.crm_customers;
		PRINT '>> Inserting Data Into: bronze.crm_customers';
		BULK INSERT bronze.crm_customers
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_crm\olist_customers_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_order_reviews';
		TRUNCATE TABLE bronze.crm_order_reviews;
		PRINT '>> Inserting Data Into: bronze.crm_order_reviews';
		BULK INSERT bronze.crm_order_reviews
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_crm\olist_order_reviews_dataset.csv'
		WITH(
		    FORMAT = 'CSV',
		    FIELDQUOTE = '"',
		    FIRSTROW = 2
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		PRINT '================================================'
		PRINT 'Loading ERP Tables';
		PRINT '================================================'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_order_items';
		TRUNCATE TABLE bronze.erp_order_items;
		PRINT '>> Inserting Data Into: bronze.erp_order_items';
		BULK INSERT bronze.erp_order_items
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_erp\olist_order_items_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_order_payments';
		TRUNCATE TABLE bronze.erp_order_payments;
		PRINT '>> Inserting Data Into: bronze.erp_order_payments';
		BULK INSERT bronze.erp_order_payments
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_erp\olist_order_payments_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_orders';
		TRUNCATE TABLE bronze.erp_orders;
		PRINT '>> Inserting Data Into: bronze.erp_orders';
		BULK INSERT bronze.erp_orders
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_erp\olist_orders_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_products';
		TRUNCATE TABLE bronze.erp_products;
		PRINT '>> Inserting Data Into: bronze.erp_products';
		BULK INSERT bronze.erp_products
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_erp\olist_products_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		PRINT '================================================'
		PRINT 'Loading LOB Tables';
		PRINT '================================================'
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_category_name_translation';
		TRUNCATE TABLE bronze.erp_category_name_translation;
		PRINT '>> Inserting Data Into: bronze.erp_category_name_translation';
		BULK INSERT bronze.erp_category_name_translation
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_erp\product_category_name_translation.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.scm_geolocation';
		TRUNCATE TABLE bronze.scm_geolocation;
		PRINT '>> Inserting Data Into: bronze.scm_geolocation';
		BULK INSERT bronze.scm_geolocation
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_scm\olist_geolocation_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.scm_sellers';
		TRUNCATE TABLE bronze.scm_sellers;
		PRINT '>> Inserting Data Into: bronze.scm_sellers';
		BULK INSERT bronze.scm_sellers
		FROM 'C:\PROJECT\2-DE\Data Warehouse\Olist_Ecommerce\source_scm\olist_sellers_dataset.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a', 
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------------------'
		
		SET @batch_end_time = GETDATE();
		PRINT '================================================'
		PRINT 'Loading Bronze Layer is Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================'
	END TRY
	BEGIN CATCH
		PRINT '================================================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================'
	END CATCH
END
