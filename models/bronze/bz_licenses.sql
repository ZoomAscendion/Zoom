-- Bronze Layer Licenses Table
-- Description: Raw license assignment and management data
-- Source: RAW.LICENSES
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'dbt_user', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Source data with null filtering for primary key
WITH source_data AS (
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
    WHERE license_id IS NOT NULL     -- Filter out null primary keys
      AND license_type IS NOT NULL   -- Filter out null license_type
      AND start_date IS NOT NULL     -- Filter out null start_date
),

-- Data cleaning and validation
cleaned_data AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        TRY_CAST(end_date AS DATE) AS end_date,  -- Handle string to date conversion
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
),

-- Deduplication based on license_id (keeping latest record)
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS rn
    FROM cleaned_data
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_data
WHERE rn = 1
