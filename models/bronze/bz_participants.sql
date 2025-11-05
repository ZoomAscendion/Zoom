/*
  Bronze Layer Participants Model
  Purpose: Raw data ingestion from RAW.PARTICIPANTS to BRONZE.BZ_PARTICIPANTS
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'
      WHERE EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} LIMIT 1)
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN PARTICIPANT_ID IS NULL THEN 'MISSING_PARTICIPANT_ID'
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN JOIN_TIME IS NULL THEN 'MISSING_JOIN_TIME'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Add row number to handle duplicates
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY LOAD_TIMESTAMP DESC) AS rn
        
    FROM {{ source('raw_zoom', 'participants') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(PARTICIPANT_ID AS STRING) AS PARTICIPANT_ID,
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(JOIN_TIME AS TIMESTAMP_NTZ) AS JOIN_TIME,
        CAST(LEAVE_TIME AS TIMESTAMP_NTZ) AS LEAVE_TIME,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
    AND rn = 1  -- Take only the most recent record for each PARTICIPANT_ID
)

-- Final selection for Bronze layer
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
