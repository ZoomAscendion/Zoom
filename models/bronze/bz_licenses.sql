-- Bronze Layer Licenses Model
-- Description: Raw license assignment and management data
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE license_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY license_id 
               ORDER BY load_timestamp DESC
           ) as rn
    FROM source_data
),

-- Final transformation with data type conversion
final AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        -- Convert VARCHAR end_date to DATE
        CASE 
            WHEN end_date IS NOT NULL AND TRIM(end_date) != ''
            THEN TRY_TO_DATE(end_date)
            ELSE NULL
        END as end_date,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per license_id
)

SELECT * FROM final
