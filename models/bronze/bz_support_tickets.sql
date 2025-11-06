-- =====================================================
-- Bronze Layer Support Tickets Model
-- =====================================================
-- Description: Raw support ticket data from source system with 1:1 mapping
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        {% if target.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
        {% endif %}
    """,
    post_hook="""
        {% if target.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 30, 'COMPLETED')
        {% endif %}
    """
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary support ticket information (1:1 mapping from source)
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'support_tickets') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(TICKET_ID AS STRING) AS TICKET_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(TICKET_TYPE AS STRING) AS TICKET_TYPE,
        CAST(RESOLUTION_STATUS AS STRING) AS RESOLUTION_STATUS,
        
        -- Preserve date values
        OPEN_DATE,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
