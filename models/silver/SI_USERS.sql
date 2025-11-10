{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_USERS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_USERS', 'SI_USERS', 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_USERS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_USERS', 'SI_USERS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'SCHEDULED', 'DBT_CLOUD', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver layer transformation for Users table
-- Applies data quality checks, standardization, and business rules

WITH bronze_users AS (
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
    WHERE USER_ID IS NOT NULL
),

-- Data quality validation and scoring
validated_users AS (
    SELECT 
        *,
        -- Data quality score calculation (0-100)
        CASE 
            WHEN USER_ID IS NULL THEN 0
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 30
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USER_ID IS NULL OR EMAIL IS NULL THEN 'FAILED'
            WHEN NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'FAILED'
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_users
),

-- Remove duplicates keeping latest record
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_users
    WHERE VALIDATION_STATUS != 'FAILED'
)

SELECT 
    USER_ID,
    TRIM(USER_NAME) AS USER_NAME,
    LOWER(TRIM(EMAIL)) AS EMAIL,
    TRIM(COMPANY) AS COMPANY,
    CASE 
        WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
        THEN UPPER(TRIM(PLAN_TYPE))
        ELSE 'FREE'
    END AS PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_users
WHERE rn = 1
