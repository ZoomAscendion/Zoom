{% macro safe_to_date(column_name, default_value='CURRENT_DATE()') %}
    COALESCE(
        TRY_TO_DATE({{ column_name }}::STRING, 'DD/MM/YYYY'),
        TRY_TO_DATE({{ column_name }}::STRING, 'YYYY-MM-DD'),
        TRY_TO_DATE({{ column_name }}::STRING, 'MM/DD/YYYY'),
        TRY_TO_DATE({{ column_name }}::STRING),
        {{ default_value }}
    )
{% endmacro %}
