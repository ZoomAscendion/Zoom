{{
    config(
        materialized='table',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Licenses Transformation
-- Transforms Bronze layer license data with assignment and management validations

WITH bronze_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND ASSIGNED_TO_USER_ID IS NOT NULL
),

-- Join with users to get user information
licenses_with_user AS (
    SELECT 
        l.LICENSE_ID,
        l.ASSIGNED_TO_USER_ID,
        l.LICENSE_TYPE,
        l.START_DATE,
        l.END_DATE,
        l.LOAD_TIMESTAMP,
        l.UPDATE_TIMESTAMP,
        l.SOURCE_SYSTEM,
        COALESCE(u.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME
    FROM bronze_licenses l
    LEFT JOIN {{ ref('si_users') }} u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
),

-- Data Quality Validations and Cleansing
licenses_cleaned AS (
    SELECT 
        LICENSE_ID,
        ASSIGNED_TO_USER_ID,
        
        -- Standardize license type
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BASIC', 'FREE') THEN 'Basic'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENT') THEN 'Enterprise'
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ADD-ON', 'ADDON', 'ADDITIONAL') THEN 'Add-on'
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        
        -- Validate start date
        CASE 
            WHEN START_DATE > CURRENT_DATE() + INTERVAL '1' YEAR THEN CURRENT_DATE()
            WHEN START_DATE < '2020-01-01' THEN '2020-01-01'
            ELSE START_DATE
        END AS START_DATE,
        
        -- Validate end date and ensure it's after start date
        CASE 
            WHEN END_DATE < START_DATE THEN START_DATE + INTERVAL '1' YEAR
            WHEN END_DATE > CURRENT_DATE() + INTERVAL '5' YEAR THEN CURRENT_DATE() + INTERVAL '1' YEAR
            ELSE END_DATE
        END AS END_DATE,
        
        -- Derive license status from dates
        CASE 
            WHEN END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN START_DATE > CURRENT_DATE() THEN 'Pending'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        
        ASSIGNED_USER_NAME,
        
        -- Derive license cost from type
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BASIC', 'FREE') THEN 0.00
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 14.99
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENT') THEN 19.99
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ADD-ON', 'ADDON', 'ADDITIONAL') THEN 5.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        -- Derive renewal status
        CASE 
            WHEN END_DATE - CURRENT_DATE() <= 30 THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Calculate utilization percentage (simplified logic)
        CASE 
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('ENTERPRISE', 'ENT') THEN 85.0
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('PRO', 'PROFESSIONAL') THEN 70.0
            WHEN UPPER(TRIM(LICENSE_TYPE)) IN ('BASIC', 'FREE') THEN 45.0
            ELSE 50.0
        END AS UTILIZATION_PERCENTAGE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN LICENSE_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN LICENSE_TYPE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN START_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
            CASE WHEN END_DATE IS NOT NULL AND END_DATE >= START_DATE THEN 0.2 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM licenses_with_user
),

-- Remove duplicates keeping the latest record
licenses_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM licenses_cleaned
)

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
FROM licenses_deduped
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.80  -- Only allow records with at least 80% data quality
