-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
               DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_SUPPORT_TICKETS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 
               'COMPLETED'
        {% endif %}
    "
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
    FROM {{ source('raw_schema', 'SUPPORT_TICKETS') }}
    WHERE TICKET_ID IS NOT NULL  -- Filter out NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY LOAD_TIMESTAMP DESC, UPDATE_TIMESTAMP DESC NULLS LAST
        ) as rn
    FROM source_data
)

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
