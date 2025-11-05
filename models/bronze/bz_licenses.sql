/*
  Bronze Layer Licenses Model
  Purpose: Raw data ingestion from RAW.LICENSES to BRONZE.BZ_LICENSES
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_LICENSES' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN LICENSE_ID IS NULL THEN 'MISSING_LICENSE_ID'
            WHEN LICENSE_TYPE IS NULL THEN 'MISSING_LICENSE_TYPE'
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 'MISSING_ASSIGNED_TO_USER_ID'
            WHEN START_DATE IS NULL THEN 'MISSING_START_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw_zoom', 'licenses') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(LICENSE_ID AS STRING) AS LICENSE_ID,
        CAST(LICENSE_TYPE AS STRING) AS LICENSE_TYPE,
        CAST(ASSIGNED_TO_USER_ID AS STRING) AS ASSIGNED_TO_USER_ID,
        CAST(START_DATE AS DATE) AS START_DATE,
        CAST(END_DATE AS DATE) AS END_DATE,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
)

-- Final selection for Bronze layer
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
