-- Bronze Layer Licenses Table
-- Description: Raw license assignment and management data
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) as END_DATE,
        LOAD_TIMESTAMP as raw_load_timestamp,
        UPDATE_TIMESTAMP as raw_update_timestamp,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL    -- Filter out NULL primary keys
      AND LICENSE_TYPE IS NOT NULL  -- Filter out NULL required fields
      AND START_DATE IS NOT NULL    -- Filter out NULL required fields
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY COALESCE(raw_update_timestamp, raw_load_timestamp) DESC
        ) as row_num
    FROM source_data
),

-- Handle null values and apply business rules
cleaned_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Bronze timestamp overwrite
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Bronze timestamp overwrite
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM cleaned_data
