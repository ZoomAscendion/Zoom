-- =====================================================
-- Bronze Layer Audit Log Model
-- =====================================================
-- Description: Audit table for tracking all bronze layer data processing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('{{ this.name }}', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
        {% endif %}
    """,
    post_hook="""
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('{{ this.name }}', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', 
                (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = '{{ this.name }}' AND STATUS = 'STARTED'), 
                CURRENT_TIMESTAMP()), 'COMPLETED')
        {% endif %}
    """
) }}

-- Create audit log table structure
SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    CAST('SYSTEM_INIT' AS VARCHAR(255)) AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CAST('DBT_INIT' AS VARCHAR(100)) AS PROCESSED_BY,
    CAST(0 AS NUMBER) AS PROCESSING_TIME,
    CAST('INITIALIZED' AS VARCHAR(50)) AS STATUS
WHERE FALSE -- This ensures no actual data is inserted during initial creation
