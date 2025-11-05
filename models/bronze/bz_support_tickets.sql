/*
  Bronze Layer Support Tickets Model
  Purpose: Raw data ingestion from RAW.SUPPORT_TICKETS to BRONZE.BZ_SUPPORT_TICKETS
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN TICKET_ID IS NULL THEN 'MISSING_TICKET_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN TICKET_TYPE IS NULL THEN 'MISSING_TICKET_TYPE'
            WHEN OPEN_DATE IS NULL THEN 'MISSING_OPEN_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw_zoom', 'support_tickets') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(TICKET_ID AS STRING) AS TICKET_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(TICKET_TYPE AS STRING) AS TICKET_TYPE,
        CAST(RESOLUTION_STATUS AS STRING) AS RESOLUTION_STATUS,
        CAST(OPEN_DATE AS DATE) AS OPEN_DATE,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
)

-- Final selection for Bronze layer
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
