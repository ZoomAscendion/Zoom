-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                DATEDIFF('second', 
                    (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED'), 
                    CURRENT_TIMESTAMP()), 'SUCCESS')
        {% endif %}
    "
) }}

-- CTE to filter out NULL primary keys and prepare raw data
WITH source_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) AS END_DATE,  -- Convert VARCHAR to DATE
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Filter out NULL primary keys
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
)

-- Final selection with 1:1 mapping from raw to bronze
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
