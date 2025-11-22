{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Layer Users Table */
/* Purpose: Cleaned and standardized user profile and subscription information */

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

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        CASE 
            WHEN USER_ID IS NULL THEN 0
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 30
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 60
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN USER_ID IS NULL THEN 'FAILED'
            WHEN EMAIL IS NULL OR NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'FAILED'
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_users
),

cleaned_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        COALESCE(PLAN_TYPE, 'Free') AS PLAN_TYPE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
        DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM data_quality_checks
    WHERE USER_ID IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) = 1
)

SELECT * FROM cleaned_users
