-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

WITH source_data AS (
    -- Select from raw source table with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY license_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
)

-- Final select with bronze timestamp overwrite
SELECT
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system
FROM deduped_data
