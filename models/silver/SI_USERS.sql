{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, STATUS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_USERS', 'SI_USERS', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP())
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'SI_AUDIT_LOG' %}
        INSERT INTO {{ ref('SI_AUDIT_LOG') }} (MODEL_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_END_TIME, STATUS, RECORDS_SUCCESS, LOAD_TIMESTAMP)
        VALUES ('{{ this.name }}', 'BZ_USERS', 'SI_USERS', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_TIMESTAMP())
        {% endif %}
    "
) }}

-- Silver layer transformation for Users table
-- Applies data quality checks, standardization, and business rules

WITH source_data AS (
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
    WHERE USER_ID IS NOT NULL  -- Exclude null user IDs
),

data_quality_checks AS (
    SELECT 
        *,
        -- Data quality score calculation
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 100
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN USER_ID IS NOT NULL 
                AND USER_NAME IS NOT NULL 
                AND EMAIL IS NOT NULL 
                AND REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
                AND PLAN_TYPE IN ('Free', 'Basic', 'Pro', 'Enterprise')
            THEN 'PASSED'
            WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM source_data
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        COALESCE(
            CASE 
                WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
                THEN INITCAP(UPPER(TRIM(PLAN_TYPE)))
                ELSE 'Free'
            END, 'Free'
        ) AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE rn = 1  -- Keep only the latest record per user
        AND VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
)

SELECT * FROM final_transformation
