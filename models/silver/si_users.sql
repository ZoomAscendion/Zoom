{{
  config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, LOAD_DATE, SOURCE_SYSTEM) SELECT 'EXEC_USERS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SILVER_USERS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_USERS', 'SILVER.SI_USERS', CURRENT_USER(), 'PROD', CURRENT_DATE(), 'BRONZE_LAYER' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET END_TIME = CURRENT_TIMESTAMP(), STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE PIPELINE_NAME = 'SILVER_USERS_TRANSFORM' AND END_TIME IS NULL AND '{{ this.name }}' != 'si_pipeline_audit'"
  )
}}

-- Silver Layer Users Model
-- Description: Transform and cleanse bronze users data to silver layer with data quality validations
-- Source: BRONZE.BZ_USERS
-- Target: SILVER.SI_USERS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

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

-- Data Quality Validation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Email validation
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN 0.0
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') THEN 0.2
            ELSE 1.0
        END AS email_quality_score,
        
        -- Plan type validation
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 1.0
            WHEN PLAN_TYPE IS NULL THEN 0.0
            ELSE 0.5
        END AS plan_type_quality_score,
        
        -- User name validation
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 0.0
            WHEN LENGTH(TRIM(USER_NAME)) < 2 THEN 0.3
            ELSE 1.0
        END AS user_name_quality_score
    FROM bronze_users
),

-- Apply data transformations and cleansing
transformed_users AS (
    SELECT 
        -- Primary key
        USER_ID,
        
        -- Cleansed business columns
        CASE 
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'Unknown User'
            ELSE TRIM(INITCAP(USER_NAME))
        END AS USER_NAME,
        
        CASE 
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' THEN NULL
            WHEN NOT REGEXP_LIKE(LOWER(TRIM(EMAIL)), '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$') THEN NULL
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        
        CASE 
            WHEN COMPANY IS NULL OR TRIM(COMPANY) = '' THEN 'Unknown Company'
            ELSE TRIM(INITCAP(COMPANY))
        END AS COMPANY,
        
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        
        -- Derived columns
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN 'Active'
            ELSE 'Inactive'
        END AS ACCOUNT_STATUS,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        ROUND((email_quality_score + plan_type_quality_score + user_name_quality_score) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Standard audit columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM data_quality_checks
    WHERE USER_ID IS NOT NULL
),

-- Deduplication layer - keep latest record per user
deduped_users AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM transformed_users
),

-- Final output with audit columns
final_users AS (
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
        UPDATE_DATE,
        
        -- Process audit columns
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT,
        'SUCCESS' AS PROCESS_STATUS
        
    FROM deduped_users
    WHERE rn = 1
      AND DATA_QUALITY_SCORE >= 0.5  -- Only high quality records proceed to Silver
)

SELECT * FROM final_users
