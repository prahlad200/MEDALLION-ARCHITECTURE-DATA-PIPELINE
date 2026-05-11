/*
===============================================================================
Stored Procedure: silver.usp_BulkLoadSilver
===============================================================================
Description:
    Transforms and loads data from the Bronze layer to the Silver layer.
    Standardizes data types, formatting, and casing across all 9 tables.
    
Usage:
    EXEC silver.usp_BulkLoadSilver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.usp_BulkLoadSilver AS
BEGIN
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        -------------------------------------------------------
        -- 1. CRM DATA
        -------------------------------------------------------
        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';
        
        -- Loading silver.crm_customers
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_customers';
        TRUNCATE TABLE silver.crm_customers;
        PRINT '>> Inserting Cleaned Data into: silver.crm_customers';

        INSERT INTO silver.crm_customers (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(customer_id) AS NVARCHAR(100)) AS customer_id,
            CAST(TRIM(customer_unique_id) AS NVARCHAR(100)) AS customer_unique_id,
            CAST(customer_zip_code_prefix AS INT) AS customer_zip_code_prefix, 
            ISNULL(UPPER(TRIM(customer_city)), 'UNKNOWN') AS customer_city,
            ISNULL(UPPER(TRIM(customer_state)), 'NA') AS customer_state,
            GETDATE() AS dwh_create_date 
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS rn
            FROM bronze.crm_customers
            WHERE customer_id IS NOT NULL
        ) t 
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.crm_geolocation
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_geolocation';
        TRUNCATE TABLE silver.crm_geolocation;
        PRINT '>> Inserting Cleaned Data into: silver.crm_geolocation';

        INSERT INTO silver.crm_geolocation (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            dwh_create_date
        )
        SELECT 
            CAST(geolocation_zip_code_prefix AS INT) AS geolocation_zip_code_prefix,
            CAST(geolocation_lat AS DECIMAL(12, 9)) AS geolocation_lat,
            CAST(geolocation_lng AS DECIMAL(12, 9)) AS geolocation_lng,
            ISNULL(UPPER(TRIM(geolocation_city)), 'UNKNOWN') AS geolocation_city,
            ISNULL(UPPER(TRIM(geolocation_state)), 'NA') AS geolocation_state,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (
                       PARTITION BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng 
                       ORDER BY geolocation_city
                   ) AS rn
            FROM bronze.crm_geolocation
        ) t 
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.crm_order_reviews
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_order_reviews';
        TRUNCATE TABLE silver.crm_order_reviews;
        PRINT '>> Inserting Cleaned Data into: silver.crm_order_reviews';

        INSERT INTO silver.crm_order_reviews (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answers_timestamp,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(review_id) AS NVARCHAR(100)) AS review_id,
            CAST(TRIM(order_id) AS NVARCHAR(100)) AS order_id,
            review_score AS review_score,
            CASE WHEN TRIM(review_comment_title) IN ('', '.', '-') THEN 'N/A' ELSE ISNULL(TRIM(review_comment_title), 'N/A') END AS review_comment_title,
            CASE WHEN TRIM(review_comment_message) IN ('', '.', '-') THEN 'N/A' ELSE ISNULL(TRIM(review_comment_message), 'N/A') END AS review_comment_message,
            CAST(review_creation_date AS DATETIME) AS review_creation_date,
            CAST(review_answers_timestamp AS DATETIME) AS review_answers_timestamp,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, 
                   ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_creation_date DESC) AS rn
            FROM bronze.crm_order_reviews
            WHERE review_id IS NOT NULL AND review_creation_date >= '2010-01-01'
        ) t 
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -------------------------------------------------------
        -- 2. ERP DATA
        -------------------------------------------------------
        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- Loading silver.erp_order_items
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_order_items';
        TRUNCATE TABLE silver.erp_order_items;

        INSERT INTO silver.erp_order_items (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(order_id) AS NVARCHAR(100)) AS order_id,
            CAST(order_item_id AS INT) AS order_item_id,
            CAST(TRIM(product_id) AS NVARCHAR(100)) AS product_id,
            CAST(TRIM(seller_id) AS NVARCHAR(100)) AS seller_id,
            CAST(shipping_limit_date AS DATETIME) AS shipping_limit_date,
            CAST(price AS DECIMAL(10, 2)) AS price,
            CAST(freight_value AS DECIMAL(10, 2)) AS freight_value,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id, order_item_id ORDER BY shipping_limit_date) AS rn
            FROM bronze.erp_order_items
        ) t WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.erp_order_payments
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_order_payments';
        TRUNCATE TABLE silver.erp_order_payments;

        INSERT INTO silver.erp_order_payments (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(order_id) AS NVARCHAR(100)) AS order_id,
            CAST(payment_sequential AS INT) AS payment_sequential,
            UPPER(TRIM(payment_type)) AS payment_type,
            CAST(payment_installments AS INT) AS payment_installments,
            CAST(payment_value AS DECIMAL(10, 2)) AS payment_value,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id, payment_sequential ORDER BY payment_value DESC) AS rn
            FROM bronze.erp_order_payments
        ) t WHERE rn = 1 AND payment_value > 0 AND payment_installments >= 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.erp_orders
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_orders';
        TRUNCATE TABLE silver.erp_orders;

        INSERT INTO silver.erp_orders (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(order_id) AS NVARCHAR(100)) AS order_id,
            CAST(TRIM(customer_id) AS NVARCHAR(100)) AS customer_id,
            UPPER(TRIM(order_status)) AS order_status,
            CAST(order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
            CAST(order_approved_at AS DATETIME) AS order_approved_at,
            CAST(order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
            CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
            CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_purchase_timestamp DESC) AS rn
            FROM bronze.erp_orders
        ) t WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.erp_products
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_products';
        TRUNCATE TABLE silver.erp_products;

        INSERT INTO silver.erp_products (
            product_id,
            product_category_name,
            product_name_length,
            product_description_length,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(product_id) AS NVARCHAR(100)) AS product_id,
            ISNULL(UPPER(TRIM(REPLACE(product_category_name, '_', ' '))), 'N/A') AS product_category_name,
            ISNULL(CAST(product_name_length AS INT), 0) AS product_name_length,
            ISNULL(CAST(product_description_length AS INT), 0) AS product_description_length,
            ISNULL(CAST(product_photos_qty AS INT), 0) AS product_photos_qty,
            ISNULL(CAST(product_weight_g AS INT), 0) AS product_weight_g,
            ISNULL(CAST(product_length_cm AS INT), 0) AS product_length_cm,
            ISNULL(CAST(product_height_cm AS INT), 0) AS product_height_cm,
            ISNULL(CAST(product_width_cm AS INT), 0) AS product_width_cm,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_category_name) AS rn
            FROM bronze.erp_products
        ) t WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.erp_sellers
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_sellers';
        TRUNCATE TABLE silver.erp_sellers;

        INSERT INTO silver.erp_sellers (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state,
            dwh_create_date
        )
        SELECT 
            CAST(TRIM(seller_id) AS NVARCHAR(100)) AS seller_id,
            CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix,
            UPPER(TRIM(seller_city)) AS seller_city,
            UPPER(TRIM(seller_state)) AS seller_state,
            GETDATE() AS dwh_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY seller_city) AS rn
            FROM bronze.erp_sellers
        ) t WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Loading silver.product_category_name_translation
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.product_category_name_translation';
        TRUNCATE TABLE silver.product_category_name_translation;

        INSERT INTO silver.product_category_name_translation (
            product_category_name,
            product_category_name_english
        )
        SELECT 
            UPPER(TRIM(REPLACE(prodect_category_name, '_', ' '))) AS product_category_name,
            UPPER(TRIM(REPLACE(prodect_category_name_english, '_', ' '))) AS product_category_name_english
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY prodect_category_name ORDER BY prodect_category_name_english) AS rn
            FROM [dbo].[bronze_product_category_name_translation]
        ) t WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -------------------------------------------------------
        -- BATCH END
        -------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Silver Layer Load Process Successfully Completed';
        PRINT 'Total Execution Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR: Silver Layer Load Process Failed';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
GO