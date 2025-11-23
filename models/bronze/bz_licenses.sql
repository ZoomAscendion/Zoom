-- Bronze Layer Licenses Model
-- Description: Raw license assignment and management data
-- Author: Data Engineer
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 1, 'SUCCESS')"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY license_id 
               ORDER BY load_timestamp DESC
           ) AS row_num
    FROM source_data
),

-- Final transformation with bronze timestamp overwrite
final AS (
    SELECT 
        license_id,
        COALESCE(license_type, 'Basic') AS license_type,
        assigned_to_user_id,
        start_date,
        CASE 
            WHEN end_date IS NULL OR end_date = '' THEN NULL
            ELSE TRY_CAST(end_date AS DATE)
        END AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'unknown') AS source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM final
