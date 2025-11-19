-- Bronze Layer Licenses Model
-- Description: Raw license assignments and entitlements from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- Raw data selection with primary key filtering
WITH raw_licenses AS (
    SELECT *
    FROM {{ source('raw_schema', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_licenses AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY license_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_licenses
),

-- Final transformation with 1-1 mapping and data type conversion
final_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        TRY_CAST(end_date AS DATE) AS end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_licenses
    WHERE row_num = 1
)

SELECT * FROM final_licenses
