{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE EXISTS (SELECT 1 FROM BRONZE.BZ_LICENSES LIMIT 1)",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE EXISTS (SELECT 1 FROM {{ this }} LIMIT 1)"
) }}

-- Silver Layer Licenses Table
-- Cleansed and standardized license assignments with critical P1 DD/MM/YYYY date format conversion

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
    WHERE LICENSE_ID IS NOT NULL
),

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        /* Critical P1: DD/MM/YYYY date format conversion for "27/08/2024" error */
        COALESCE(
            TRY_TO_DATE(START_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE)
        ) AS START_DATE,
        
        COALESCE(
            TRY_TO_DATE(END_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE)
        ) AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_licenses
),

validated_licenses AS (
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
        
        /* Data quality score calculation */
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
        
        /* Validation status */
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
    FROM cleansed_licenses
),

/* Remove duplicates - keep latest record */
deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_licenses
    ) ranked
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
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE VALIDATION_STATUS IN ('PASSED', 'WARNING')
