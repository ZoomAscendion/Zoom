-- Bronze Layer Support Tickets Model
-- Description: Transforms raw support tickets data to bronze layer with data quality checks
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.bz_support_tickets
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_support_tickets', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_support_tickets', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
) }}

WITH raw_support_tickets AS (
    SELECT 
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'SUPPORT_TICKETS') }}
),

-- Data quality and cleansing transformations
cleansed_support_tickets AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(USER_ID)::STRING as user_id,
        TRIM(UPPER(TICKET_TYPE))::STRING as ticket_type,
        TRIM(UPPER(RESOLUTION_STATUS))::STRING as resolution_status,
        OPEN_DATE::DATE as open_date,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
    FROM raw_support_tickets
    WHERE USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
)

-- Final select for bronze layer
SELECT 
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_support_tickets
