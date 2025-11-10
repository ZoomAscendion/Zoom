{% macro log_audit_event(process_name, source_table, target_table, status='STARTED') %}
  INSERT INTO {{ ref('go_audit_log') }} (
    PROCESS_ID,
    PROCESS_NAME,
    SOURCE_TABLE,
    TARGET_TABLE,
    PROCESS_START_TIME,
    PROCESS_STATUS,
    CREATED_AT,
    UPDATED_AT
  ) VALUES (
    GENERATE_UUID(),
    '{{ process_name }}',
    '{{ source_table }}',
    '{{ target_table }}',
    CURRENT_TIMESTAMP(),
    '{{ status }}',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
  )
{% endmacro %}

{% macro update_audit_event(process_name, status='COMPLETED', record_count=0) %}
  UPDATE {{ ref('go_audit_log') }}
  SET 
    PROCESS_END_TIME = CURRENT_TIMESTAMP(),
    PROCESS_STATUS = '{{ status }}',
    RECORDS_PROCESSED = {{ record_count }},
    RECORDS_SUCCESS = {{ record_count }},
    UPDATED_AT = CURRENT_TIMESTAMP()
  WHERE PROCESS_NAME = '{{ process_name }}'
    AND PROCESS_STATUS = 'STARTED'
{% endmacro %}

{% macro get_current_timestamp() %}
  CURRENT_TIMESTAMP()
{% endmacro %}

{% macro generate_uuid() %}
  GENERATE_UUID()
{% endmacro %}
