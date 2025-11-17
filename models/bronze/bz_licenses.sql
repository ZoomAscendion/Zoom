-- Bronze Layer Licenses Table
-- Description: Raw license assignments and entitlements from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

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
        ) as row_num
    FROM source_data
),

-- Data quality checks and transformations
final_data AS (
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
      AND LICENSE_ID IS NOT NULL  -- Ensure primary key is not null
)

SELECT * FROM final_data
