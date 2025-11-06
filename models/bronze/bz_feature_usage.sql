/*
  Bronze Layer Feature Usage Model
  
  Purpose: Raw data ingestion from RAW.FEATURE_USAGE to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.FEATURE_USAGE to BZ_FEATURE_USAGE
  - Preserves all source data without transformation
  - Adds audit trail through pre/post hooks
*/

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.BZ_AUDIT_LOG (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')",
    post_hook="UPDATE {{ this.database }}.{{ this.schema }}.BZ_AUDIT_LOG SET STATUS = 'COMPLETED', PROCESSING_TIME = 1 WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Primary identifier
        USAGE_ID,
        
        -- Feature usage information
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'feature_usage') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(USAGE_ID AS STRING) AS usage_id,
        CAST(MEETING_ID AS STRING) AS meeting_id,
        CAST(FEATURE_NAME AS STRING) AS feature_name,
        CAST(USAGE_COUNT AS NUMBER) AS usage_count,
        CAST(USAGE_DATE AS DATE) AS usage_date,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
