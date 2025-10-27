-- Bronze Layer Users Model
-- Description: Transforms raw users data to bronze layer with data quality checks
-- Source: RAW.USERS
-- Target: BRONZE.bz_users
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_users AS (
    SELECT 
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'USERS') }}
),

-- Data quality and cleansing transformations
cleansed_users AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(USER_NAME) as user_name,
        TRIM(LOWER(EMAIL)) as email,
        TRIM(COMPANY) as company,
        TRIM(UPPER(PLAN_TYPE)) as plan_type,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_users
    WHERE USER_NAME IS NOT NULL
      AND EMAIL IS NOT NULL
      AND PLAN_TYPE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
      AND EMAIL LIKE '%@%'  -- Basic email validation
)

-- Final select for bronze layer
SELECT 
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_users
