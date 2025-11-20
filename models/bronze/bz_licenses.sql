-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}), 0) + 1, 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('bz_data_audit') }}), 0) + 1, 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    -- Select from raw licenses table with null filtering for primary key
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        TRY_CAST(end_date AS DATE) as end_date,
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
               ) as row_num
        FROM source_data
    )
    WHERE row_num = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
