{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Licenses table
-- Applies data quality checks and date validation

WITH source_data AS (
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
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality validations
        CASE WHEN LICENSE_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 0 ELSE 20 END +
        CASE WHEN ASSIGNED_TO_USER_ID IS NULL THEN 0 ELSE 20 END +
        CASE WHEN START_DATE IS NULL THEN 0 ELSE 20 END +
        CASE WHEN END_DATE IS NULL OR END_DATE < START_DATE THEN 0 ELSE 20 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN START_DATE IS NULL OR END_DATE IS NULL THEN 'FAILED'
            WHEN END_DATE < START_DATE THEN 'FAILED'
            ELSE 'PASSED'
        END AS validation_status
    FROM source_data
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per LICENSE_ID
)

SELECT * FROM final_transformation
