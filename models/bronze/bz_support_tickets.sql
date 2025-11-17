-- Bronze Layer Support Tickets Table
-- Description: Raw customer support requests and resolution tracking from source systems
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), CURRENT_USER(), 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), CURRENT_USER(), 'COMPLETED')
        {% endif %}
    "
) }}

-- CTE for data extraction and deduplication
WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('raw_schema', 'support_tickets') }}
),

-- Final deduplication
deduped_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1
)

-- Final select with data quality checks
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE TICKET_ID IS NOT NULL  -- Basic data quality check
