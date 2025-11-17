{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Licenses to Silver Licenses with enhanced date format validation */
/* Includes Critical P1 fix for DD/MM/YYYY date format conversion ("27/08/2024" error) */

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
),

/* Critical P1 Fix: Convert DD/MM/YYYY date formats */
clean_dates AS (
    SELECT 
        *,
        /* Multi-format date parsing for START_DATE */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'DD-MM-YYYY')
        ) AS CLEAN_START_DATE,
        
        /* Multi-format date parsing for END_DATE */
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'DD-MM-YYYY')
        ) AS CLEAN_END_DATE
    FROM bronze_licenses
),

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_START_DATE IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN CLEAN_END_DATE IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN CLEAN_END_DATE >= CLEAN_START_DATE THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_START_DATE IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_DATE IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN CLEAN_END_DATE >= CLEAN_START_DATE THEN 10 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_START_DATE IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN CLEAN_END_DATE IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN CLEAN_END_DATE >= CLEAN_START_DATE THEN 10 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM clean_dates
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    LICENSE_ID,
    UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    CLEAN_START_DATE AS START_DATE,
    COALESCE(CLEAN_END_DATE, DATEADD('year', 1, CLEAN_START_DATE)) AS END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
  AND CLEAN_START_DATE IS NOT NULL
