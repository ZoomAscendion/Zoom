-- Bronze Layer Licenses Model
-- Transforms raw license data from RAW.LICENSES to BRONZE.BZ_LICENSES
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    
    -- Metadata columns
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM {{ source('raw', 'licenses') }}
WHERE LICENSE_ID IS NOT NULL
  AND LICENSE_TYPE IS NOT NULL
  AND ASSIGNED_TO_USER_ID IS NOT NULL
