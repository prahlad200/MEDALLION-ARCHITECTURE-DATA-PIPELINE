/*
===============================================================================
Data Quality Audit: silver.erp_order_payments
===============================================================================
*/

-- 1. Deduplication Check (Composite Key)
SELECT 'TC-01: Duplicate Payment Seq' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (SELECT order_id, payment_sequential FROM silver.erp_order_payments GROUP BY order_id, payment_sequential HAVING COUNT(*) > 1) t

UNION ALL

-- 2. Financial Logic Check (Zero or Negative payments shouldn't exist)
SELECT 'TC-02: Zero/Negative Payment', COUNT(*) 
FROM silver.erp_order_payments WHERE payment_value <= 0

UNION ALL

-- 3. Business Logic: Installment Check
-- Orders with 0 installments are usually technical errors in the source
SELECT 'TC-03: Zero Installment Check', COUNT(*) 
FROM silver.erp_order_payments WHERE payment_installments < 1;
GO