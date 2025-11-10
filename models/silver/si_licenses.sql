{{ config(
    materialized='table'
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer
-- Handles multiple date formats including DD/MM/YYYY

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
),

-- Date Format Validation and Conversion
date_processed AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        -- Handle multiple date formats for START_DATE
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                COALESCE(
                    TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
                    TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY')
                )
            WHEN START_DATE::STRING REGEXP '^\\d{4}-\\d{1,2}-\\d{1,2}$' THEN 
                TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD')
            ELSE START_DATE
        END AS START_DATE,
        
        -- Handle multiple date formats for END_DATE
        CASE 
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' THEN 
                COALESCE(
                    TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
                    TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY')
                )
            WHEN END_DATE::STRING REGEXP '^\\d{4}-\\d{1,2}-\\d{1,2}$' THEN 
                TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD')
            ELSE END_DATE
        END AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Track date format issues
        CASE 
            WHEN START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' 
                 AND TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NULL 
                 AND TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY') IS NULL THEN 'START_DATE_FORMAT_ERROR'
            WHEN END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$' 
                 AND TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NULL 
                 AND TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY') IS NULL THEN 'END_DATE_FORMAT_ERROR'
            ELSE 'FORMAT_OK'
        END AS DATE_FORMAT_STATUS
    FROM bronze_licenses
),

-- Data Quality and Transformation Layer
cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE_FORMAT_STATUS,
        
        -- Data Quality Scoring
        CASE 
            WHEN LICENSE_ID IS NULL THEN 0
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 20
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 30
            WHEN START_DATE IS NULL OR END_DATE IS NULL THEN 40
            WHEN DATE_FORMAT_STATUS IN ('START_DATE_FORMAT_ERROR', 'END_DATE_FORMAT_ERROR') THEN 45
            WHEN START_DATE >= END_DATE THEN 50
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN START_DATE IS NULL OR END_DATE IS NULL THEN 'FAILED'
            WHEN DATE_FORMAT_STATUS IN ('START_DATE_FORMAT_ERROR', 'END_DATE_FORMAT_ERROR') THEN 'FAILED'
            WHEN START_DATE >= END_DATE THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM date_processed
),

-- Remove duplicates - keep latest record
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_licenses
    WHERE LICENSE_ID IS NOT NULL
      AND DATE_FORMAT_STATUS = 'FORMAT_OK'
)

-- Final Select with Silver layer metadata
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
