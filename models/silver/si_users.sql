{{ config(
    materialized='table'
) }}

-- Silver Layer Users Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_users AS (
    SELECT *
    FROM {{ source('bronze', 'bz_users') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality flags
        CASE 
            WHEN USER_ID IS NULL OR TRIM(USER_ID) = '' THEN 'INVALID_USER_ID'
            WHEN EMAIL IS NULL OR TRIM(EMAIL) = '' OR EMAIL NOT LIKE '%@%' THEN 'INVALID_EMAIL'
            WHEN USER_NAME IS NULL OR TRIM(USER_NAME) = '' THEN 'INVALID_USER_NAME'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_users
),

cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(UPPER(USER_NAME)) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'BUSINESS', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'UNKNOWN'
        END AS PLAN_TYPE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_users
    WHERE data_quality_flag = 'VALID'
),

deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_users
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
WHERE row_num = 1
