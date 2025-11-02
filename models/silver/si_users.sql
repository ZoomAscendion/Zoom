{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT 'EXEC_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_PIPELINE', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_USERS', 'SI_USERS', 'DBT_SILVER_PIPELINE', 'PROD', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AUDIT_LOG')",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT 'EXEC_USERS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_USERS_PIPELINE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'Success', COUNT(*), COUNT(*), 'BZ_USERS', 'SI_USERS', 'DBT_SILVER_PIPELINE', 'PROD', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' FROM {{ this }} WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AUDIT_LOG')"
) }}

-- Silver Layer Users Model
-- Transforms bronze users data with data quality validations and standardization

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN 'MISSING_EMAIL'
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'INVALID_EMAIL_FORMAT'
            ELSE 'VALID'
        END AS EMAIL_QUALITY_FLAG,
        
        -- Plan type validation
        CASE 
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'INVALID_PLAN_TYPE'
            ELSE 'VALID'
        END AS PLAN_TYPE_QUALITY_FLAG,
        
        -- Temporal validation
        CASE 
            WHEN LOAD_TIMESTAMP > CURRENT_TIMESTAMP() + INTERVAL '1' DAY THEN 'FUTURE_TIMESTAMP'
            WHEN UPDATE_TIMESTAMP < LOAD_TIMESTAMP THEN 'TEMPORAL_ANOMALY'
            ELSE 'VALID'
        END AS TEMPORAL_QUALITY_FLAG
        
    FROM bronze_users
),

-- Deduplication Layer - Keep latest record per USER_ID
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
    WHERE EMAIL_QUALITY_FLAG != 'MISSING_EMAIL'  -- Block records with missing email
),

-- Transformation Layer
transformed_users AS (
    SELECT 
        -- Primary identifier
        USER_ID,
        
        -- Standardized business columns
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(INITCAP(COMPANY)) AS COMPANY,
        
        -- Standardized plan type
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown'
        END AS PLAN_TYPE,
        
        -- Derived fields
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        -- Account status derivation
        CASE 
            WHEN PLAN_TYPE = 'Free' AND UPDATE_TIMESTAMP < DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Inactive'
            WHEN PLAN_TYPE IN ('Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Active'
        END AS ACCOUNT_STATUS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN EMAIL_QUALITY_FLAG = 'VALID' 
                 AND PLAN_TYPE_QUALITY_FLAG = 'VALID' 
                 AND TEMPORAL_QUALITY_FLAG = 'VALID' 
            THEN 1.00
            WHEN EMAIL_QUALITY_FLAG = 'VALID' 
                 AND (PLAN_TYPE_QUALITY_FLAG != 'VALID' OR TEMPORAL_QUALITY_FLAG != 'VALID')
            THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM deduped_users
    WHERE rn = 1
      AND EMAIL_QUALITY_FLAG != 'MISSING_EMAIL'  -- Ensure no null emails in silver
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    REGISTRATION_DATE,
    LAST_LOGIN_DATE,
    ACCOUNT_STATUS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM transformed_users
WHERE DATA_QUALITY_SCORE >= 0.60  -- Only allow records with acceptable quality
