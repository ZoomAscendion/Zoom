{{ config(
    materialized='table'
) }}

-- Silver layer transformation for Users table
-- Applies data quality checks, standardization, and business rules

WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_USERS') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality validations
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 25 END +
        CASE WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 0 ELSE 25 END +
        CASE WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0 ELSE 25 END +
        CASE WHEN USER_NAME IS NULL OR LENGTH(TRIM(USER_NAME)) = 0 THEN 0 ELSE 25 END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN USER_ID IS NULL OR EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'FAILED'
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') OR USER_NAME IS NULL THEN 'WARNING'
            ELSE 'PASSED'
        END AS validation_status
    FROM source_data
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status != 'FAILED'  -- Exclude failed records
),

final_transformation AS (
    SELECT 
        USER_ID,
        COALESCE(TRIM(USER_NAME), 'Unknown') AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        COALESCE(TRIM(COMPANY), 'Unknown') AS COMPANY,
        COALESCE(
            CASE 
                WHEN UPPER(TRIM(PLAN_TYPE)) = 'FREE' THEN 'Free'
                WHEN UPPER(TRIM(PLAN_TYPE)) = 'BASIC' THEN 'Basic'
                WHEN UPPER(TRIM(PLAN_TYPE)) = 'PRO' THEN 'Pro'
                WHEN UPPER(TRIM(PLAN_TYPE)) = 'ENTERPRISE' THEN 'Enterprise'
                ELSE 'Free'
            END, 'Free'
        ) AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1  -- Keep only the latest record per USER_ID
)

SELECT * FROM final_transformation
