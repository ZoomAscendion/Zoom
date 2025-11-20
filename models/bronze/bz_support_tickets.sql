-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Create sample data for Bronze Support Tickets table
WITH sample_support_tickets AS (
    SELECT 
        'TICK001' as TICKET_ID,
        'USER001' as USER_ID,
        'Technical Issue' as TICKET_TYPE,
        'Resolved' as RESOLUTION_STATUS,
        CURRENT_DATE() - 2 as OPEN_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
    
    UNION ALL
    
    SELECT 
        'TICK002' as TICKET_ID,
        'USER002' as USER_ID,
        'Billing Inquiry' as TICKET_TYPE,
        'Open' as RESOLUTION_STATUS,
        CURRENT_DATE() - 1 as OPEN_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
        
    UNION ALL
    
    SELECT 
        'TICK003' as TICKET_ID,
        'USER003' as USER_ID,
        'Feature Request' as TICKET_TYPE,
        'In Progress' as RESOLUTION_STATUS,
        CURRENT_DATE() as OPEN_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
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
FROM sample_support_tickets
