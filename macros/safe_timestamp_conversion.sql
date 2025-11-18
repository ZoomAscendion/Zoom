{% macro safe_timestamp_conversion(column_name) %}
    COALESCE(
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'YYYY-MM-DD HH24:MI:SS'),
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'DD/MM/YYYY HH24:MI'),
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'MM/DD/YYYY HH24:MI'),
        TRY_TO_TIMESTAMP({{ column_name }}::STRING)
    )
{% endmacro %}
