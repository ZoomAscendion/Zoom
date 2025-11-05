{{ config(
    materialized='table'
) }}

WITH bronze_billing_events AS (
    SELECT *
    FROM {{ source('bronze', 'bz_billing_events') }}
),

data_quality_checks AS (
    SELECT 
        *,
        -- Amount validation
        CASE 
            WHEN amount IS NOT NULL AND (amount > 0 OR (amount < 0 AND event_type = 'Refund')) THEN 1
            ELSE 0
        END AS amount_quality,
        
        -- Event type validation
        CASE 
            WHEN event_type IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN 1
            ELSE 0
        END AS type_quality,
        
        -- Date validation
        CASE 
            WHEN event_date IS NOT NULL AND event_date <= CURRENT_DATE() THEN 1
            ELSE 0
        END AS date_quality,
        
        -- User validation
        CASE 
            WHEN user_id IS NOT NULL THEN 1
            ELSE 0
        END AS user_quality
    FROM bronze_billing_events
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY event_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        event_id,
        user_id,
        CASE 
            WHEN event_type IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund') THEN event_type
            WHEN amount < 0 THEN 'Refund'
            ELSE 'Subscription'
        END AS event_type,
        ABS(amount) AS transaction_amount,
        event_date AS transaction_date,
        CASE 
            WHEN amount >= 100 THEN 'Credit Card'
            WHEN amount >= 50 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS payment_method,
        'USD' AS currency_code,
        CONCAT('INV-', event_id) AS invoice_number,
        CASE 
            WHEN amount > 0 THEN 'Completed'
            WHEN amount < 0 THEN 'Refunded'
            ELSE 'Pending'
        END AS transaction_status,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        ROUND(
            (amount_quality + type_quality + date_quality + user_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM deduplication
    WHERE rn = 1
      AND event_id IS NOT NULL
      AND user_id IS NOT NULL
      AND amount IS NOT NULL
      AND event_date IS NOT NULL
)

SELECT * FROM final_transformation
