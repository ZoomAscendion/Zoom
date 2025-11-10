-- Bronze Layer Users Table
-- Description: Raw user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED') WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'COMPLETED') WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Extract raw user data from source system
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'users') }}
),

validated_data AS (
    -- Apply basic data validation and cleansing
    SELECT 
        -- Primary identifier
        USER_ID,
        
        -- User profile information
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM source_data
    WHERE USER_ID IS NOT NULL  -- Ensure primary key is not null
)

SELECT * FROM validated_data
