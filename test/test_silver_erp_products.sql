/*
===============================================================================
Data Quality Audit: silver.erp_products
===============================================================================
*/

-- 1. Deduplication Check
SELECT 'TC-01: Duplicate Products' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (SELECT product_id FROM silver.erp_products GROUP BY product_id HAVING COUNT(*) > 1) t

UNION ALL

-- 2. Category NULL Check
SELECT 'TC-02: Missing Categories', COUNT(*) 
FROM silver.erp_products WHERE product_category_name = 'N/A'

UNION ALL

-- 3. Logic Check: Impossible Dimensions
-- Flag products that have weight but no physical size (or vice versa)
SELECT 'TC-03: Impossible Dimensions', COUNT(*) 
FROM silver.erp_products 
WHERE (product_weight_g > 0 AND product_length_cm = 0)
   OR (product_length_cm > 1000); -- Flagging items over 10 meters as suspicious
GO