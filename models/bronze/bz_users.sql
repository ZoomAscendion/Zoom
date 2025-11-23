-- Bronze Layer Users Table
-- Description: Raw user account data from user management systems
-- Source: RAW.USERS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'dbt_user', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Source data with null filtering for primary key
WITH source_data AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out null primary keys
),

-- Data cleaning and validation
cleaned_data AS (
    SELECT 
        user_id,
        COALESCE(user_name, 'Unknown User') AS user_name,
        COALESCE(email, user_name || '@gmail.com') AS email,  -- Default email if null
        company,
        COALESCE(plan_type, 'Basic') AS plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
),

-- Deduplication based on user_id (keeping latest record)
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS rn
    FROM cleaned_data
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_data
WHERE rn = 1
