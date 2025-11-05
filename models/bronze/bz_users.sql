/*
  Bronze Layer Users Model
  Purpose: Raw data ingestion from RAW.USERS to BRONZE.BZ_USERS
  Transformation: 1-1 mapping with data quality checks
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
      SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'
      WHERE EXISTS (SELECT 1 FROM {{ ref('bz_audit_log') }} LIMIT 1)
    ",
    post_hook="
      UPDATE {{ ref('bz_audit_log') }} 
      SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
          STATUS = 'COMPLETED'
      WHERE SOURCE_TABLE = 'BZ_USERS' 
      AND STATUS = 'STARTED'
      AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = 'BZ_USERS' AND STATUS = 'STARTED')
    "
) }}

-- Raw data extraction with error handling
WITH source_data AS (
    SELECT 
        -- Primary data fields (1-1 mapping from RAW to BRONZE)
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata fields
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality indicators
        CASE 
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN EMAIL IS NULL THEN 'MISSING_EMAIL'
            WHEN USER_NAME IS NULL THEN 'MISSING_USER_NAME'
            ELSE 'VALID'
        END AS data_quality_flag,
        
        -- Add row number to handle duplicates
        ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY LOAD_TIMESTAMP DESC) AS rn
        
    FROM {{ source('raw_zoom', 'users') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(USER_NAME AS STRING) AS USER_NAME,
        CAST(EMAIL AS STRING) AS EMAIL,
        CAST(COMPANY AS STRING) AS COMPANY,
        CAST(PLAN_TYPE AS STRING) AS PLAN_TYPE,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    WHERE data_quality_flag = 'VALID'  -- Only process valid records
    AND rn = 1  -- Take only the most recent record for each USER_ID
)

-- Final selection for Bronze layer
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
