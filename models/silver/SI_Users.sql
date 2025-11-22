{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE'"
) }}

/* Silver Users table with data quality checks and deduplication */
WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_USERS') }}
),

/* Data quality validation and cleaning */
validated_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN PLAN_TYPE
            ELSE 'Free'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        /* Data quality score calculation */
        CASE 
            WHEN USER_ID IS NULL THEN 0
            WHEN EMAIL IS NULL THEN 30
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 70
            ELSE 100
        END AS DATA_QUALITY_SCORE,
        
        /* Validation status */
        CASE 
            WHEN USER_ID IS NULL OR EMAIL IS NULL THEN 'FAILED'
            WHEN PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS,
        
        /* Row number for deduplication */
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC NULLS LAST) AS rn
    FROM bronze_users
    WHERE USER_ID IS NOT NULL
),

/* Remove duplicates and failed records */
deduped_users AS (
    SELECT *
    FROM validated_users
    WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_users
