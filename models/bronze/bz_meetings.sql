-- Bronze Layer Meetings Model
-- Transforms raw meeting data from RAW.MEETINGS to BRONZE.BZ_MEETINGS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    post_hook="{{ audit_insert('BZ_MEETINGS', "(SELECT COUNT(*) FROM " ~ this ~ ")") }}"
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality validation
        CASE 
            WHEN MEETING_ID IS NULL THEN 'INVALID'
            WHEN HOST_ID IS NULL THEN 'INVALID'
            WHEN START_TIME IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'meetings') }}
),

-- CTE for final data selection with error handling
final_data AS (
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
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
