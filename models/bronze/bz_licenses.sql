-- Bronze Licenses Model
-- Transforms raw licenses data to bronze layer with data quality checks
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
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_zoom', 'LICENSES') }}
    WHERE LICENSE_TYPE IS NOT NULL
      AND START_DATE IS NOT NULL
      AND END_DATE IS NOT NULL
),

-- Data cleansing and standardization
cleansed_data AS (
    SELECT 
        TRIM(UPPER(LICENSE_TYPE)) as license_type,
        TRIM(UPPER(ASSIGNED_TO_USER_ID)) as assigned_to_user_id,
        START_DATE as start_date,
        END_DATE as end_date,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(COALESCE(SOURCE_SYSTEM, 'UNKNOWN'))) as source_system
    FROM source_data
    WHERE START_DATE <= END_DATE
)

-- Final selection with audit information
SELECT 
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_data
