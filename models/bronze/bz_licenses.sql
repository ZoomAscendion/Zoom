/*
  Bronze Layer Licenses Model
  
  Purpose: Raw data ingestion from RAW.LICENSES to Bronze layer
  Author: DBT Data Engineer
  Created: {{ run_started_at }}
  
  Description:
  - 1:1 mapping from RAW.LICENSES to BZ_LICENSES
  - Preserves all source data without transformation
  - Adds audit trail through pre/post hooks
*/

{{ config(
    materialized='table'
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Primary identifier
        LICENSE_ID,
        
        -- License information
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_zoom_data', 'licenses') }}
),

-- Data validation and cleansing (minimal for Bronze layer)
validated_data AS (
    SELECT 
        -- Convert data types to Bronze layer standards
        CAST(LICENSE_ID AS STRING) AS license_id,
        CAST(LICENSE_TYPE AS STRING) AS license_type,
        CAST(ASSIGNED_TO_USER_ID AS STRING) AS assigned_to_user_id,
        CAST(START_DATE AS DATE) AS start_date,
        CAST(END_DATE AS DATE) AS end_date,
        
        -- Preserve original timestamps
        CAST(LOAD_TIMESTAMP AS TIMESTAMP_NTZ) AS load_timestamp,
        CAST(UPDATE_TIMESTAMP AS TIMESTAMP_NTZ) AS update_timestamp,
        CAST(SOURCE_SYSTEM AS STRING) AS source_system
        
    FROM source_data
)

-- Final selection for Bronze layer
SELECT * FROM validated_data
