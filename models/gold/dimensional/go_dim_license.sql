{{ config(
    materialized='table'
) }}

-- License Dimension Table with SCD Type 2
WITH license_types AS (
    SELECT 'BASIC' AS LICENSE_TYPE_KEY, 'Zoom Basic' AS LICENSE_NAME
    UNION ALL
    SELECT 'PRO' AS LICENSE_TYPE_KEY, 'Zoom Pro' AS LICENSE_NAME
    UNION ALL
    SELECT 'ENTERPRISE' AS LICENSE_TYPE_KEY, 'Zoom Enterprise' AS LICENSE_NAME
),

license_attributes AS (
    SELECT 
        'DIM_LICENSE_' || LICENSE_TYPE_KEY || '_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS') AS DIM_LICENSE_ID,
        LICENSE_TYPE_KEY,
        LICENSE_NAME,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 'BASIC'
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 'PROFESSIONAL'
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 'ENTERPRISE'
        END AS LICENSE_TIER,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 0.00
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 14.99
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 19.99
        END AS MONTHLY_COST,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 0.00
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 149.90
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 199.90
        END AS ANNUAL_COST,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 100
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 500
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 1000
        END AS MAX_PARTICIPANTS,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 1
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 5
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 10
        END AS STORAGE_GB,
        CASE 
            WHEN LICENSE_TYPE_KEY = 'BASIC' THEN 'Basic meeting features, 40-minute limit'
            WHEN LICENSE_TYPE_KEY = 'PRO' THEN 'Advanced features, cloud recording, admin controls'
            WHEN LICENSE_TYPE_KEY = 'ENTERPRISE' THEN 'Enterprise security, advanced admin, unlimited cloud storage'
        END AS FEATURES_INCLUDED,
        '2020-01-01'::DATE AS EFFECTIVE_START_DATE,
        '9999-12-31'::DATE AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'BUSINESS_RULES' AS SOURCE_SYSTEM
    FROM license_types
)

SELECT * FROM license_attributes
