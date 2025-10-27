-- Bronze Audit Log Model
-- This model creates the audit log table for tracking data processing activities
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

WITH audit_base AS (
    SELECT 
        1 as record_id,
        'AUDIT_LOG_INITIALIZATION' as source_table,
        CURRENT_TIMESTAMP() as load_timestamp,
        CURRENT_USER() as processed_by,
        0 as processing_time,
        'INITIALIZED' as status
)

SELECT 
    record_id,
    source_table::VARCHAR(255) as source_table,
    load_timestamp,
    processed_by::VARCHAR(255) as processed_by,
    processing_time,
    status::VARCHAR(50) as status
FROM audit_base
