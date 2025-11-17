{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) VALUES ('{{ invocation_id }}', 'SI_USERS', CURRENT_TIMESTAMP(), 'RUNNING', 'BRONZE.BZ_USERS', 'SILVER.SI_USERS', 'DBT_PIPELINE', CURRENT_TIMESTAMP())",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}) WHERE EXECUTION_ID = '{{ invocation_id }}' AND TARGET_TABLE = 'SILVER.SI_USERS'"
) }}

-- Silver Layer Users Table
-- Transforms and cleanses user data from Bronze layer
-- Applies data quality checks and standardization

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
),

cleansed_users AS (
    SELECT 
        -- Primary key validation
        USER_ID,
        
        -- Name standardization
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'UNKNOWN_USER'
            ELSE UPPER(TRIM(USER_NAME))
        END AS USER_NAME,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN 'no-email@unknown.com'
            WHEN NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'invalid-email@unknown.com'
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'UNKNOWN_COMPANY'
            ELSE UPPER(TRIM(COMPANY))
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END AS PLAN_TYPE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Silver layer specific fields
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_users
    WHERE USER_ID IS NOT NULL
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score (0-100)
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME != 'UNKNOWN_USER' 
                AND EMAIL != 'no-email@unknown.com' 
                AND EMAIL != 'invalid-email@unknown.com'
                AND COMPANY != 'UNKNOWN_COMPANY'
                AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 100
            WHEN USER_ID IS NOT NULL 
                AND (USER_NAME != 'UNKNOWN_USER' OR EMAIL NOT IN ('no-email@unknown.com', 'invalid-email@unknown.com'))
            THEN 75
            WHEN USER_ID IS NOT NULL
            THEN 50
            ELSE 0
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME != 'UNKNOWN_USER' 
                AND EMAIL NOT IN ('no-email@unknown.com', 'invalid-email@unknown.com')
            THEN 'PASSED'
            WHEN USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_users
),

-- Remove duplicates keeping the latest record
deduped_users AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
    )
    WHERE rn = 1
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_users
WHERE VALIDATION_STATUS != 'FAILED'
