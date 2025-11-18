-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'COMPLETED')"
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY LICENSE_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
),

transformed_data AS (
    -- Handle data type conversions for Bronze layer
    SELECT
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        -- Convert END_DATE from VARCHAR to DATE if not null
        CASE 
            WHEN END_DATE IS NOT NULL AND END_DATE != '' 
            THEN TRY_TO_DATE(END_DATE)
            ELSE NULL 
        END AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        row_num
    FROM deduped_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM transformed_data
WHERE row_num = 1
