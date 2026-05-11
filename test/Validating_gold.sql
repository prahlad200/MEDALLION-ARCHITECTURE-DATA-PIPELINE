/* =============================================================================
GOLD LAYER MASTER VALIDATION: Olist Data Warehouse
=============================================================================
Check 1: Orphaned Keys (Referential Integrity)
Check 2: Financial Balance (Gold vs Silver Totals)
Check 3: Logical Accuracy (Count of Categorized Products)
=============================================================================
*/

SELECT 
    'Referential Integrity' AS check_type,
    'Orphaned Product Keys' AS metric,
    COUNT(*) AS value
FROM gold.fact_sales 
WHERE product_key IS NULL

UNION ALL

SELECT 
    'Referential Integrity',
    'Orphaned Customer Keys',
    COUNT(*)
FROM gold.fact_sales 
WHERE customer_key IS NULL

UNION ALL

SELECT 
    'Financial Balance',
    'Total Revenue Variance (ERP vs Gold)',
    (SELECT SUM(price + freight_value) FROM silver.erp_order_items) - 
    (SELECT SUM(total_sales_amount) FROM gold.fact_sales)

UNION ALL

SELECT 
    'Logical Completeness',
    'Unmapped Product Categories (Total)',
    COUNT(*)
FROM gold.dim_products 
WHERE product_category = 'Other';