-- Macro for audit logging
{% macro log_audit_start(table_name) %}
    {% if target.name != 'bz_data_audit' %}
        INSERT INTO {{ target.schema }}.BZ_DATA_AUDIT 
        (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) 
        VALUES ('{{ table_name }}', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED')
    {% endif %}
{% endmacro %}

{% macro log_audit_success(table_name) %}
    {% if target.name != 'bz_data_audit' %}
        INSERT INTO {{ target.schema }}.BZ_DATA_AUDIT 
        (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) 
        VALUES ('{{ table_name }}', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
        DATEDIFF('second', 
            (SELECT MAX(LOAD_TIMESTAMP) FROM {{ target.schema }}.BZ_DATA_AUDIT 
             WHERE SOURCE_TABLE = '{{ table_name }}' AND STATUS = 'STARTED'), 
            CURRENT_TIMESTAMP()), 'SUCCESS')
    {% endif %}
{% endmacro %}
