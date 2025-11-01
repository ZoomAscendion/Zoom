{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_USERS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_USERS_TRANSFORM', CURRENT_TIMESTAMP(), 'STARTED', 'BRONZE.BZ_USERS', 'SILVER.SI_USERS', 'DBT_PIPELINE', 'PROD', 'User data transformation with validation', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="INSERT INTO {{ ref('audit_log') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, RECORDS_PROCESSED, RECORDS_INSERTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(["'SI_USERS'", 'CURRENT_TIMESTAMP()']) }}', 'SI_USERS_TRANSFORM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PROD', 'User data transformation completed', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'"
) }}

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
      AND TRIM(USER_ID) != ''
),

-- Data quality validation and cleansing
cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(INITCAP(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(INITCAP(COMPANY)) AS COMPANY,
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') THEN UPPER(PLAN_TYPE)
            ELSE 'FREE'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS REGISTRATION_DATE,
        DATE(UPDATE_TIMESTAMP) AS LAST_LOGIN_DATE,
        CASE 
            WHEN UPDATE_TIMESTAMP >= DATEADD('day', -30, CURRENT_DATE()) THEN 'Active'
            WHEN UPDATE_TIMESTAMP >= DATEADD('day', -90, CURRENT_DATE()) THEN 'Inactive'
            ELSE 'Suspended'
        END AS ACCOUNT_STATUS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_users
),

-- Data quality scoring
quality_scored_users AS (
    SELECT 
        *,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
                 AND USER_NAME IS NOT NULL AND TRIM(USER_NAME) != ''
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 1.00
            WHEN EMAIL IS NOT NULL AND USER_NAME IS NOT NULL
            THEN 0.75
            WHEN USER_ID IS NOT NULL
            THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE
    FROM cleansed_users
),

-- Remove duplicates using ROW_NUMBER
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM quality_scored_users
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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_users
WHERE rn = 1
  AND DATA_QUALITY_SCORE >= 0.50  -- Only include records with acceptable quality
