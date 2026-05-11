/*
===============================================================================
Data Quality Audit: silver.product_category_name_translation
===============================================================================
*/

-- 1. Uniqueness Check (Test Case 1)
-- Ensures each Portuguese category maps to exactly one English translation.
SELECT 'TC-01: Duplicate Portuguese Categories' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (
    SELECT product_category_name 
    FROM silver.product_category_name_translation 
    GROUP BY product_category_name 
    HAVING COUNT(*) > 1
) t

UNION ALL

-- 2. Completeness Check (Test Case 2)
-- Ensures there are no missing (NULL) values on either side of the mapping.
SELECT 'TC-02: Missing Translations (NULLs)', COUNT(*) 
FROM silver.product_category_name_translation 
WHERE product_category_name IS NULL 
   OR product_category_name_english IS NULL

UNION ALL

-- 3. Literal Underscore Check (Test Case 3)
-- Uses [ _ ] to verify the literal underscore character is gone from both columns.
SELECT 'TC-03: Remaining Underscores', COUNT(*) 
FROM silver.product_category_name_translation 
WHERE product_category_name LIKE '%[_]%' 
   OR product_category_name_english LIKE '%[_]%'

UNION ALL

-- 4. Case Sensitivity Check (Test Case 4)
-- Verifies that all text has been successfully converted to UPPERCASE.
SELECT 'TC-04: Lowercase Letters Found', COUNT(*) 
FROM silver.product_category_name_translation 
WHERE product_category_name COLLATE Latin1_General_BIN2 LIKE '%[a-z]%'
   OR product_category_name_english COLLATE Latin1_General_BIN2 LIKE '%[a-z]%'

UNION ALL

-- 5. Row Count Verification (Test Case 5)
-- Confirms the table contains the expected 71 unique categories.
SELECT 'TC-05: Total Category Count', COUNT(*) 
FROM silver.product_category_name_translation;
GO