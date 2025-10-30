{% macro calculate_data_quality_score(table_name, columns) %}
  (
    -- Completeness Score (40% weight)
    (
      {% for col in columns %}
        CASE WHEN {{ col }} IS NOT NULL THEN 1 ELSE 0 END
        {%- if not loop.last %} + {% endif %}
      {% endfor %}
    ) * 0.4 / {{ columns | length }}
    
    -- Validity Score (40% weight) - Basic format checks
    + CASE 
        WHEN EMAIL IS NOT NULL AND EMAIL LIKE '%@%' THEN 0.4
        WHEN EMAIL IS NULL THEN 0.4
        ELSE 0
      END
    
    -- Consistency Score (20% weight) - Basic business rule checks
    + CASE 
        WHEN START_TIME IS NOT NULL AND END_TIME IS NOT NULL AND END_TIME >= START_TIME THEN 0.2
        WHEN START_TIME IS NULL OR END_TIME IS NULL THEN 0.2
        ELSE 0
      END
  )
{% endmacro %}
