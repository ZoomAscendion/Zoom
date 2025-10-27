-- Bronze Layer Users Model
-- Description: Transforms raw users data to bronze layer with data quality checks
-- Source: RAW.USERS
-- Target: BRONZE.bz_users
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_users', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_users', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
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
        TRIM(USER_NAME)::STRING as user_name,
        TRIM(LOWER(EMAIL))::STRING as email,
        TRIM(COMPANY)::STRING as company,
        TRIM(UPPER(PLAN_TYPE))::STRING as plan_type,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
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
