-- Bronze Layer Support Tickets Model
-- Author: DBT Pipeline Generator
-- Description: Transform raw support tickets data to bronze layer with audit information
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS

{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_START_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        VALUES (
            'BZ_SUPPORT_TICKETS', 
            CURRENT_TIMESTAMP(), 
            'STARTED', 
            'DBT_PIPELINE'
        )
    ",
    post_hook="
        INSERT INTO {{ ref('bz_audit_log') }} (
            SOURCE_TABLE, 
            PROCESS_END_TIME, 
            STATUS, 
            CREATED_BY
        ) 
        VALUES (
            'BZ_SUPPORT_TICKETS', 
            CURRENT_TIMESTAMP(), 
            'COMPLETED', 
            'DBT_PIPELINE'
        )
    "
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata columns from source
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw_schema', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Basic data quality check
),

-- CTE for data quality validation
validated_data AS (
    SELECT 
        *,
        -- Add row validation flags
        CASE 
            WHEN TICKET_ID IS NULL THEN 'INVALID_TICKET_ID'
            WHEN USER_ID IS NULL THEN 'INVALID_USER_ID'
            WHEN TICKET_TYPE IS NULL THEN 'INVALID_TICKET_TYPE'
            ELSE 'VALID'
        END AS data_quality_status
    FROM source_data
)

-- Final SELECT with error handling
SELECT 
    -- Business columns (direct 1:1 mapping)
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    
    -- Metadata columns (direct 1:1 mapping)
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
    
FROM validated_data
WHERE data_quality_status = 'VALID'
