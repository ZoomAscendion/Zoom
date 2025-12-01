-- Bronze Meetings Table
-- Description: Stores meeting information and session details
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="{% if not (this.name == 'bz_data_audit') %}INSERT INTO {{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'){% endif %}",
    post_hook="{% if not (this.name == 'bz_data_audit') %}INSERT INTO {{ target.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1, 'SUCCESS'){% endif %}"
) }}

WITH source_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Filter out null primary keys
),

-- Apply deduplication based on MEETING_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) DESC
        ) as rn
    FROM source_data
),

-- Data quality transformations
cleaned_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        COALESCE(MEETING_TOPIC, 'Untitled Meeting') as MEETING_TOPIC,
        START_TIME,
        END_TIME,
        COALESCE(DURATION_MINUTES, 0) as DURATION_MINUTES,
        -- Bronze Timestamp Overwrite Requirement
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') as SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM cleaned_data
