-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- Raw data extraction and deduplication
WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
),

-- Apply deduplication based on LICENSE_ID and UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1
