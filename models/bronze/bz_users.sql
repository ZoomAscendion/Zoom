-- =====================================================
-- Bronze Layer Users Model
-- =====================================================
-- Description: Raw user data from source system with 1:1 mapping
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS
-- =====================================================

{{ config(
    materialized='table'
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary user information (1:1 mapping from source)
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN EMAIL IS NULL THEN 'MISSING_EMAIL'
            WHEN USER_NAME IS NULL THEN 'MISSING_USER_NAME'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'users') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(USER_NAME AS STRING) AS USER_NAME,
        CAST(EMAIL AS STRING) AS EMAIL,
        CAST(COMPANY AS STRING) AS COMPANY,
        CAST(PLAN_TYPE AS STRING) AS PLAN_TYPE,
        
        -- Preserve original timestamps
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
