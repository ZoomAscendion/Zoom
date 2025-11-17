{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_USERS', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_USERS', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_USERS: Cleaned and standardized user profile and subscription information
-- Transformation from Bronze BZ_USERS to Silver SI_USERS

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
    FROM BRONZE.BZ_USERS
    WHERE USER_ID IS NOT NULL
),

-- Data Quality Checks and Cleansing
cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data Quality Scoring
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 100
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') 
                 AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
            THEN 'PASSED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM bronze_users
),

-- Remove Duplicates (Keep latest record based on UPDATE_TIMESTAMP)
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
    FROM cleansed_users
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_users
WHERE rn = 1
  AND EMAIL IS NOT NULL
  AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
