/*
===============================================================================
Data Quality Audit: silver.erp_orders
===============================================================================
*/

-- 1. Deduplication Check (Primary Key Integrity)
SELECT 'TC-01: Duplicate Order IDs' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (SELECT order_id FROM silver.erp_orders GROUP BY order_id HAVING COUNT(*) > 1) t

UNION ALL

-- 2. Date Logic Check: Delivery vs. Purchase
-- Flags rows where delivery happened BEFORE the purchase (Impossible)
SELECT 'TC-02: Delivery Before Purchase', COUNT(*) 
FROM silver.erp_orders 
WHERE order_delivered_customer_date < order_purchase_timestamp

UNION ALL

-- 3. Date Logic Check: Approval vs. Purchase
-- Flags rows where approval happened BEFORE the purchase (Impossible)
SELECT 'TC-03: Approval Before Purchase', COUNT(*) 
FROM silver.erp_orders 
WHERE order_approved_at < order_purchase_timestamp

UNION ALL

-- 4. Status Consistency
-- Ensure no orders have an empty or invalid status string
SELECT 'TC-04: Missing Order Status', COUNT(*) 
FROM silver.erp_orders WHERE order_status IS NULL OR order_status = '';
GO