-- Bronze Layer Licenses Table
-- Description: Transforms raw license data into bronze layer with data quality checks and deduplication
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES
-- Author: DBT Bronze Pipeline
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_licenses', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('bz_licenses', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'COMPLETED')"
) }}

WITH raw_licenses_filtered AS (
    -- Filter out records with NULL primary keys
    SELECT *
    FROM {{ source('raw_zoom', 'licenses') }}
    WHERE license_id IS NOT NULL
),

raw_licenses_deduplicated AS (
    -- Apply deduplication logic based on primary key and latest update timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY license_id 
               ORDER BY COALESCE(update_timestamp, load_timestamp, CURRENT_TIMESTAMP()) DESC
           ) AS row_num
    FROM raw_licenses_filtered
),

raw_licenses_clean AS (
    -- Select only the most recent record for each license
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        source_system
    FROM raw_licenses_deduplicated
    WHERE row_num = 1
),

final_licenses AS (
    -- Apply Bronze layer transformations and add audit columns
    SELECT 
        -- Primary business columns (1-1 mapping from RAW)
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        
        -- Bronze layer audit columns (overwrite with current timestamp)
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        
        -- Source system tracking
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM raw_licenses_clean
)

SELECT *
FROM final_licenses
