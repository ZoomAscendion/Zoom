{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_LICENSES', 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (MODEL_NAME, TABLE_NAME, PROCESS_STATUS, LOAD_TIMESTAMP) SELECT '{{ this.name }}', 'SI_LICENSES', 'COMPLETED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer with DD/MM/YYYY date format conversion
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
),

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        TRIM(UPPER(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        -- Handle DD/MM/YYYY date format (Critical P1 fix for "27/08/2024" error)
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            START_DATE
        ) AS START_DATE,
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            END_DATE
        ) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE
    FROM bronze_licenses
),

validated_licenses AS (
    SELECT *,
        CASE 
            WHEN LICENSE_TYPE IS NOT NULL AND START_DATE IS NOT NULL 
                 AND END_DATE IS NOT NULL AND END_DATE > START_DATE
            THEN 100
            WHEN LICENSE_TYPE IS NOT NULL AND START_DATE IS NOT NULL
            THEN 75
            WHEN LICENSE_TYPE IS NOT NULL OR START_DATE IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN LICENSE_TYPE IS NOT NULL AND START_DATE IS NOT NULL 
                 AND END_DATE IS NOT NULL AND END_DATE > START_DATE
            THEN 'PASSED'
            WHEN END_DATE <= START_DATE
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_licenses
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_licenses
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
FROM deduped_licenses
WHERE rn = 1
  AND VALIDATION_STATUS != 'FAILED'
