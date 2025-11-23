{{ config(
    materialized='table'
) }}

-- Transform Bronze Users to Silver Users with data quality checks and deduplication
WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_USERS') }}
    WHERE USER_ID IS NOT NULL
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM bronze_users
),

transformed_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END AS PLAN_TYPE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        
        -- Data Quality Score Calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IS NOT NULL
            THEN 100
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 75
            WHEN USER_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IS NOT NULL
            THEN 'PASSED'
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
        
    FROM deduped_users
    WHERE rn = 1
)

SELECT *
FROM transformed_users
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
