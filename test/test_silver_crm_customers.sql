/*
===============================================================================
Data Quality Audit: silver.crm_customers
===============================================================================
Expectation: Issue_Count = 0 for all tests.
===============================================================================
*/

-- 1. Check for Duplicate Primary Keys
SELECT 'TC-01: Deduplication Check' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (
    SELECT customer_id FROM silver.crm_customers GROUP BY customer_id HAVING COUNT(*) > 1
) t

UNION ALL

-- 2. Check for NULL values in critical columns
SELECT 'TC-02: NULL Value Check' AS Test_Name, COUNT(*) 
FROM silver.crm_customers 
WHERE customer_id IS NULL 
   OR customer_unique_id IS NULL 
   OR customer_city IS NULL 
   OR customer_state IS NULL

UNION ALL

-- 3. Check for formatting errors (Casing and Trimming)
SELECT 'TC-03: Casing & Trim Check' AS Test_Name, COUNT(*) 
FROM silver.crm_customers 
WHERE customer_city != UPPER(TRIM(customer_city)) 
   OR customer_state != UPPER(TRIM(customer_state))

UNION ALL

-- 4. Check for invalid State Codes (Must be 2 chars or 'NA')
SELECT 'TC-04: State Code Integrity' AS Test_Name, COUNT(*) 
FROM silver.crm_customers 
WHERE LEN(customer_state) != 2 AND customer_state != 'NA'

UNION ALL

-- 5. Check for data loss during transfer (Bronze Unique vs Silver Total)
SELECT 'TC-05: Row Count Reconciliation' AS Test_Name, 
    ABS((SELECT COUNT(DISTINCT customer_id) FROM bronze.crm_customers) - (SELECT COUNT(*) FROM silver.crm_customers));
GO
