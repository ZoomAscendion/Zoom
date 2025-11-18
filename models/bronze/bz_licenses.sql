-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary keys
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) as END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND LICENSE_TYPE IS NOT NULL
      AND START_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on LICENSE_ID and LOAD_TIMESTAMP
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY LICENSE_ID 
               ORDER BY LOAD_TIMESTAMP DESC, 
                        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) as rn
    FROM source_data
)

-- Final selection with audit columns
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
