-- Bronze Layer Licenses Model
-- Description: License assignments and entitlements
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES

{{ config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'licenses'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status)
            SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                   DATEDIFF('seconds', 
                           (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'),
                           CURRENT_TIMESTAMP()), 
                   'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter out records with null primary keys
    
    {% if is_incremental() %}
        AND COALESCE(update_timestamp, load_timestamp) > (
            SELECT COALESCE(MAX(update_timestamp), '1900-01-01') 
            FROM {{ this }}
        )
    {% endif %}
),

validated_data AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE row_num = 1  -- Keep only the most recent record per license_id
        AND assigned_to_user_id IS NOT NULL  -- Required field validation
        AND (start_date IS NULL OR end_date IS NULL OR start_date <= end_date)  -- Date range validation
        AND (start_date IS NULL OR start_date <= CURRENT_DATE() + INTERVAL '1 year')  -- No far future dates
)

SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    -- Override timestamps as per Bronze layer requirements
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    COALESCE(source_system, 'UNKNOWN') AS source_system
FROM validated_data
