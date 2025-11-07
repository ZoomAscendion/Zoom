{% macro log_audit_start(model_name, source_table) %}
  {% if execute %}
    {% set audit_sql %}
      INSERT INTO {{ ref('go_audit_log') }} 
      (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM)
      VALUES 
      ('{{ model_name }}_LOAD', '{{ source_table }}', '{{ model_name }}', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')
    {% endset %}
    {% do run_query(audit_sql) %}
  {% endif %}
{% endmacro %}

{% macro log_audit_end(model_name, source_table) %}
  {% if execute %}
    {% set audit_sql %}
      INSERT INTO {{ ref('go_audit_log') }} 
      (PROCESS_NAME, SOURCE_TABLE, TARGET_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, RECORDS_PROCESSED, RECORDS_SUCCESS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM)
      VALUES 
      ('{{ model_name }}_LOAD', '{{ source_table }}', '{{ model_name }}', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 
       (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')
    {% endset %}
    {% do run_query(audit_sql) %}
  {% endif %}
{% endmacro %}
