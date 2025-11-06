/*
  Bronze Layer Billing Events Model
  
  Purpose: Raw data ingestion from RAW.BILLING_EVENTS to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.BILLING_EVENTS to BZ_BILLING_EVENTS
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
        EVENT_ID,
        
        -- Billing event information
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'billing_events') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(EVENT_ID AS STRING) AS event_id,
        CAST(USER_ID AS STRING) AS user_id,
        CAST(EVENT_TYPE AS STRING) AS event_type,
        CAST(AMOUNT AS NUMBER(10,2)) AS amount,
        CAST(EVENT_DATE AS DATE) AS event_date,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
