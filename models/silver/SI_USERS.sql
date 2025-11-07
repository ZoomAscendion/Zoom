{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_USERS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_USERS', 'SI_USERS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTION_TRIGGER, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_USERS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_USERS', 'SI_USERS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
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
        -- Calculate data quality score based on completeness and validation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 100
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 75
            WHEN USER_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Set validation status based on quality score
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 'PASSED'
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM bronze_users
),

-- Remove duplicates keeping the latest record
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM validated_users
    WHERE validation_status IN ('PASSED', 'WARNING')
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
    data_quality_score AS DATA_QUALITY_SCORE,
    validation_status AS VALIDATION_STATUS
FROM deduped_users
WHERE rn = 1
