{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS, PROCESSED_BY, PROCESSING_MODE, LOAD_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_LICENSES', 'BZ_LICENSES', 'SI_LICENSES', CURRENT_TIMESTAMP(), 'RUNNING', 'DBT_PIPELINE', 'INCREMENTAL', CURRENT_DATE(), 'SILVER_LAYER_PROCESSING' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE TARGET_TABLE = 'SI_LICENSES' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Licenses Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
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
        -- Data quality validation
        CASE 
            WHEN LICENSE_ID IS NULL OR TRIM(LICENSE_ID) = '' THEN 'INVALID_LICENSE_ID'
            WHEN LICENSE_TYPE IS NULL OR TRIM(LICENSE_TYPE) = '' THEN 'INVALID_LICENSE_TYPE'
            WHEN ASSIGNED_TO_USER_ID IS NULL OR TRIM(ASSIGNED_TO_USER_ID) = '' THEN 'INVALID_USER_ID'
            WHEN START_DATE IS NULL THEN 'INVALID_START_DATE'
            WHEN END_DATE IS NULL THEN 'INVALID_END_DATE'
            WHEN START_DATE > END_DATE THEN 'INVALID_DATE_RANGE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_licenses
),

cleansed_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        -- Calculate license status
        CASE 
            WHEN END_DATE < CURRENT_DATE() THEN 'EXPIRED'
            WHEN END_DATE <= DATEADD('day', 30, CURRENT_DATE()) THEN 'EXPIRING_SOON'
            WHEN START_DATE > CURRENT_DATE() THEN 'FUTURE'
            ELSE 'ACTIVE'
        END AS LICENSE_STATUS,
        -- Calculate days to expiry
        CASE 
            WHEN END_DATE >= CURRENT_DATE() 
            THEN DATEDIFF('day', CURRENT_DATE(), END_DATE)
            ELSE 0
        END AS DAYS_TO_EXPIRY,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_licenses
    WHERE data_quality_flag = 'VALID'
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_licenses
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    DAYS_TO_EXPIRY,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_licenses
WHERE row_num = 1
