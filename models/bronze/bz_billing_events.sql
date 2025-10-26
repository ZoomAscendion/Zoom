/*
  Bronze Layer Billing Events Model
  Purpose: Clean and validate billing events data from raw layer
  Source: RAW.BILLING_EVENTS
  Target: BRONZE.BZ_BILLING_EVENTS
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table'
) }}

WITH raw_billing_events AS (
    SELECT 
        -- Source data extraction with data quality checks
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_zoom', 'billing_events') }}
    WHERE user_id IS NOT NULL
      AND event_type IS NOT NULL
      AND amount IS NOT NULL
      AND event_date IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Add data quality flags
        CASE 
            WHEN amount < 0 THEN 'NEGATIVE_AMOUNT'
            WHEN event_date > CURRENT_DATE() THEN 'FUTURE_DATE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM raw_billing_events
),

final_bronze AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        user_id::STRING AS user_id,
        event_type::STRING AS event_type,
        amount::NUMBER(10,2) AS amount,
        event_date::DATE AS event_date,
        load_timestamp::TIMESTAMP_NTZ AS load_timestamp,
        update_timestamp::TIMESTAMP_NTZ AS update_timestamp,
        source_system::STRING AS source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_bronze
