-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- Filter out NULL primary keys first
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY LICENSE_ID 
               ORDER BY LOAD_TIMESTAMP DESC, UPDATE_TIMESTAMP DESC NULLS LAST
           ) as rn
    FROM source_data
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    TRY_CAST(END_DATE AS DATE) as END_DATE,  -- Handle VARCHAR to DATE conversion
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1
