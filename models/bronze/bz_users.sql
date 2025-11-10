-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- Source: RAW.USERS -> BRONZE.BZ_USERS

{{ config(
    materialized='table',
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED'){% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS'){% endif %}"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Unique identifier for each user account
        USER_ID,
        
        -- Display name of the user (PII)
        USER_NAME,
        
        -- Email address of the user (PII)
        EMAIL,
        
        -- Company or organization name
        COMPANY,
        
        -- Subscription plan type
        PLAN_TYPE,
        
        -- Timestamp when record was loaded into system
        LOAD_TIMESTAMP,
        
        -- Timestamp when record was last updated
        UPDATE_TIMESTAMP,
        
        -- Source system from which data originated
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'users') }}
),

-- Data validation and cleansing
validated_data AS (
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
    -- Basic data quality checks
    WHERE USER_ID IS NOT NULL
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
