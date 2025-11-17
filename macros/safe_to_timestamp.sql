{% macro safe_to_timestamp(column_name) %}
    COALESCE(
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'YYYY-MM-DD HH24:MI:SS'),
        TRY_TO_TIMESTAMP(REGEXP_REPLACE({{ column_name }}::STRING, '\\s*(EST|PST|CST|IST|UTC)', ''), 'YYYY-MM-DD HH24:MI:SS'),
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'MM/DD/YYYY HH24:MI'),
        TRY_TO_TIMESTAMP({{ column_name }}::STRING, 'DD/MM/YYYY HH24:MI'),
        {{ column_name }}
    )
{% endmacro %}
