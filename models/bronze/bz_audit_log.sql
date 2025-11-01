-- Bronze Layer Audit Log Model
-- Author: DBT Pipeline Generator
-- Description: Audit table for tracking data processing activities in Bronze layer
-- Target: BRONZE.BZ_AUDIT_LOG

{{ config(
    materialized='table',
    pre_hook="
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (
                SOURCE_TABLE, 
                PROCESS_START_TIME, 
                STATUS, 
                CREATED_BY
            ) 
            VALUES (
                '{{ this.name }}', 
                CURRENT_TIMESTAMP(), 
                'STARTED', 
                'DBT_PIPELINE'
            )
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_audit_log' %}
            INSERT INTO {{ ref('bz_audit_log') }} (
                SOURCE_TABLE, 
                PROCESS_END_TIME, 
                STATUS, 
                CREATED_BY
            ) 
            VALUES (
                '{{ this.name }}', 
                CURRENT_TIMESTAMP(), 
                'COMPLETED', 
                'DBT_PIPELINE'
            )
        {% endif %}
    "
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP()) AS RECORD_ID,
    CAST('AUDIT_LOG_INIT' AS VARCHAR(255)) AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS PROCESS_START_TIME,
    CURRENT_TIMESTAMP() AS PROCESS_END_TIME,
    CAST('INITIALIZED' AS VARCHAR(50)) AS STATUS,
    CAST('DBT_PIPELINE' AS VARCHAR(100)) AS CREATED_BY,
    CURRENT_TIMESTAMP() AS CREATED_TIMESTAMP
WHERE FALSE -- This ensures the table structure is created but no initial data is inserted

UNION ALL

SELECT 
    1 AS RECORD_ID,
    CAST('SYSTEM_INIT' AS VARCHAR(255)) AS SOURCE_TABLE,
    CURRENT_TIMESTAMP() AS PROCESS_START_TIME,
    CURRENT_TIMESTAMP() AS PROCESS_END_TIME,
    CAST('SYSTEM_READY' AS VARCHAR(50)) AS STATUS,
    CAST('DBT_SYSTEM' AS VARCHAR(100)) AS CREATED_BY,
    CURRENT_TIMESTAMP() AS CREATED_TIMESTAMP
