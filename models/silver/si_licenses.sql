{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, STATUS, EXECUTED_BY, EXECUTION_ENVIRONMENT, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'LIC_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Licenses_ETL', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SILVER_JOB', 'PRODUCTION', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (EXECUTION_ID, PIPELINE_NAME, START_TIME, END_TIME, STATUS, EXECUTION_DURATION_SECONDS, SOURCE_TABLES_PROCESSED, TARGET_TABLES_UPDATED, RECORDS_PROCESSED, RECORDS_INSERTED, RECORDS_UPDATED, RECORDS_REJECTED, EXECUTED_BY, EXECUTION_ENVIRONMENT, DATA_LINEAGE_INFO, SOURCE_SYSTEM, LOAD_DATE, UPDATE_DATE) SELECT 'LIC_' || REPLACE(REPLACE(REPLACE(CURRENT_TIMESTAMP()::STRING, ' ', '_'), ':', ''), '.', '_'), 'Silver_Licenses_ETL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'COMPLETED', 0, 'BZ_LICENSES', 'SI_LICENSES', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 0, 0, 'DBT_SILVER_JOB', 'PRODUCTION', 'Bronze to Silver Licenses transformation', 'ZOOM_PLATFORM', CURRENT_DATE(), CURRENT_DATE()"
) }}

-- Silver Licenses Table
-- Transforms Bronze licenses data with validations and enrichments

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

bronze_users AS (
    SELECT USER_ID, USER_NAME
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validations
validated_licenses AS (
    SELECT
        l.*,
        -- Data Quality Flags
        CASE 
            WHEN l.LICENSE_ID IS NULL THEN 'CRITICAL_NO_LICENSE_ID'
            WHEN l.ASSIGNED_TO_USER_ID IS NULL THEN 'CRITICAL_NO_USER_ID'
            WHEN l.LICENSE_TYPE IS NULL THEN 'CRITICAL_NO_LICENSE_TYPE'
            WHEN l.END_DATE < l.START_DATE THEN 'CRITICAL_INVALID_DATE_RANGE'
            WHEN l.START_DATE > CURRENT_DATE() + INTERVAL '1 YEAR' THEN 'WARNING_FUTURE_START_DATE'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY l.LICENSE_ID ORDER BY l.UPDATE_TIMESTAMP DESC, l.LOAD_TIMESTAMP DESC) AS rn
    FROM bronze_licenses l
    WHERE l.LICENSE_ID IS NOT NULL  -- Block records without LICENSE_ID
      AND l.ASSIGNED_TO_USER_ID IS NOT NULL -- Block records without USER_ID
      AND l.LICENSE_TYPE IS NOT NULL -- Block records without LICENSE_TYPE
      AND l.END_DATE >= l.START_DATE -- Block invalid date ranges
),

-- Apply Transformations
transformed_licenses AS (
    SELECT
        -- Primary Keys
        vl.LICENSE_ID,
        vl.ASSIGNED_TO_USER_ID,
        
        -- Standardized Business Columns
        CASE 
            WHEN UPPER(vl.LICENSE_TYPE) IN ('BASIC', 'FREE') THEN 'Basic'
            WHEN UPPER(vl.LICENSE_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(vl.LICENSE_TYPE) IN ('ENTERPRISE', 'ENT') THEN 'Enterprise'
            WHEN UPPER(vl.LICENSE_TYPE) IN ('ADD-ON', 'ADDON') THEN 'Add-on'
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        
        vl.START_DATE,
        vl.END_DATE,
        
        -- Derived License Status
        CASE 
            WHEN vl.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN vl.START_DATE > CURRENT_DATE() THEN 'Pending'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        
        -- Enriched User Name
        COALESCE(u.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        
        -- Derived License Cost
        CASE 
            WHEN UPPER(vl.LICENSE_TYPE) IN ('BASIC', 'FREE') THEN 0.00
            WHEN UPPER(vl.LICENSE_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 14.99
            WHEN UPPER(vl.LICENSE_TYPE) IN ('ENTERPRISE', 'ENT') THEN 19.99
            WHEN UPPER(vl.LICENSE_TYPE) IN ('ADD-ON', 'ADDON') THEN 5.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        -- Derived Renewal Status
        CASE 
            WHEN vl.END_DATE <= CURRENT_DATE() + INTERVAL '30 DAYS' THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Derived Utilization Percentage
        CASE 
            WHEN UPPER(vl.LICENSE_TYPE) IN ('ENTERPRISE', 'ENT') THEN 85.0
            WHEN UPPER(vl.LICENSE_TYPE) IN ('PRO', 'PROFESSIONAL') THEN 70.0
            WHEN UPPER(vl.LICENSE_TYPE) IN ('BASIC', 'FREE') THEN 45.0
            ELSE 60.0
        END AS UTILIZATION_PERCENTAGE,
        
        -- Metadata Columns
        vl.LOAD_TIMESTAMP,
        vl.UPDATE_TIMESTAMP,
        vl.SOURCE_SYSTEM,
        
        -- Data Quality Score
        CASE 
            WHEN vl.data_quality_flag = 'VALID' THEN 1.00
            WHEN vl.data_quality_flag LIKE 'WARNING%' THEN 0.80
            ELSE 0.60
        END AS DATA_QUALITY_SCORE,
        
        -- Standard Metadata
        DATE(vl.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(vl.UPDATE_TIMESTAMP) AS UPDATE_DATE
        
    FROM validated_licenses vl
    LEFT JOIN bronze_users u ON vl.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE vl.rn = 1  -- Keep only the latest record for each LICENSE_ID
      AND vl.data_quality_flag NOT LIKE 'CRITICAL%'
)

SELECT
    LICENSE_ID,
    ASSIGNED_TO_USER_ID,
    LICENSE_TYPE,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    ASSIGNED_USER_NAME,
    LICENSE_COST,
    RENEWAL_STATUS,
    UTILIZATION_PERCENTAGE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM transformed_licenses
