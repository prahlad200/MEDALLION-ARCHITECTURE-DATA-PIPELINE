/*
===============================================================================
Data Quality Audit: silver.crm_order_reviews
===============================================================================
Goal: Ensure no NULLs, no duplicates, and valid business logic.
===============================================================================
*/

-- 1. Deduplication Check: Ensures no review_id appears more than once.
SELECT 'TC-01: Duplicate Review ID' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (
    SELECT review_id FROM silver.crm_order_reviews GROUP BY review_id HAVING COUNT(*) > 1
) t

UNION ALL

-- 2. NULL/NA Placeholder Check: Ensures no raw NULLs exist in text fields.
SELECT 'TC-02: Hidden NULLs in Text', COUNT(*) 
FROM silver.crm_order_reviews 
WHERE review_comment_title IS NULL 
   OR review_comment_message IS NULL

UNION ALL

-- 3. 'N/A' Validation: Checks if titles/messages were correctly filled with placeholders.
-- This is just a count to see the volume of N/A data.
SELECT 'TC-03: Count of N/A Comments', COUNT(*) 
FROM silver.crm_order_reviews 
WHERE review_comment_title = 'N/A' 
   OR review_comment_message = 'N/A'

UNION ALL

-- 4. Score Logic Check: Ensures all ratings are within the 1-5 star range.
SELECT 'TC-04: Invalid Review Score', COUNT(*) 
FROM silver.crm_order_reviews 
WHERE review_score NOT BETWEEN 1 AND 5

UNION ALL

-- 5. Timeline Logic Check: Ensures the customer didn't answer before the review was created.
SELECT 'TC-05: Impossible Timestamps', COUNT(*) 
FROM silver.crm_order_reviews 
WHERE review_answers_timestamp < review_creation_date;
GO