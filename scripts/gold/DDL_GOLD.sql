/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- 1. Create Dimension: gold.dim_customers
-- =============================================================================
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key, 
    customer_id                              AS customer_id, 
    customer_city                            AS city,
    customer_state                           AS state
FROM silver.crm_customers;
GO

-- =============================================================================
-- 2. Create Dimension: gold.dim_products
-- =============================================================================
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY p.product_id) AS product_key, 
    p.product_id                              AS product_id, 
    p.product_weight_g                        AS weight_grams,
    ISNULL(t.product_category_name_english, 'Other') AS product_category
FROM silver.erp_products p
LEFT JOIN silver.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;
GO

-- =============================================================================
-- 3. Create Fact Table: gold.fact_sales
-- =============================================================================
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    c.customer_key,
    p.product_key,
    o.order_id                           AS order_id,
    o.order_purchase_timestamp           AS order_date,
    -- Aggregated Business Metrics
    SUM(oi.price)                        AS item_revenue,
    SUM(oi.freight_value)                AS shipping_cost,
    SUM(oi.price + oi.freight_value)     AS total_sales_amount,
    COUNT(*)                             AS items_quantity
FROM silver.erp_orders o
INNER JOIN silver.erp_order_items oi 
    ON o.order_id = oi.order_id
LEFT JOIN gold.dim_customers c 
    ON o.customer_id = c.customer_id
LEFT JOIN gold.dim_products p 
    ON oi.product_id = p.product_id
GROUP BY 
    c.customer_key,
    p.product_key,
    o.order_id,
    o.order_purchase_timestamp;
GO