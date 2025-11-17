{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Licenses Table - Cleaned and standardized license assignments with critical date format conversion */

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

date_format_cleaning AS (
    SELECT 
        bl.*,
        /* Critical P1 Fix: Convert DD/MM/YYYY date format to Snowflake-compatible format */
        COALESCE(
            TRY_TO_DATE(bl.START_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(bl.START_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(bl.START_DATE, 'DD-MM-YYYY'),
            TRY_TO_DATE(bl.START_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(bl.START_DATE)
        ) AS CLEAN_START_DATE,
        
        COALESCE(
            TRY_TO_DATE(bl.END_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(bl.END_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(bl.END_DATE, 'DD-MM-YYYY'),
            TRY_TO_DATE(bl.END_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(bl.END_DATE)
        ) AS CLEAN_END_DATE
    FROM bronze_licenses bl
),

data_quality_checks AS (
    SELECT 
        dfc.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN dfc.LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN dfc.LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(dfc.LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN dfc.ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN dfc.CLEAN_START_DATE IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN dfc.CLEAN_END_DATE IS NOT NULL THEN 20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN dfc.LICENSE_ID IS NULL OR dfc.ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN dfc.LICENSE_TYPE IS NULL OR LENGTH(TRIM(dfc.LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN dfc.CLEAN_START_DATE IS NULL OR dfc.CLEAN_END_DATE IS NULL THEN 'FAILED'
            WHEN dfc.CLEAN_START_DATE >= dfc.CLEAN_END_DATE THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM date_format_cleaning dfc
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE LICENSE_ID IS NOT NULL
),

final_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        CLEAN_START_DATE AS START_DATE,
        CLEAN_END_DATE AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_licenses
