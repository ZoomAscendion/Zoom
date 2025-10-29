-- Bronze Layer Licenses Model
-- Transforms raw license data from RAW.LICENSES to BRONZE.BZ_LICENSES
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    post_hook="{{ audit_insert('BZ_LICENSES', "(SELECT COUNT(*) FROM " ~ this ~ ")") }}"
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
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
        SOURCE_SYSTEM,
        
        -- Data quality validation
        CASE 
            WHEN LICENSE_ID IS NULL THEN 'INVALID'
            WHEN LICENSE_TYPE IS NULL THEN 'INVALID'
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'licenses') }}
),

-- CTE for final data selection with error handling
final_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
