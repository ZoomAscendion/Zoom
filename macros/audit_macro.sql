-- Audit Macro for Bronze Layer Processing
-- Description: Provides reusable audit functionality for all bronze models
-- Author: DBT Data Engineer

{% macro log_model_execution(model_name, status='STARTED') %}
    {% if status == 'STARTED' %}
        INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status)
        VALUES ('{{ model_name }}', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED')
    {% elif status == 'COMPLETED' %}
        UPDATE {{ ref('bz_audit_log') }}
        SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()),
            status = 'COMPLETED'
        WHERE source_table = '{{ model_name }}' 
          AND status = 'STARTED'
          AND load_timestamp = (SELECT MAX(load_timestamp) FROM {{ ref('bz_audit_log') }} WHERE source_table = '{{ model_name }}' AND status = 'STARTED')
    {% endif %}
{% endmacro %}

{% macro get_current_timestamp() %}
    CURRENT_TIMESTAMP()
{% endmacro %}

{% macro validate_not_null(column_name) %}
    {{ column_name }} IS NOT NULL
{% endmacro %}

{% macro clean_string(column_name) %}
    TRIM({{ column_name }})
{% endmacro %}

{% macro standardize_status(column_name) %}
    TRIM(UPPER({{ column_name }}))
{% endmacro %}
