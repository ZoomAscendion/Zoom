{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_START_TIME, EXECUTED_BY, LOAD_TIMESTAMP) SELECT 'SI_LICENSES', 'STARTED', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, STATUS, EXECUTION_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT 'SI_LICENSES', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Licenses Table
-- Purpose: Clean and standardized license assignments and entitlements
-- Transformation: Bronze BZ_LICENSES -> Silver SI_LICENSES

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
    FROM {{ source('bronze', 'BZ_LICENSES') }}
    WHERE LICENSE_ID IS NOT NULL
),

date_format_cleaning AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        -- Handle DD/MM/YYYY date format (Critical P1 fix for "27/08/2024" error)
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY')
            ELSE START_DATE
        END AS START_DATE,
        CASE 
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY')
            ELSE END_DATE
        END AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
),

data_quality_checks AS (
    SELECT 
        l.*,
        -- Date logic validation
        CASE 
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL AND l.START_DATE < l.END_DATE THEN 1
            ELSE 0
        END AS date_logic_valid,
        
        -- User reference validation
        CASE 
            WHEN u.USER_ID IS NOT NULL THEN 1
            ELSE 0
        END AS user_ref_valid,
        
        -- License type validation
        CASE 
            WHEN l.LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(l.LICENSE_TYPE)) > 0 THEN 1
            ELSE 0
        END AS license_type_valid,
        
        -- Calculate data quality score
        CASE 
            WHEN l.LICENSE_ID IS NOT NULL AND l.LICENSE_TYPE IS NOT NULL AND l.ASSIGNED_TO_USER_ID IS NOT NULL 
                 AND l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL THEN
                CASE 
                    WHEN l.START_DATE < l.END_DATE AND u.USER_ID IS NOT NULL 
                         AND LENGTH(TRIM(l.LICENSE_TYPE)) > 0 THEN 100
                    WHEN l.START_DATE < l.END_DATE AND LENGTH(TRIM(l.LICENSE_TYPE)) > 0 THEN 80
                    WHEN l.START_DATE < l.END_DATE THEN 60
                    ELSE 40
                END
            ELSE 0
        END AS data_quality_score
    FROM date_format_cleaning l
    LEFT JOIN {{ ref('SI_USERS') }} u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 80 THEN 'PASSED'
            WHEN data_quality_score >= 50 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
      AND LICENSE_ID IS NOT NULL
      AND ASSIGNED_TO_USER_ID IS NOT NULL
      AND START_DATE IS NOT NULL
      AND END_DATE IS NOT NULL
      AND START_DATE < END_DATE
)

SELECT * FROM cleaned_licenses
