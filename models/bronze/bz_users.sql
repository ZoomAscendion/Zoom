-- Bronze Layer Users Model
-- Transforms raw user data from RAW.USERS to BRONZE.BZ_USERS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

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
    SOURCE_SYSTEM
    
FROM {{ source('raw', 'users') }}
WHERE USER_ID IS NOT NULL
