-- Bronze Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Filter out null primary keys
),

-- Apply deduplication based on TICKET_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Data quality transformations
cleaned_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        COALESCE(TICKET_TYPE, 'General') as TICKET_TYPE,
        COALESCE(RESOLUTION_STATUS, 'Open') as RESOLUTION_STATUS,
        OPEN_DATE,
        -- Bronze Timestamp Overwrite Requirement
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') as SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM cleaned_data
