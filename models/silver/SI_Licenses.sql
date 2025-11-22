{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_LICENSES', 'PIPELINE_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_Audit_Log'"
) }}

/* Silver Licenses Table - Cleaned and standardized license assignments with critical P1 DD/MM/YYYY date format conversion */

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'BZ_LICENSES') }}
),

cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        
        /* Critical P1 Fix: Convert DD/MM/YYYY date format to Snowflake-compatible format */
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            START_DATE
        ) AS START_DATE,
        
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            END_DATE
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
        /* Data Quality Score Calculation */
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL 
                AND START_DATE <= END_DATE
            THEN 100
            WHEN LICENSE_ID IS NOT NULL AND ASSIGNED_TO_USER_ID IS NOT NULL AND LICENSE_TYPE IS NOT NULL 
            THEN 80
            WHEN LICENSE_ID IS NOT NULL 
            THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
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

deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC) AS rn
        FROM validated_licenses
    )
    WHERE rn = 1
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATE(CURRENT_TIMESTAMP()) AS LOAD_DATE,
    DATE(CURRENT_TIMESTAMP()) AS UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_licenses
WHERE VALIDATION_STATUS != 'FAILED'
