/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- 1. Customers Table
IF OBJECT_ID('bronze.crm_customers', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customers;
GO
CREATE TABLE bronze.crm_customers(
    customer_id              NVARCHAR(100),
    customer_unique_id       NVARCHAR(100),
    customer_zip_code_prefix INT,
    customer_city            NVARCHAR(100),
    customer_state           NVARCHAR(100)
);
GO

-- 2. Geolocation Table
IF OBJECT_ID('bronze.crm_geolocation', 'U') IS NOT NULL
    DROP TABLE bronze.crm_geolocation;
GO
CREATE TABLE bronze.crm_geolocation(
    geolocation_zip_code_prefix INT,
    geolocation_lat             DECIMAL(12, 9),
    geolocation_lng             DECIMAL(12, 9),
    geolocation_city            NVARCHAR(100),
    geolocation_state           NVARCHAR(100)
);
GO

-- 3. Order Reviews Table
IF OBJECT_ID('bronze.crm_order_reviews', 'U') IS NOT NULL
    DROP TABLE bronze.crm_order_reviews;
GO
CREATE TABLE bronze.crm_order_reviews(
    review_id                NVARCHAR(100),
    order_id                 NVARCHAR(100),
    review_score             INT,
    review_comment_title     NVARCHAR(255),
    review_comment_message   NVARCHAR(MAX), -- Increased to handle long Portuguese reviews
    review_creation_date     DATETIME,
    review_answers_timestamp DATETIME
);
GO

-- 4. Order Items Table
IF OBJECT_ID('bronze.erp_order_items', 'U') IS NOT NULL
    DROP TABLE bronze.erp_order_items;
GO
CREATE TABLE bronze.erp_order_items(
    order_id            NVARCHAR(100),
    order_item_id       INT,
    product_id          NVARCHAR(100),
    seller_id           NVARCHAR(100),
    shipping_limit_date DATETIME,
    price               DECIMAL(10, 2),
    freight_value       DECIMAL(10, 2)
);
GO

-- 5. Order Payments Table
IF OBJECT_ID('bronze.erp_order_payments', 'U') IS NOT NULL
    DROP TABLE bronze.erp_order_payments;
GO
CREATE TABLE bronze.erp_order_payments(
    order_id             NVARCHAR(100),
    payment_sequential   INT,
    payment_type         NVARCHAR(100),
    payment_installments INT,
    payment_value        DECIMAL(10, 2)
);
GO

-- 6. Orders Table
IF OBJECT_ID('bronze.erp_orders', 'U') IS NOT NULL
    DROP TABLE bronze.erp_orders;
GO
CREATE TABLE bronze.erp_orders(
    order_id                      NVARCHAR(100),
    customer_id                   NVARCHAR(100),
    order_status                  NVARCHAR(100),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME,
    order_delivered_carrier_date  DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);
GO

-- 7. Category Translation Table
IF OBJECT_ID('bronze.product_category_name_translation', 'U') IS NOT NULL
    DROP TABLE bronze.product_category_name_translation;
GO
CREATE TABLE bronze.product_category_name_translation(
    product_category_name         NVARCHAR(100), -- Fixed spelling
    product_category_name_english NVARCHAR(100)  -- Fixed spelling
);
GO

-- 8. Products Table
IF OBJECT_ID('bronze.erp_products', 'U') IS NOT NULL
    DROP TABLE bronze.erp_products;
GO
CREATE TABLE bronze.erp_products(
    product_id                 NVARCHAR(100),
    product_category_name      NVARCHAR(100),
    product_name_length        INT, -- Fixed spelling
    product_description_length INT, -- Fixed spelling
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);
GO

-- 9. Sellers Table
IF OBJECT_ID('bronze.erp_sellers', 'U') IS NOT NULL
    DROP TABLE bronze.erp_sellers;
GO
CREATE TABLE bronze.erp_sellers(
    seller_id              NVARCHAR(100),
    seller_zip_code_prefix INT,
    seller_city            NVARCHAR(100),
    seller_state           NVARCHAR(100)
);
GO
