/*
===============================================================================
Data Quality Audit: silver.erp_order_items
===============================================================================
Expectation: Issue_Count = 0 for all tests.
===============================================================================
*/

-- 1. Check for Duplicate Line Items (Composite Key Check)
SELECT 'TC-01: Duplicate Order Items' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (
    SELECT order_id, order_item_id FROM silver.erp_order_items 
    GROUP BY order_id, order_item_id HAVING COUNT(*) > 1
) t

UNION ALL

-- 2. Check for Negative Pricing (Financial Data Integrity)
SELECT 'TC-02: Negative Money Check', COUNT(*) 
FROM silver.erp_order_items 
WHERE price < 0 OR freight_value < 0

UNION ALL

-- 3. Check for NULL Primary Keys
SELECT 'TC-03: Null ID Check', COUNT(*) 
FROM silver.erp_order_items 
WHERE order_id IS NULL OR product_id IS NULL;
GO