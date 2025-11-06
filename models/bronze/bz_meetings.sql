/*
  Bronze Layer Meetings Model
  
  Purpose: Raw data ingestion from RAW.MEETINGS to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.MEETINGS to BZ_MEETINGS
  - Preserves all source data without transformation
  - Adds audit trail through pre/post hooks
*/

{{ config(
    materialized='table'
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Primary identifier
        MEETING_ID,
        
        -- Meeting information
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'meetings') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(MEETING_ID AS STRING) AS meeting_id,
        CAST(HOST_ID AS STRING) AS host_id,
        CAST(MEETING_TOPIC AS STRING) AS meeting_topic,
        CAST(START_TIME AS TIMESTAMP_NTZ) AS start_time,
        CAST(END_TIME AS TIMESTAMP_NTZ) AS end_time,
        CAST(DURATION_MINUTES AS NUMBER) AS duration_minutes,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
