{% macro safe_to_number(column_name) %}
    TRY_TO_NUMBER(REGEXP_REPLACE({{ column_name }}::STRING, '[^0-9.]', ''))
{% endmacro %}
