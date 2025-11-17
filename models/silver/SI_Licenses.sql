{{ config(
    materialized='table'
) }}

-- Silver Licenses table transformation from Bronze layer
-- Validates license date logic and standardizes license types

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

-- Data cleansing and standardization
cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality scoring
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
            WHEN LICENSE_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Validation status
        CASE 
            WHEN LICENSE_ID IS NULL OR ASSIGNED_TO_USER_ID IS NULL THEN 'FAILED'
            WHEN LICENSE_TYPE IS NULL OR LENGTH(TRIM(LICENSE_TYPE)) = 0 THEN 'FAILED'
            WHEN START_DATE IS NULL OR END_DATE IS NULL THEN 'FAILED'
            WHEN START_DATE > END_DATE THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_licenses
    WHERE LICENSE_ID IS NOT NULL
),

-- Remove duplicates keeping the latest record
deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM cleansed_licenses
    )
    WHERE rn = 1
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
WHERE VALIDATION_STATUS != 'FAILED'  -- Exclude failed records
