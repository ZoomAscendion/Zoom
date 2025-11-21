-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (
            SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS
        ) VALUES (
            'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'
        )
        {% endif %}
    ",
    post_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (
            SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS
        ) VALUES (
            'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
            DATEDIFF('second', 
                (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'), 
                CURRENT_TIMESTAMP()
            ), 'SUCCESS'
        )
        {% endif %}
    "
) }}

-- CTE to select and filter raw data
WITH raw_feature_usage_filtered AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL  -- Filter out NULL primary keys
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_feature_usage_filtered
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP, -- Overwrite with current DBT run time
    SOURCE_SYSTEM
FROM deduped_feature_usage
WHERE rn = 1
