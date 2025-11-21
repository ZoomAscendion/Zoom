-- Bronze Layer Support Tickets Model
-- Description: Transforms raw support ticket data into bronze layer with audit logging
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP as RAW_LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP as RAW_UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY RAW_LOAD_TIMESTAMP DESC) as rn
    FROM raw_support_tickets
)

-- Final selection with bronze timestamp overwrite
SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current DBT run time
    SOURCE_SYSTEM
FROM deduped_support_tickets
WHERE rn = 1  -- Keep only the most recent record per TICKET_ID
