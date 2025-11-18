-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ this.name }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        VALUES ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_{{ this.name }}', 
                DATEDIFF('seconds', 
                    (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), 
                    CURRENT_TIMESTAMP()), 
                'COMPLETED')
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary keys
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
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on TICKET_ID and LOAD_TIMESTAMP
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY TICKET_ID 
               ORDER BY LOAD_TIMESTAMP DESC, 
                        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) as rn
    FROM source_data
)

-- Final selection with audit columns
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
WHERE rn = 1
