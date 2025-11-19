{{
  config(
    materialized='table',
    cluster_by=['LICENSE_ID', 'LICENSE_CATEGORY'],
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_license', run_started_at]) }}', 'go_dim_license', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SI_LICENSES', 'GO_DIM_LICENSE', 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (AUDIT_LOG_ID, PROCESS_NAME, PROCESS_TYPE, EXECUTION_START_TIMESTAMP, EXECUTION_END_TIMESTAMP, EXECUTION_STATUS, SOURCE_TABLE_NAME, TARGET_TABLE_NAME, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT '{{ dbt_utils.generate_surrogate_key(['go_dim_license_complete', run_started_at]) }}', 'go_dim_license', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SI_LICENSES', 'GO_DIM_LICENSE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_RUN', 'DBT_SYSTEM', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_LAYER'"
  )
}}

-- License Dimension Table
-- Transforms Silver layer license data into comprehensive license dimension

WITH source_licenses AS (
    SELECT DISTINCT
        LICENSE_TYPE,
        START_DATE,
        END_DATE,
        SOURCE_SYSTEM
    FROM {{ source('silver', 'si_licenses') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),

license_attributes AS (
    SELECT 
        -- Primary Key
        ROW_NUMBER() OVER (ORDER BY LICENSE_TYPE) AS LICENSE_ID,
        
        -- License Information
        INITCAP(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        
        -- License Categorization
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Standard'
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Professional'
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Enterprise'
            ELSE 'Other'
        END AS LICENSE_CATEGORY,
        
        -- License Tier
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 'Tier 1'
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 'Tier 2'
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 'Tier 3'
            ELSE 'Tier 0'
        END AS LICENSE_TIER,
        
        -- License Limits and Features
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 100
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 500
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 50
        END AS MAX_PARTICIPANTS,
        
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 5
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 1
        END AS STORAGE_LIMIT_GB,
        
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 40
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 100
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 500
            ELSE 0
        END AS RECORDING_LIMIT_HOURS,
        
        -- Feature Flags
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS ADMIN_FEATURES_INCLUDED,
        
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' OR UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS API_ACCESS_INCLUDED,
        
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS SSO_SUPPORT_INCLUDED,
        
        -- Pricing Information
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 14.99
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 19.99
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 39.99
            ELSE 0.00
        END AS MONTHLY_PRICE,
        
        CASE 
            WHEN UPPER(LICENSE_TYPE) LIKE '%BASIC%' THEN 149.90
            WHEN UPPER(LICENSE_TYPE) LIKE '%PRO%' THEN 199.90
            WHEN UPPER(LICENSE_TYPE) LIKE '%ENTERPRISE%' THEN 399.90
            ELSE 0.00
        END AS ANNUAL_PRICE,
        
        -- License Benefits
        'Standard license benefits for ' || LICENSE_TYPE AS LICENSE_BENEFITS,
        
        -- SCD Type 2 Fields
        START_DATE AS EFFECTIVE_START_DATE,
        COALESCE(END_DATE, '9999-12-31'::DATE) AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT_RECORD,
        
        -- Metadata
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        SOURCE_SYSTEM
    FROM source_licenses
)

SELECT * FROM license_attributes
