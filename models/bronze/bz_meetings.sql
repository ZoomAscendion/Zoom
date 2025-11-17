-- =====================================================
-- BRONZE LAYER - MEETINGS TABLE
-- Purpose: Raw to Bronze transformation for meeting data
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'",
    post_hook="INSERT INTO {{ this.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'COMPLETED'"
) }}

WITH source_data AS (
    -- Extract raw data from source table
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on MEETING_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY MEETING_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw', 'meetings') }}
),

deduped_data AS (
    -- Apply deduplication logic
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
    FROM source_data
    WHERE row_num = 1
        AND MEETING_ID IS NOT NULL  -- Data quality check
        AND HOST_ID IS NOT NULL
),

final_data AS (
    -- Final transformation with audit columns
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
    FROM deduped_data
)

SELECT * FROM final_data
