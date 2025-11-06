/*
  Bronze Layer Support Tickets Model
  
  Purpose: Raw data ingestion from RAW.SUPPORT_TICKETS to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.SUPPORT_TICKETS to BZ_SUPPORT_TICKETS
  - Preserves all source data without transformation
  - Clean Bronze layer implementation
*/

{{ config(
    materialized='table'
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Primary identifier
        TICKET_ID,
        
        -- Support ticket information
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'support_tickets') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(TICKET_ID AS STRING) AS ticket_id,
        CAST(USER_ID AS STRING) AS user_id,
        CAST(TICKET_TYPE AS STRING) AS ticket_type,
        CAST(RESOLUTION_STATUS AS STRING) AS resolution_status,
        CAST(OPEN_DATE AS DATE) AS open_date,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
