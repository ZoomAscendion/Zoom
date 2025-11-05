/*
  Bronze Layer Feature Usage Model
  Purpose: Raw data ingestion from RAW.FEATURE_USAGE to BRONZE.BZ_FEATURE_USAGE
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN USAGE_ID IS NULL THEN 'MISSING_USAGE_ID'
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN FEATURE_NAME IS NULL THEN 'MISSING_FEATURE_NAME'
            WHEN USAGE_COUNT IS NULL THEN 'MISSING_USAGE_COUNT'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw_zoom', 'feature_usage') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(USAGE_ID AS STRING) AS USAGE_ID,
        CAST(MEETING_ID AS STRING) AS MEETING_ID,
        CAST(FEATURE_NAME AS STRING) AS FEATURE_NAME,
        CAST(USAGE_COUNT AS NUMBER) AS USAGE_COUNT,
        CAST(USAGE_DATE AS DATE) AS USAGE_DATE,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
)

-- Final selection for Bronze layer
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
