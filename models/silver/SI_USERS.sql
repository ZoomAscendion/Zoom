{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_START_TIME, AUDIT_TIMESTAMP) SELECT 'SI_USERS', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (TABLE_NAME, PROCESS_STATUS, PROCESS_END_TIME, RECORDS_PROCESSED, RECORDS_SUCCESS, AUDIT_TIMESTAMP) SELECT 'SI_USERS', 'COMPLETED', CURRENT_TIMESTAMP(), (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }} WHERE VALIDATION_STATUS = 'PASSED'), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Users Table
-- Transforms and cleanses user data from Bronze layer

WITH bronze_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM {{ source('bronze', 'BZ_USERS') }}
    WHERE USER_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Email format validation
        CASE 
            WHEN EMAIL IS NULL THEN 0
            WHEN NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 20
            ELSE 30
        END +
        -- Plan type validation
        CASE 
            WHEN PLAN_TYPE IS NULL THEN 0
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 10
            ELSE 30
        END +
        -- User name validation
        CASE 
            WHEN USER_NAME IS NULL OR LENGTH(TRIM(USER_NAME)) = 0 THEN 0
            ELSE 20
        END +
        -- Company validation
        CASE 
            WHEN COMPANY IS NULL OR LENGTH(TRIM(COMPANY)) = 0 THEN 0
            ELSE 20
        END AS DATA_QUALITY_SCORE,
        
        CASE 
            WHEN EMAIL IS NULL OR USER_ID IS NULL THEN 'FAILED'
            WHEN NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'WARNING'
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_users
    WHERE rn = 1
)

SELECT 
    USER_ID,
    TRIM(USER_NAME) AS USER_NAME,
    LOWER(TRIM(EMAIL)) AS EMAIL,
    TRIM(COMPANY) AS COMPANY,
    COALESCE(PLAN_TYPE, 'Free') AS PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM data_quality_checks
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
