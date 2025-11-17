{% macro safe_to_date(column_name) %}
    COALESCE(
        TRY_TO_DATE({{ column_name }}::STRING, 'YYYY-MM-DD'),
        TRY_TO_DATE({{ column_name }}::STRING, 'DD/MM/YYYY'),
        TRY_TO_DATE({{ column_name }}::STRING, 'MM/DD/YYYY'),
        {{ column_name }}
    )
{% endmacro %}
