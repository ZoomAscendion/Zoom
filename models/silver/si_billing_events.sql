{{
  config(
    materialized='incremental',
    unique_key='billing_event_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge',
    pre_hook="
      {% if target.name != 'audit_log' %}
        INSERT INTO {{ ref('audit_log') }} (
          audit_id, pipeline_name, start_time, status, execution_id, 
          execution_start_time, source_table, target_table, execution_status, 
          processed_by, load_timestamp
        )
        VALUES (
          '{{ dbt_utils.generate_surrogate_key(['si_billing_events', run_started_at]) }}',
          'si_billing_events_transformation',
          '{{ run_started_at }}',
          'RUNNING',
          '{{ invocation_id }}',
          '{{ run_started_at }}',
          'bz_billing_events',
          'si_billing_events',
          'STARTED',
          'DBT_SILVER_PIPELINE',
          '{{ run_started_at }}'
        )
      {% endif %}
    ",
    post_hook="
      {% if target.name != 'audit_log' %}
        INSERT INTO {{ ref('audit_log') }} (
          audit_id, pipeline_name, end_time, status, execution_id, 
          execution_end_time, source_table, target_table, execution_status, 
          processed_by, load_timestamp, records_processed
        )
        VALUES (
          '{{ dbt_utils.generate_surrogate_key(['si_billing_events_complete', run_started_at]) }}',
          'si_billing_events_transformation',
          CURRENT_TIMESTAMP(),
          'SUCCESS',
          '{{ invocation_id }}',
          CURRENT_TIMESTAMP(),
          'bz_billing_events',
          'si_billing_events',
          'COMPLETED',
          'DBT_SILVER_PIPELINE',
          CURRENT_TIMESTAMP(),
          (SELECT COUNT(*) FROM {{ this }})
        )
      {% endif %}
    "
  )
}}

-- Silver Billing Events Table Transformation
-- Transforms bronze billing data with amount validation and standardization

WITH bronze_billing AS (
    SELECT 
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE user_id IS NOT NULL 
      AND event_type IS NOT NULL
      AND amount IS NOT NULL
      AND amount > 0
      AND amount <= 10000
      AND event_date IS NOT NULL
      AND event_date <= CURRENT_DATE()
),

deduped_billing AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, event_type, event_date, amount 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_billing
),

transformed_billing AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['user_id', 'event_date', 'event_type', 'amount']) }} AS billing_event_id,
        
        -- Direct Mappings
        user_id,
        
        -- Standardized Event Types
        CASE 
            WHEN UPPER(event_type) IN ('PAYMENT', 'PAY', 'CHARGE') THEN 'Payment'
            WHEN UPPER(event_type) IN ('REFUND', 'RETURN') THEN 'Refund'
            WHEN UPPER(event_type) IN ('SUBSCRIPTION', 'SUB', 'RECURRING') THEN 'Subscription'
            WHEN UPPER(event_type) IN ('UPGRADE', 'UP') THEN 'Upgrade'
            WHEN UPPER(event_type) IN ('DOWNGRADE', 'DOWN') THEN 'Downgrade'
            ELSE 'Payment'
        END AS event_type,
        
        ROUND(amount, 2) AS amount,
        event_date,
        
        -- Derived Attributes
        'USD' AS currency_code,
        
        CASE 
            WHEN UPPER(event_type) IN ('PAYMENT', 'PAY', 'CHARGE') THEN 'Credit Card'
            WHEN UPPER(event_type) IN ('SUBSCRIPTION', 'SUB', 'RECURRING') THEN 'Auto Pay'
            ELSE 'Unknown'
        END AS payment_method,
        
        'Completed' AS transaction_status,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN event_type IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN amount > 0 AND amount <= 10000 THEN 0.25 ELSE 0 END +
             CASE WHEN event_date IS NOT NULL AND event_date <= CURRENT_DATE() THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_billing
    WHERE row_num = 1
)

SELECT * FROM transformed_billing

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
