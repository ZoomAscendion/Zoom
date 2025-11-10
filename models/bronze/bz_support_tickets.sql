-- Bronze Layer Support Tickets Table
-- Description: Raw customer support requests and resolution tracking from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT CAST('BZ_SUPPORT_TICKETS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_SYSTEM' AS VARCHAR(255)), CAST(0.0 AS NUMBER(38,3)), CAST('STARTED' AS VARCHAR(255)) WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT CAST('BZ_SUPPORT_TICKETS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_SYSTEM' AS VARCHAR(255)), CAST(DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_SUPPORT_TICKETS' AND status = 'STARTED'), CURRENT_TIMESTAMP()) AS NUMBER(38,3)), CAST('SUCCESS' AS VARCHAR(255)) WHERE '{{ this.name }}' != 'bz_data_audit'"
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
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw_schema', 'support_tickets') }}
),

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
    WHERE row_num = 1
),

final AS (
    SELECT 
        -- Direct 1:1 mapping from RAW to Bronze layer
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final
