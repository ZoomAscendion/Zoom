{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_licenses', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_LICENSES', 
            'SILVER.SI_LICENSES', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_LICENSES'"
) }}

-- Silver layer licenses table with DD/MM/YYYY date format conversion (Critical P1)
WITH bronze_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND ASSIGNED_TO_USER_ID IS NOT NULL
),

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        /* Convert DD/MM/YYYY formatted dates to Snowflake-compatible format (Critical P1 fix for "27/08/2024" error) */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY')
        ) AS START_DATE,
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY')
        ) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_licenses
    WHERE LICENSE_TYPE IS NOT NULL
      AND LENGTH(TRIM(LICENSE_TYPE)) > 0
),

validated_licenses AS (
    SELECT 
        l.LICENSE_ID,
        l.LICENSE_TYPE,
        l.ASSIGNED_TO_USER_ID,
        l.START_DATE,
        l.END_DATE,
        l.LOAD_TIMESTAMP,
        l.UPDATE_TIMESTAMP,
        l.SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(l.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(l.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL 
                 AND l.END_DATE > l.START_DATE 
                 AND u.USER_ID IS NOT NULL THEN 100
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL 
                 AND l.END_DATE > l.START_DATE THEN 80
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL 
                 AND l.END_DATE > l.START_DATE 
                 AND u.USER_ID IS NOT NULL THEN 'PASSED'
            WHEN l.END_DATE <= l.START_DATE THEN 'FAILED'
            WHEN u.USER_ID IS NULL THEN 'FAILED'
            WHEN l.START_DATE IS NULL OR l.END_DATE IS NULL THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_licenses l
    LEFT JOIN {{ ref('si_users') }} u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE l.rn = 1
      AND l.START_DATE IS NOT NULL
      AND l.END_DATE IS NOT NULL
      AND l.END_DATE > l.START_DATE  -- Business logic validation
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM validated_licenses
