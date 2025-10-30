-- Bronze Layer Users Model
-- Transforms raw user data from RAW.USERS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- CTE for raw data extraction
WITH raw_users AS (
    SELECT 
        -- Business columns from source
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'users') }}
),

-- CTE for data validation and cleansing
validated_users AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(USER_ID, 'UNKNOWN') as USER_ID,
        COALESCE(USER_NAME, 'UNKNOWN') as USER_NAME,
        COALESCE(EMAIL, 'UNKNOWN') as EMAIL,
        COALESCE(COMPANY, 'UNKNOWN') as COMPANY,
        COALESCE(PLAN_TYPE, 'UNKNOWN') as PLAN_TYPE,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_users
)

-- Final selection for Bronze layer
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_users
