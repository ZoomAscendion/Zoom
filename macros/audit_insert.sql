-- Macro for inserting audit records
-- This macro helps insert audit information for each model run

{% macro audit_insert(table_name, record_count, status='SUCCESS', error_message=null) %}
    INSERT INTO {{ ref('bz_audit_log') }} (
        SOURCE_TABLE,
        PROCESS_START_TIME,
        PROCESS_END_TIME,
        STATUS,
        RECORD_COUNT,
        ERROR_MESSAGE,
        PROCESSED_BY,
        CREATED_TIMESTAMP
    )
    VALUES (
        '{{ table_name }}',
        CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE',
        CURRENT_TIMESTAMP(),
        '{{ status }}',
        {{ record_count }},
        {% if error_message %}'{{ error_message }}'{% else %}NULL{% endif %},
        'DBT_SYSTEM',
        CURRENT_TIMESTAMP()
    )
{% endmacro %}
