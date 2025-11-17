{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Transform Bronze Users to Silver Users with data quality checks and standardization */

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

data_quality_checks AS (
    SELECT 
        *,
        /* Data Quality Score Calculation */
        (
            CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN USER_NAME IS NOT NULL AND LENGTH(TRIM(USER_NAME)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 25 ELSE 0 END +
            CASE WHEN COMPANY IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 25 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN (
                CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_NAME IS NOT NULL AND LENGTH(TRIM(USER_NAME)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 25 ELSE 0 END +
                CASE WHEN COMPANY IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 25 ELSE 0 END
            ) >= 90 THEN 'PASSED'
            WHEN (
                CASE WHEN USER_ID IS NOT NULL THEN 20 ELSE 0 END +
                CASE WHEN USER_NAME IS NOT NULL AND LENGTH(TRIM(USER_NAME)) > 0 THEN 20 ELSE 0 END +
                CASE WHEN EMAIL IS NOT NULL AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 25 ELSE 0 END +
                CASE WHEN COMPANY IS NOT NULL THEN 10 ELSE 0 END +
                CASE WHEN PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 25 ELSE 0 END
            ) >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM bronze_users
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) as rn
    FROM data_quality_checks
)

SELECT 
    USER_ID,
    COALESCE(TRIM(USER_NAME), 'UNKNOWN') AS USER_NAME,
    COALESCE(LOWER(TRIM(EMAIL)), 'unknown@domain.com') AS EMAIL,
    COALESCE(TRIM(COMPANY), 'UNKNOWN') AS COMPANY,
    COALESCE(PLAN_TYPE, 'Free') AS PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduplication
WHERE rn = 1
  AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
