-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Source: RAW.USERS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out records with null primary keys
),

-- CTE for data cleaning and validation
cleaned_users AS (
    SELECT 
        user_id,
        COALESCE(user_name, 'Unknown User') AS user_name,
        COALESCE(email, user_name || '@gmail.com') AS email,  -- Default email if null
        company,
        COALESCE(plan_type, 'Basic') AS plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_users
),

-- CTE for deduplication
deduped_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_users
    WHERE row_num = 1  -- Keep only the latest record for each user_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    user_id::VARCHAR(16777216) AS user_id,
    user_name::VARCHAR(16777216) AS user_name,
    email::VARCHAR(16777216) AS email,
    company::VARCHAR(16777216) AS company,
    plan_type::VARCHAR(16777216) AS plan_type,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_users
