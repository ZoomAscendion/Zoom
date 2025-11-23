-- Bronze Layer Support Tickets Model
-- Description: Transforms raw support ticket data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH raw_support_tickets AS (
    -- Select from raw support tickets table with null filtering for primary keys
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
),

deduped_support_tickets AS (
    -- Apply deduplication based on ticket_id, keeping the latest record
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) as rn
        FROM raw_support_tickets
    )
    WHERE rn = 1
),

final_support_tickets AS (
    -- Final transformation
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'unknown') AS SOURCE_SYSTEM
    FROM deduped_support_tickets
)

SELECT * FROM final_support_tickets
