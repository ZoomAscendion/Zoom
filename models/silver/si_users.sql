{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_USR'), 'Silver_Users_ETL', CURRENT_TIMESTAMP(), 'Started', 'BRONZE.BZ_USERS', 'SILVER.SI_USERS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Processing users data from Bronze to Silver', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('EXEC_', TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), '_USR_END'), 'Silver_Users_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_SILVER_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'ZOOM_PLATFORM' WHERE '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Users Table Transformation
-- Transforms Bronze users data with data quality validations and standardization

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
    FROM {{ source('bronze', 'bz_users') }}
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Validations
validated_users AS (
    SELECT 
        USER_ID,
        -- Standardize user name with proper case formatting
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(USER_NAME))
        END AS USER_NAME,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN NULL
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(COMPANY)
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown Plan'
        END AS PLAN_TYPE,
        
        -- Derive registration date from load timestamp
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        
        -- Derive last login date from update timestamp
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        -- Derive account status from plan type and activity
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Calculate data quality score
        (
            CASE WHEN USER_ID IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 0.25 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND TRIM(USER_NAME) != '' THEN 0.25 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 0.25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_users
),

-- Remove duplicates keeping the latest record
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_users
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
FROM deduped_users
WHERE rn = 1
  AND EMAIL IS NOT NULL -- Block records without valid email
  AND DATA_QUALITY_SCORE >= 0.5 -- Only allow records with good quality score
