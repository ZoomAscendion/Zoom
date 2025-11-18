-- Bronze Pipeline Step 8: Transform raw licenses data to bronze layer
-- Description: 1-1 mapping from RAW.LICENSES to BRONZE.BZ_LICENSES with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- Bronze Pipeline Step 8.1: Select and filter raw data excluding null primary keys
WITH raw_licenses_filtered AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 8.2: Apply deduplication logic based on primary key and latest timestamp
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC, load_timestamp DESC
        ) as rn
    FROM raw_licenses_filtered
),

-- Bronze Pipeline Step 8.3: Select final deduplicated records
final_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_licenses
    WHERE rn = 1
)

SELECT * FROM final_licenses
