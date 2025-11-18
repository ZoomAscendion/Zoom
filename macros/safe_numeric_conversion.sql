{% macro safe_numeric_conversion(column_name) %}
  CASE 
    WHEN TRY_TO_NUMBER(REGEXP_REPLACE({{ column_name }}::STRING, '[^0-9.]', '')) IS NOT NULL THEN
         TRY_TO_NUMBER(REGEXP_REPLACE({{ column_name }}::STRING, '[^0-9.]', ''))
    ELSE TRY_TO_NUMBER({{ column_name }}::STRING)
  END
{% endmacro %}
