/*
===============================================================================
Data Quality Audit: silver.erp_sellers
===============================================================================
*/

-- 1. Deduplication Check
SELECT 'TC-01: Duplicate Seller IDs' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (SELECT seller_id FROM silver.erp_sellers GROUP BY seller_id HAVING COUNT(*) > 1) t

UNION ALL

-- 2. State Format Check (Should be 2 characters)
SELECT 'TC-02: Invalid State Code', COUNT(*) 
FROM silver.erp_sellers WHERE LEN(seller_state) != 2

UNION ALL

-- 3. NULL/Empty Value Check
SELECT 'TC-03: Missing Location Data', COUNT(*) 
FROM silver.erp_sellers 
WHERE seller_city IS NULL OR seller_city = '' 
   OR seller_state IS NULL OR seller_state = '';
GO