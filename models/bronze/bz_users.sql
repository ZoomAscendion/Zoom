-- Bronze Layer Users Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw users data to bronze layer with audit information
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS

{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_START_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_USERS', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_USERS' AND STATUS = 'STARTED')
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        SELECT 
            'BZ_USERS', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        WHERE NOT EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_USERS' AND STATUS = 'COMPLETED')
    "
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'users') }}
    WHERE USER_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN USER_ID IS NULL THEN 'INVALID_USER_ID'
            WHEN EMAIL IS NULL THEN 'INVALID_EMAIL'
            WHEN USER_NAME IS NULL THEN 'INVALID_USER_NAME'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
