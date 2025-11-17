{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_LICENSES', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_LICENSES', 'SI_LICENSES', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_LICENSES', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_LICENSES', 'SI_LICENSES', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer
-- Applies data quality validations and business rules

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
),

-- Data Quality and Validation Layer
validated_licenses AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN LICENSE_ID IS NULL THEN 0 ELSE 1 END AS license_id_valid,
        CASE WHEN LICENSE_TYPE IS NULL THEN 0 ELSE 1 END AS license_type_valid,
        CASE WHEN ASSIGNED_TO_USER_ID IS NULL THEN 0 ELSE 1 END AS assigned_user_valid,
        CASE WHEN START_DATE IS NULL THEN 0 ELSE 1 END AS start_date_valid,
        CASE WHEN END_DATE IS NULL THEN 0 ELSE 1 END AS end_date_valid,
        
        -- Business logic validation
        CASE WHEN END_DATE >= START_DATE THEN 1 ELSE 0 END AS date_logic_valid,
        CASE WHEN LENGTH(LICENSE_TYPE) <= 100 THEN 1 ELSE 0 END AS license_type_length_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN LICENSE_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN LICENSE_TYPE IS NULL THEN 0 ELSE 20 END +
            CASE WHEN ASSIGNED_TO_USER_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN START_DATE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN END_DATE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN END_DATE >= START_DATE THEN 10 ELSE 0 END
        ), 0) AS data_quality_score
    FROM bronze_licenses
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_licenses AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_licenses
    WHERE LICENSE_ID IS NOT NULL  -- Remove null license IDs
),

-- Final transformation layer
final_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
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
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_licenses
    WHERE row_num = 1  -- Keep only the latest record per license
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND END_DATE >= START_DATE  -- Ensure valid date logic
)

SELECT * FROM final_licenses
