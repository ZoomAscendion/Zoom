/*
  Bronze Layer Billing Events Model
  Purpose: Raw data ingestion from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN EVENT_ID IS NULL THEN 'MISSING_EVENT_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN EVENT_TYPE IS NULL THEN 'MISSING_EVENT_TYPE'
            WHEN AMOUNT IS NULL THEN 'MISSING_AMOUNT'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw_zoom', 'billing_events') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(EVENT_ID AS STRING) AS EVENT_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(EVENT_TYPE AS STRING) AS EVENT_TYPE,
        CAST(AMOUNT AS NUMBER(10,2)) AS AMOUNT,
        CAST(EVENT_DATE AS DATE) AS EVENT_DATE,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
)

-- Final selection for Bronze layer
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
