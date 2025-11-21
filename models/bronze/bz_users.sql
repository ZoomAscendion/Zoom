-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
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
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out NULL primary keys
),

-- CTE for deduplication based on user_id and latest update_timestamp
deduped_users AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) as rn
    FROM raw_users
),

-- CTE for data quality and transformation
cleaned_users AS (
    SELECT 
        user_id,
        COALESCE(user_name, 'Unknown User') as user_name,
        CASE 
            WHEN email IS NULL OR email = '' THEN user_name || '@gmail.com'
            ELSE email 
        END as email,
        company,
        COALESCE(plan_type, 'Basic') as plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_users
    WHERE rn = 1
)

-- Final SELECT with audit columns
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
