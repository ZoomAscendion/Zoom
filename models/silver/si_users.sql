{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Users Table - Cleaned and standardized user profile and subscription information */

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
),

data_quality_checks AS (
    SELECT 
        bu.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN bu.USER_ID IS NOT NULL THEN 20 ELSE 0 END +
            CASE WHEN bu.EMAIL IS NOT NULL AND REGEXP_LIKE(bu.EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 20 ELSE 0 END +
            CASE WHEN bu.USER_NAME IS NOT NULL THEN 15 ELSE 0 END +
            CASE WHEN bu.PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 15 ELSE 0 END +
            CASE WHEN bu.COMPANY IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN bu.LOAD_TIMESTAMP IS NOT NULL THEN 10 ELSE 0 END +
            CASE WHEN bu.SOURCE_SYSTEM IS NOT NULL THEN 10 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN bu.USER_ID IS NULL OR bu.EMAIL IS NULL THEN 'FAILED'
            WHEN NOT REGEXP_LIKE(bu.EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$') THEN 'FAILED'
            WHEN bu.PLAN_TYPE NOT IN ('Free', 'Basic', 'Pro', 'Enterprise') THEN 'WARNING'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_users bu
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE USER_ID IS NOT NULL
),

final_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        COALESCE(PLAN_TYPE, 'Free') AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_users
