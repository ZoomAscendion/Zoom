{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_USERS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Users Table - Cleaned and standardized user profile and subscription information */
/* Implements data quality checks and transformations from Bronze layer */

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
    WHERE USER_ID IS NOT NULL
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC) as rn
    FROM bronze_users
),

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
        /* Calculate data quality score */
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 100
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        /* Set validation status */
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
            THEN 'PASSED'
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_users
    WHERE rn = 1
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
FROM validated_users
