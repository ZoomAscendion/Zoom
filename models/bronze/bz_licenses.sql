-- Bronze Layer Licenses Model
-- Description: Raw license assignment and management data
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_LICENSES' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 0 as processing_time, 'STARTED' as status, 13 as record_id",
    post_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_LICENSES' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 1 as processing_time, 'COMPLETED' as status, 14 as record_id"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
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
    WHERE LICENSE_ID IS NOT NULL  -- Filter null primary keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per license
