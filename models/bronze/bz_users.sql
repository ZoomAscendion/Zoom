/*
  Bronze Layer Users Model
  
  Purpose: Raw data ingestion from RAW.USERS to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.USERS to BZ_USERS
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
        USER_ID,
        
        -- User information
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'users') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(USER_ID AS STRING) AS user_id,
        CAST(USER_NAME AS STRING) AS user_name,
        CAST(EMAIL AS STRING) AS email,
        CAST(COMPANY AS STRING) AS company,
        CAST(PLAN_TYPE AS STRING) AS plan_type,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
