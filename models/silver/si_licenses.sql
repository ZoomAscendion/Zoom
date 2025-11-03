{{ config(
    materialized='table'
) }}

-- Silver Layer Licenses Table
-- Transforms Bronze licenses data with validation and license management standardization

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
        AND ASSIGNED_TO_USER_ID IS NOT NULL
),

-- Get user names for license assignment
user_info AS (
    SELECT 
        USER_ID,
        USER_NAME
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
licenses_cleaned AS (
    SELECT 
        -- Primary identifiers
        bl.LICENSE_ID,
        bl.ASSIGNED_TO_USER_ID,
        
        -- License type standardization
        CASE 
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') 
                THEN INITCAP(bl.LICENSE_TYPE)
            ELSE 'Unknown License'
        END AS LICENSE_TYPE,
        
        -- Date validation and correction
        CASE 
            WHEN bl.START_DATE > CURRENT_DATE() + INTERVAL '1 YEAR' THEN CURRENT_DATE()
            ELSE COALESCE(bl.START_DATE, CURRENT_DATE())
        END AS START_DATE,
        
        CASE 
            WHEN bl.END_DATE < bl.START_DATE 
                THEN DATEADD('year', 1, COALESCE(bl.START_DATE, CURRENT_DATE()))
            WHEN bl.END_DATE IS NULL
                THEN DATEADD('year', 1, COALESCE(bl.START_DATE, CURRENT_DATE()))
            ELSE bl.END_DATE
        END AS END_DATE,
        
        -- License status derivation
        CASE 
            WHEN COALESCE(bl.END_DATE, DATEADD('year', 1, CURRENT_DATE())) > CURRENT_DATE() THEN 'Active'
            WHEN COALESCE(bl.END_DATE, DATEADD('year', 1, CURRENT_DATE())) <= CURRENT_DATE() THEN 'Expired'
            ELSE 'Suspended'
        END AS LICENSE_STATUS,
        
        -- Assigned user name from join
        COALESCE(ui.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        
        -- License cost derivation
        CASE 
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'BASIC' THEN 0.00
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'PRO' THEN 14.99
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'ENTERPRISE' THEN 19.99
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'ADD-ON' THEN 5.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        -- Renewal status derivation
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), COALESCE(bl.END_DATE, DATEADD('year', 1, CURRENT_DATE()))) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Utilization percentage (estimated)
        CASE 
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'ENTERPRISE' THEN 85.5
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'PRO' THEN 72.3
            WHEN UPPER(TRIM(COALESCE(bl.LICENSE_TYPE, ''))) = 'BASIC' THEN 45.2
            ELSE 60.0
        END AS UTILIZATION_PERCENTAGE,
        
        -- Metadata columns
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN bl.LICENSE_ID IS NOT NULL 
                AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
                AND bl.LICENSE_TYPE IS NOT NULL
                AND bl.START_DATE IS NOT NULL
                AND bl.END_DATE IS NOT NULL
                AND bl.END_DATE >= bl.START_DATE
                THEN 1.00
            WHEN bl.LICENSE_ID IS NOT NULL AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
                THEN 0.75
            WHEN bl.LICENSE_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        bl.LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        bl.UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY bl.LICENSE_ID ORDER BY bl.UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_licenses bl
    LEFT JOIN user_info ui ON bl.ASSIGNED_TO_USER_ID = ui.USER_ID
),

-- Final selection with data quality filters
licenses_final AS (
    SELECT 
        LICENSE_ID,
        ASSIGNED_TO_USER_ID,
        LICENSE_TYPE,
        START_DATE,
        END_DATE,
        LICENSE_STATUS,
        ASSIGNED_USER_NAME,
        LICENSE_COST,
        RENEWAL_STATUS,
        UTILIZATION_PERCENTAGE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATA_QUALITY_SCORE,
        LOAD_DATE,
        UPDATE_DATE
    FROM licenses_cleaned
    WHERE rn = 1  -- Deduplication
        AND END_DATE >= START_DATE  -- Ensure valid date range
)

SELECT * FROM licenses_final
