/*
  Bronze Layer Meetings Model
  Purpose: Raw data ingestion from RAW.MEETINGS to BRONZE.BZ_MEETINGS
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      VALUES ('BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_MEETINGS' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN HOST_ID IS NULL THEN 'MISSING_HOST_ID'
            WHEN START_TIME IS NULL THEN 'MISSING_START_TIME'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw_zoom', 'meetings') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(HOST_ID AS STRING) AS HOST_ID,
        CAST(MEETING_TOPIC AS STRING) AS MEETING_TOPIC,
        CAST(START_TIME AS TIMESTAMP_NTZ) AS START_TIME,
        CAST(END_TIME AS TIMESTAMP_NTZ) AS END_TIME,
        CAST(DURATION_MINUTES AS NUMBER) AS DURATION_MINUTES,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
)

-- Final selection for Bronze layer
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
FROM validated_data
