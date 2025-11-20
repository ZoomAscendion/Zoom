-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    -- Select from raw licenses table with null filtering for primary key
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
    WHERE LICENSE_ID IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication logic
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS rn
    FROM source_data
)

-- Final select with 1-1 mapping from raw to bronze
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
WHERE rn = 1
