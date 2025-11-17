{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP)
        VALUES (UUID_STRING(), 'SI_LICENSES', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_LICENSES', '{{ this.schema }}.SI_LICENSES', 'DBT_PIPELINE', CURRENT_TIMESTAMP())
    ",
    post_hook="
        UPDATE {{ ref('SI_AUDIT_LOG') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), 
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            UPDATE_TIMESTAMP = CURRENT_TIMESTAMP()
        WHERE TARGET_TABLE = '{{ this.schema }}.SI_LICENSES' 
        AND EXECUTION_STATUS = 'STARTED'
        AND EXECUTION_START_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
    "
) }}

-- Silver Layer Licenses Table
-- Purpose: Clean and standardized license assignments and entitlements
-- Transformation: Bronze to Silver with data quality validations

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

data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN LICENSE_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN LICENSE_TYPE IS NOT NULL AND LENGTH(TRIM(LICENSE_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN START_DATE IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN END_DATE IS NOT NULL AND END_DATE >= START_DATE THEN 20 ELSE 0 END
        AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN LICENSE_ID IS NULL OR LICENSE_TYPE IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN START_DATE IS NULL OR END_DATE IS NULL THEN 'FAILED'
            WHEN END_DATE < START_DATE THEN 'FAILED'
            WHEN LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_licenses
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING') -- Exclude FAILED records
)

SELECT * FROM final_transformation
