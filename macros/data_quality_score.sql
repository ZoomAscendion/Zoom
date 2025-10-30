{% macro calculate_data_quality_score() %}
  CASE 
    WHEN COUNT(*) = 0 THEN 0.0
    ELSE ROUND(
      (
        -- Completeness check (weight: 0.6)
        CASE WHEN USER_ID IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN USER_NAME IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN EMAIL IS NOT NULL THEN 0.2 ELSE 0 END +
        
        -- Validity check (weight: 0.4)
        CASE WHEN EMAIL LIKE '%@%' OR EMAIL IS NULL THEN 0.4 ELSE 0 END
      ), 2
    )
  END
{% endmacro %}
