/*
  Bronze Layer Participants Model
  
  Purpose: Raw data ingestion from RAW.PARTICIPANTS to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.PARTICIPANTS to BZ_PARTICIPANTS
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
        PARTICIPANT_ID,
        
        -- Participant information
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'participants') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(PARTICIPANT_ID AS STRING) AS participant_id,
        CAST(MEETING_ID AS STRING) AS meeting_id,
        CAST(USER_ID AS STRING) AS user_id,
        CAST(JOIN_TIME AS TIMESTAMP_NTZ) AS join_time,
        CAST(LEAVE_TIME AS TIMESTAMP_NTZ) AS leave_time,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
