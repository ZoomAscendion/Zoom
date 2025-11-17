{{ config(
    materialized='table'
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer
-- Handles DD/MM/YYYY date format conversion

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

date_converted AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        -- Enhanced DD/MM/YYYY Date Format Conversion for START_DATE
        CASE 
            WHEN START_DATE::STRING REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN 
                COALESCE(
                    TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
                    TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY')
                )
            ELSE START_DATE
        END AS START_DATE,
        
        -- Enhanced DD/MM/YYYY Date Format Conversion for END_DATE
        CASE 
            WHEN END_DATE::STRING REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN 
                COALESCE(
                    TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
                    TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY')
                )
            ELSE END_DATE
        END AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
),

validated_licenses AS (
    SELECT 
        *,
        -- Validate license date logic
        CASE 
            WHEN START_DATE <= END_DATE 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
            THEN TRUE
            ELSE FALSE
        END AS is_valid_license,
        
        -- Data Quality Score
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 'PASSED'
            WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM date_converted
),

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
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE rn = 1
    AND VALIDATION_STATUS != 'FAILED'
    AND is_valid_license = TRUE
