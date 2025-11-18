{% macro safe_to_number(column_name, default_value=0) %}
    CASE 
        WHEN TRY_TO_NUMBER(REGEXP_REPLACE({{ column_name }}::STRING, '[^0-9.]', '')) IS NOT NULL THEN 
            TRY_TO_NUMBER(REGEXP_REPLACE({{ column_name }}::STRING, '[^0-9.]', ''))
        ELSE {{ default_value }}
    END
{% endmacro %}
