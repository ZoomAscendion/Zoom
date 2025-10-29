-- Bronze Layer Users Model
-- Transforms raw user data from RAW.USERS to BRONZE.BZ_USERS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table'
) }}

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
        
        -- Data quality flags
        CASE 
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN EMAIL IS NULL THEN 'MISSING_EMAIL'
            WHEN USER_NAME IS NULL THEN 'MISSING_USER_NAME'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'users') }}
),

-- CTE for final data selection
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
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
