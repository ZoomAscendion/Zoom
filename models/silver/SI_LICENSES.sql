{{ config(
    materialized='table',
    alias='SI_LICENSES',
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'PRE_HOOK_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'POST_HOOK_COMPLETE', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

/*
 * SI_LICENSES - Silver Layer Licenses Table
 * Transforms and cleanses license data from Bronze layer
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
    FROM {{ source('bronze', 'BZ_LICENSES') }}
    WHERE LICENSE_ID IS NOT NULL
),

format_cleaned_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        COALESCE(
            TRY_TO_DATE(START_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(START_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(START_DATE::STRING)
        ) AS START_DATE,
        COALESCE(
            TRY_TO_DATE(END_DATE::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY'),
            TRY_TO_DATE(END_DATE::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(END_DATE::STRING)
        ) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_licenses
),

validated_licenses AS (
    SELECT 
        *,
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
    FROM format_cleaned_licenses
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST) AS rn
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
