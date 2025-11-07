-- Bronze Layer Support Tickets Table
-- Description: Raw customer support requests and resolution tracking from source systems
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS
-- Transformation: 1-1 mapping with audit metadata

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT CAST('BZ_SUPPORT_TICKETS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(0.0 AS NUMBER(38,3)), CAST('STARTED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT CAST('BZ_SUPPORT_TICKETS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()) AS NUMBER(38,3)), CAST('COMPLETED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Source data extraction with data quality checks
WITH source_data AS (
    SELECT 
        -- Primary identifier
        TICKET_ID,
        
        -- Ticket details
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- System metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Basic data quality check
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_data
)

-- Final selection for Bronze layer
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
