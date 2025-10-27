-- Bronze Users Model
-- Transforms raw users data to bronze layer with data quality checks
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
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_zoom', 'USERS') }}
    WHERE USER_NAME IS NOT NULL
      AND EMAIL IS NOT NULL
      AND PLAN_TYPE IS NOT NULL
),

-- Data cleansing and standardization
cleansed_data AS (
    SELECT 
        TRIM(USER_NAME) as user_name,
        TRIM(LOWER(EMAIL)) as email,
        TRIM(UPPER(COALESCE(COMPANY, 'UNKNOWN'))) as company,
        TRIM(UPPER(PLAN_TYPE)) as plan_type,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(COALESCE(SOURCE_SYSTEM, 'UNKNOWN'))) as source_system
    FROM source_data
    WHERE EMAIL LIKE '%@%'
)

-- Final selection with audit information
SELECT 
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_data
