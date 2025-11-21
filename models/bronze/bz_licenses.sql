-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Source: RAW.LICENSES
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out records with null primary keys
),

-- CTE for data cleaning and validation
cleaned_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        TRY_CAST(end_date AS DATE) AS end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_licenses
),

-- CTE for deduplication
deduped_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_licenses
    WHERE row_num = 1  -- Keep only the latest record for each license_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    license_id::VARCHAR(16777216) AS license_id,
    license_type::VARCHAR(16777216) AS license_type,
    assigned_to_user_id::VARCHAR(16777216) AS assigned_to_user_id,
    start_date::DATE AS start_date,
    end_date::DATE AS end_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_licenses
