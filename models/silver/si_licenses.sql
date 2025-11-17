{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_LICENSES', 'PROCESSING_STARTED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (TABLE_NAME, STATUS, AUDIT_TIMESTAMP, LOAD_TIMESTAMP) SELECT 'SI_LICENSES', 'PROCESSING_COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- SI_LICENSES: Cleaned and standardized license assignments and entitlements
-- Transformation from Bronze BZ_LICENSES to Silver SI_LICENSES
-- Includes critical DD/MM/YYYY date format conversion

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
    FROM {{ source('bronze', 'BZ_LICENSES') }}
    WHERE LICENSE_ID IS NOT NULL
),

-- Critical: Handle DD/MM/YYYY date format conversion (e.g., "27/08/2024")
cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        -- Critical DD/MM/YYYY date format conversion
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
        SOURCE_SYSTEM
    FROM bronze_licenses
),

-- Data Quality Validation
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
        -- Data Quality Scoring
        CASE 
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL
                 AND l.END_DATE > l.START_DATE
                 AND l.LICENSE_TYPE IS NOT NULL
                 AND u.USER_ID IS NOT NULL
            THEN 100
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL
                 AND l.END_DATE > l.START_DATE
            THEN 80
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN l.START_DATE IS NOT NULL AND l.END_DATE IS NOT NULL
                 AND l.END_DATE > l.START_DATE
                 AND l.LICENSE_TYPE IS NOT NULL
                 AND u.USER_ID IS NOT NULL
            THEN 'PASSED'
            WHEN l.START_DATE IS NULL OR l.END_DATE IS NULL OR l.END_DATE <= l.START_DATE
            THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_licenses l
    LEFT JOIN {{ ref('si_users') }} u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
),

-- Remove Duplicates
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
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
    -- Additional Silver layer metadata columns
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE rn = 1
  AND START_DATE IS NOT NULL
  AND END_DATE IS NOT NULL
  AND END_DATE > START_DATE
