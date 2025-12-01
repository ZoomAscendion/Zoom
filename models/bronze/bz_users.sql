-- Bronze Layer Users Model
-- Description: User profile and subscription information from source systems
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS

{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'users', 'pii'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status)
            SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                   DATEDIFF('seconds', 
                           (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'),
                           CURRENT_TIMESTAMP()), 
                   'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out records with null primary keys
    
    {% if is_incremental() %}
        AND COALESCE(update_timestamp, load_timestamp) > (
            SELECT COALESCE(MAX(update_timestamp), '1900-01-01') 
            FROM {{ this }}
        )
    {% endif %}
),

deduped_data AS (
    SELECT 
        user_id,
        user_name,
        -- Handle email validation and default generation
        CASE 
            WHEN email IS NULL OR email = '' THEN 
                COALESCE(user_name, 'user' || user_id) || '@gmail.com'
            ELSE email
        END AS email,
        company,
        -- Validate plan types
        CASE 
            WHEN plan_type IN ('Basic', 'Pro', 'Business', 'Enterprise') THEN plan_type
            ELSE 'Basic'
        END AS plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE row_num = 1  -- Keep only the most recent record per user_id
)

SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    -- Override timestamps as per Bronze layer requirements
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    COALESCE(source_system, 'UNKNOWN') AS source_system
FROM deduped_data
