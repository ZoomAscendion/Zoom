-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} 
        (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} 
        (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                DATEDIFF('second', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), 
                    CURRENT_TIMESTAMP()), 
                'SUCCESS')
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw licenses table with null filtering for primary key
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY license_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    ) ranked
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    license_id::VARCHAR(16777216) as license_id,
    license_type::VARCHAR(16777216) as license_type,
    assigned_to_user_id::VARCHAR(16777216) as assigned_to_user_id,
    start_date::DATE as start_date,
    TRY_CAST(end_date AS DATE) as end_date,
    load_timestamp::TIMESTAMP_NTZ(9) as load_timestamp,
    update_timestamp::TIMESTAMP_NTZ(9) as update_timestamp,
    source_system::VARCHAR(16777216) as source_system
FROM deduped_data
