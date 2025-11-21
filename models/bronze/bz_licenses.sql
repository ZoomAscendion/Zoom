-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Source: RAW.LICENSES
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL    -- Filter out NULL primary keys
      AND LICENSE_TYPE IS NOT NULL  -- Filter out NULL required fields
      AND START_DATE IS NOT NULL    -- Filter out NULL required fields
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY LICENSE_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

-- Final transformation with Bronze timestamp overwrite
final_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
