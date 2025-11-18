{{ config(
    materialized='table'
) }}

/*
 * SI_LICENSES - Silver Layer Licenses Table
 * Includes critical P1 DQ check for DD/MM/YYYY date format conversion
 */

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
        
        /* Critical P1 DQ Check: DD/MM/YYYY Date Format Conversion */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE::STRING),
            START_DATE
        ) AS START_DATE,
        
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE::STRING),
            END_DATE
        ) AS END_DATE,
        
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_licenses
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
    
    /* Data Quality Score Calculation */
    CASE 
        WHEN LICENSE_ID IS NOT NULL 
            AND LICENSE_TYPE IS NOT NULL 
            AND ASSIGNED_TO_USER_ID IS NOT NULL 
            AND START_DATE IS NOT NULL 
            AND END_DATE IS NOT NULL 
        THEN 100
        WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL 
        THEN 75
        WHEN LICENSE_ID IS NOT NULL 
        THEN 50
        ELSE 25
    END AS DATA_QUALITY_SCORE,
    
    /* Validation Status */
    CASE 
        WHEN LICENSE_ID IS NOT NULL 
            AND LICENSE_TYPE IS NOT NULL 
            AND ASSIGNED_TO_USER_ID IS NOT NULL 
            AND START_DATE IS NOT NULL 
            AND END_DATE IS NOT NULL 
        THEN 'PASSED'
        WHEN LICENSE_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL 
        THEN 'WARNING'
        ELSE 'FAILED'
    END AS VALIDATION_STATUS
FROM cleansed_licenses
