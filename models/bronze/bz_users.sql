-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 0, 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', DATEDIFF('second', 
            (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), 
            CURRENT_TIMESTAMP()), 'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw users table with null filtering for primary key
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY user_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
