-- Bronze Layer Users Model
-- Transforms raw user data from RAW.USERS to BRONZE.BZ_USERS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality validation
        CASE 
            WHEN USER_ID IS NULL THEN 'INVALID'
            WHEN EMAIL IS NULL THEN 'INVALID'
            WHEN USER_NAME IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'users') }}
),

-- CTE for final data selection with error handling
final_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
