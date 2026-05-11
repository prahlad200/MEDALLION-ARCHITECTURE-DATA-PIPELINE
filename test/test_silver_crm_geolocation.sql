/*
===============================================================================
Data Quality Audit: silver.crm_geolocation
===============================================================================
Expectation: All Issue_Counts should be 0.
===============================================================================
*/

-- 1. Check for Duplicate Coordinate Points (Composite Key Check)
SELECT 'TC-01: Duplicate Coordinate Check' AS Test_Name, COUNT(*) AS Issue_Count 
FROM (
    SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng 
    FROM silver.crm_geolocation 
    GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng 
    HAVING COUNT(*) > 1
) t

UNION ALL

-- 2. Check for NULL values in critical mapping columns
SELECT 'TC-02: NULL Value Check' AS Test_Name, COUNT(*) 
FROM silver.crm_geolocation 
WHERE geolocation_zip_code_prefix IS NULL 
   OR geolocation_lat IS NULL 
   OR geolocation_lng IS NULL

UNION ALL

-- 3. Check for formatting errors (Casing and Trimming)
SELECT 'TC-03: Casing & Trim Check' AS Test_Name, COUNT(*) 
FROM silver.crm_geolocation 
WHERE geolocation_city != UPPER(TRIM(geolocation_city)) 
   OR geolocation_state != UPPER(TRIM(geolocation_state))

UNION ALL

-- 4. Check for coordinate precision (Latitude range -90 to 90)
SELECT 'TC-04: Lat/Lng Range Check' AS Test_Name, COUNT(*) 
FROM silver.crm_geolocation 
WHERE geolocation_lat < -90 OR geolocation_lat > 90
   OR geolocation_lng < -180 OR geolocation_lng > 180

UNION ALL

-- 5. Row Count Reconciliation (Unique Coordinate Points Bronze vs Total Silver)
SELECT 'TC-05: Row Count Reconciliation' AS Test_Name, 
    ABS(
        (SELECT COUNT(*) FROM (SELECT DISTINCT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng FROM bronze.crm_geolocation) sub) 
        - (SELECT COUNT(*) FROM silver.crm_geolocation)
    );
GO