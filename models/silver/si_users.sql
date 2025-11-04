{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT CONCAT('SILVER_USERS_', DATE_PART('epoch', CURRENT_TIMESTAMP())::STRING), 'SI_USERS_ETL', CURRENT_TIMESTAMP(), 'In Progress', 'BZ_USERS', 'SI_USERS', 'DBT_SILVER_PIPELINE', 'PRODUCTION', 'Bronze to Silver Users transformation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'Success', EXECUTION_DURATION_SECONDS = DATEDIFF('second', START_TIME, CURRENT_TIMESTAMP()), RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SI_USERS_ETL' AND STATUS = 'In Progress' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Users Table
-- Cleaned and standardized user data with data quality validations
-- Source: Bronze.BZ_USERS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Checks and Cleansing
cleansed_users AS (
    SELECT
        -- Primary identifier with validation
        USER_ID,
        
        -- Standardized user name with proper formatting
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(UPPER(USER_NAME))
        END AS USER_NAME,
        
        -- Email validation and standardization
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                THEN LOWER(TRIM(EMAIL))
            ELSE NULL
        END AS EMAIL,
        
        -- Company standardization
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(INITCAP(COMPANY))
        END AS COMPANY,
        
        -- Plan type standardization
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Unknown Plan'
        END AS PLAN_TYPE,
        
        -- Derived fields
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS REGISTRATION_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS LAST_LOGIN_DATE,
        
        -- Account status derivation
        CASE 
            WHEN PLAN_TYPE IN ('Pro', 'Enterprise') THEN 'Active'
            WHEN PLAN_TYPE = 'Basic' THEN 'Active'
            WHEN PLAN_TYPE = 'Free' THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL AND TRIM(USER_NAME) != ''
                AND EMAIL IS NOT NULL AND REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
                THEN 1.00
            WHEN USER_ID IS NOT NULL AND USER_NAME IS NOT NULL
                THEN 0.75
            WHEN USER_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        COALESCE(LOAD_TIMESTAMP::DATE, CURRENT_DATE()) AS LOAD_DATE,
        COALESCE(UPDATE_TIMESTAMP::DATE, CURRENT_DATE()) AS UPDATE_DATE
        
    FROM bronze_users
    WHERE USER_ID IS NOT NULL  -- Block records without primary key
),

-- Deduplication - keep latest record per user
deduped_users AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_users
)

-- Final selection with data quality validation
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
  AND DATA_QUALITY_SCORE >= 0.50  -- Minimum quality threshold
