{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_USERS', UUID_STRING(), 'BZ_USERS', 'SI_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_USERS' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Users transformation with data quality checks
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

validated_users AS (
    SELECT 
        USER_ID,
        -- Standardize user name
        CASE 
            WHEN USER_NAME IS NULL OR LENGTH(TRIM(USER_NAME)) = 0 OR LENGTH(USER_NAME) > 100 
            THEN 'UNKNOWN_USER'
            ELSE TRIM(UPPER(USER_NAME))
        END AS USER_NAME,
        -- Validate and standardize email
        CASE 
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
            THEN 'invalid@example.com'
            ELSE LOWER(TRIM(EMAIL))
        END AS EMAIL,
        -- Clean company name
        COALESCE(TRIM(COMPANY), 'UNKNOWN_COMPANY') AS COMPANY,
        -- Validate plan type
        CASE 
            WHEN UPPER(PLAN_TYPE) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE', 'EDUCATION') 
            THEN UPPER(PLAN_TYPE)
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_users
),

deduped_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_users
    WHERE rn = 1
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_users
