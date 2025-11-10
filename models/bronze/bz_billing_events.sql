-- Bronze Layer Billing Events Table
-- Description: Raw financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED') WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'COMPLETED') WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Extract raw billing event data from source system
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'billing_events') }}
),

validated_data AS (
    -- Apply basic data validation and cleansing
    SELECT 
        -- Primary identifier
        EVENT_ID,
        
        -- Relationship identifier
        USER_ID,
        
        -- Billing event details
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM source_data
    WHERE EVENT_ID IS NOT NULL  -- Ensure primary key is not null
)

SELECT * FROM validated_data
