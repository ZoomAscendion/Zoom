-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'TICK001' as TICKET_ID,
        'USR001' as USER_ID,
        'Technical Issue' as TICKET_TYPE,
        'Resolved' as RESOLUTION_STATUS,
        '2024-01-01'::DATE as OPEN_DATE,
        '2024-01-01 16:00:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 16:00:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'SUPPORT_SYSTEM' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'TICK002',
        'USR002',
        'Billing Inquiry',
        'Open',
        '2024-01-01'::DATE,
        '2024-01-01 17:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 17:00:00'::TIMESTAMP_NTZ,
        'SUPPORT_SYSTEM'
    UNION ALL
    SELECT 
        'TICK003',
        'USR003',
        'Feature Request',
        'Closed',
        '2024-01-01'::DATE,
        '2024-01-01 18:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 18:00:00'::TIMESTAMP_NTZ,
        'SUPPORT_SYSTEM'
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

-- Final transformation with audit columns
final AS (
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
)

SELECT * FROM final
