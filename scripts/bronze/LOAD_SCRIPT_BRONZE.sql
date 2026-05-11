/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.usp_BulkLoadOlist
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '==========================================';
        PRINT 'STARTING OLIST BRONZE LAYER BULK LOAD';
        PRINT '==========================================';

        PRINT '------------------------------------------';
        PRINT 'LOADIND CRM TABLES';
        PRINT '------------------------------------------';
        PRINT ''; -- Space after header 
    
        -- 1. Customers
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.crm_customers';
        TRUNCATE TABLE bronze.crm_customers;

        PRINT '>> INSERTING DATA INTO: bronze.crm_customers';

        BULK INSERT bronze.crm_customers
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 1 CRM (Front-Office)\customers.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Customers loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 1

        -- 2. Geolocation
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.crm_geolocation';
        TRUNCATE TABLE bronze.crm_geolocation;

        PRINT '>> INSERTING DATA INTO: bronze.crm_geolocation';

        BULK INSERT bronze.crm_geolocation
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 1 CRM (Front-Office)\geolocation.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Geolocation loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 2

        -- 3. Order_Reviews
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.crm_order_reviews';
        TRUNCATE TABLE bronze.crm_order_reviews;

        PRINT '>> INSERTING DATA INTO: bronze.crm_order_reviews';

        BULK INSERT bronze.crm_order_reviews
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 1 CRM (Front-Office)\order_reviews.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Order Reviews loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 3

        PRINT '------------------------------------------';
        PRINT 'LOADIND ERP TABLES';
        PRINT '------------------------------------------';
        PRINT ''; -- Space after header 

        -- 4. Orders_items
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.erp_order_items';
        TRUNCATE TABLE bronze.erp_order_items;

        PRINT '>> INSERTING DATA INTO: bronze.erp_order_items';
    
        BULK INSERT bronze.erp_order_items
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\order_items.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Order Items loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 4

        -- 5. Orders_Payments
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.erp_order_payments';
        TRUNCATE TABLE bronze.erp_order_payments;

        PRINT '>> INSERTING DATA INTO: bronze.erp_order_payments';

        BULK INSERT bronze.erp_order_payments
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\order_payments.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Order Payments loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 5

        -- 6. Orders
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.erp_orders';
        TRUNCATE TABLE bronze.erp_orders;

        PRINT '>> INSERTING DATA INTO: bronze.erp_orders';

        BULK INSERT bronze.erp_orders
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\orders.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Orders loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 6

        -- 7. Products
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.erp_products';
        TRUNCATE TABLE bronze.erp_products;

        PRINT '>> INSERTING DATA INTO: bronze.erp_products';

        BULK INSERT bronze.erp_products
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\products.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Products loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 7

        -- 8. Sellers
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: bronze.erp_sellers';
        TRUNCATE TABLE bronze.erp_sellers;

        PRINT '>> INSERTING DATA INTO: bronze.erp_sellers';

        BULK INSERT bronze.erp_sellers
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\sellers.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Sellers loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
        PRINT ''; -- Space after table 8

        -- 9. Product_Category_Name_Translation
        SET @start_time = GETDATE();
        PRINT '>> TRUNCATING TABLE: dbo.bronze_product_category_name_translation';
        TRUNCATE TABLE dbo.bronze_product_category_name_translation;

        PRINT '>> INSERTING DATA INTO: dbo.bronze_product_category_name_translation';

        BULK INSERT dbo.bronze_product_category_name_translation
        FROM 'C:\OlistData\Olist Brazilian E-Commerce dataset\Source System 2 ERP (Back-Office)\product_category_name_translation.csv'
        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', CODEPAGE = '65001', TABLOCK);
        PRINT '>> Category Translations loaded.';
        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
        PRINT ''; -- Space after table 9

        PRINT '------------------------------------------';
        PRINT 'SUCCESS: All Bronze tables loaded.';
        PRINT '------------------------------------------';
    END TRY 
    BEGIN CATCH
    PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='    
    END CATCH
END




