-- Bronze Support Tickets Model
-- Transforms raw support tickets data to bronze layer with data quality checks
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                '{{ this.name }}' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                CURRENT_USER() as processed_by,
                0 as processing_time,
                'STARTED' as status
        {% endif %}
    """,
    post_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                '{{ this.name }}' as source_table,
                CURRENT_TIMESTAMP() as load_timestamp,
                CURRENT_USER() as processed_by,
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_audit_log') }} WHERE source_table = '{{ this.name }}' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ) as processing_time,
                'COMPLETED' as status
        {% endif %}
    """
) }}

-- Data quality and transformation layer
WITH source_data AS (
    SELECT 
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_zoom', 'SUPPORT_TICKETS') }}
    WHERE USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
),

-- Data cleansing and standardization
cleansed_data AS (
    SELECT 
        TRIM(UPPER(USER_ID)) as user_id,
        TRIM(UPPER(TICKET_TYPE)) as ticket_type,
        TRIM(UPPER(RESOLUTION_STATUS)) as resolution_status,
        OPEN_DATE as open_date,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(COALESCE(SOURCE_SYSTEM, 'UNKNOWN'))) as source_system
    FROM source_data
)

-- Final selection with audit information
SELECT 
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_data
