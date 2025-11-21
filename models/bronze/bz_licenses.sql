-- Bronze Layer Licenses Table
-- Description: Raw license assignment and management data
-- Author: Data Engineering Team

{{ config(
    materialized='table'
) }}

-- CTE to select and filter raw data
WITH raw_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        CASE 
            WHEN end_date IS NULL OR end_date = '' THEN NULL
            ELSE TRY_CAST(end_date AS DATE)
        END AS end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL    -- Filter out NULL primary keys
      AND license_type IS NOT NULL  -- Filter out NULL license_type
      AND start_date IS NOT NULL    -- Filter out NULL start_date
),

-- CTE for deduplication based on primary key
deduped_licenses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY load_timestamp DESC) as rn
    FROM raw_licenses
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_licenses
WHERE rn = 1  -- Keep only the most recent record per license_id
