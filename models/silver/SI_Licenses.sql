{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_LICENSES', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_LICENSES', 'SI_LICENSES', 'DBT_PIPELINE', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_LICENSES' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Licenses Table
-- Transforms and cleanses license data from Bronze layer
-- Applies data quality checks and business rules

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
),

cleansed_licenses AS (
    SELECT 
        bl.LICENSE_ID,
        UPPER(TRIM(bl.LICENSE_TYPE)) AS LICENSE_TYPE,
        bl.ASSIGNED_TO_USER_ID,
        bl.START_DATE,
        bl.END_DATE,
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM,
        
        -- Additional Silver layer metadata
        DATE(bl.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bl.UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_licenses bl
    INNER JOIN {{ ref('SI_Users') }} su ON bl.ASSIGNED_TO_USER_ID = su.USER_ID
    WHERE bl.LICENSE_ID IS NOT NULL
        AND bl.LICENSE_TYPE IS NOT NULL
        AND bl.ASSIGNED_TO_USER_ID IS NOT NULL
        AND bl.START_DATE IS NOT NULL
        AND bl.END_DATE IS NOT NULL
        AND bl.START_DATE <= bl.END_DATE
),

data_quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL 
                AND START_DATE <= END_DATE
                AND LENGTH(LICENSE_TYPE) <= 100
            THEN 100
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE <= END_DATE
            THEN 75
            WHEN LICENSE_ID IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 50
            ELSE 25
        END AS DATA_QUALITY_SCORE,
        
        -- Set validation status
        CASE 
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL 
                AND START_DATE IS NOT NULL 
                AND END_DATE IS NOT NULL 
                AND START_DATE <= END_DATE
                AND LENGTH(LICENSE_TYPE) <= 100
            THEN 'PASSED'
            WHEN LICENSE_ID IS NOT NULL 
                AND LICENSE_TYPE IS NOT NULL 
                AND ASSIGNED_TO_USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleansed_licenses
),

-- Remove duplicates keeping the latest record
deduped_licenses AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        FROM data_quality_scored
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
