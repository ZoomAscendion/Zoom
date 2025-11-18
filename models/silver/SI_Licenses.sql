{{ config(
    materialized='table'
) }}

-- SI_Licenses table transformation from Bronze to Silver
-- Includes critical P1 fix for DD/MM/YYYY date format conversion

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
    FROM BRONZE.BZ_LICENSES
),

cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        /* Critical P1 fix: Handle DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE::STRING)
        ) AS START_DATE,
        /* Critical P1 fix: Handle DD/MM/YYYY date format conversion */
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE::STRING)
        ) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
    WHERE LICENSE_ID IS NOT NULL
),

validated_licenses AS (
    SELECT 
        *,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        /* Calculate data quality score */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        /* Set validation status */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL
                AND START_DATE <= END_DATE
            THEN 'PASSED'
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_licenses
),

/* Remove duplicates keeping the latest record */
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
