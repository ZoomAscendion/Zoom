-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_LICENSES',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                0,
                'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_LICENSES',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ),
                'SUCCESS'
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary key
WITH raw_licenses AS (
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and latest timestamp
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM raw_licenses
),

-- Final transformation with data type conversions and bronze timestamp overwrite
final_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        TRY_CAST(end_date AS DATE) AS end_date,  -- Convert VARCHAR to DATE
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run timestamp
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run timestamp
        source_system
    FROM deduped_licenses
    WHERE row_num = 1
)

SELECT * FROM final_licenses
