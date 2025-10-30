{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for billing events with data quality checks
WITH bronze_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_billing_events') }}
    WHERE event_id IS NOT NULL 
    AND TRIM(event_id) != ''
    AND user_id IS NOT NULL
    AND amount IS NOT NULL
    AND event_date IS NOT NULL
    AND event_date <= CURRENT_DATE()
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_billing_events
    WHERE rn = 1
),

validated_billing_events AS (
    SELECT 
        b.event_id,
        b.user_id,
        CASE 
            WHEN b.event_type IN ('Subscription', 'Upgrade', 'Downgrade', 'Refund')
            THEN b.event_type
            ELSE 'Other'
        END AS event_type,
        CASE 
            WHEN b.event_type = 'Refund' THEN ABS(b.amount) * -1
            ELSE ABS(b.amount)
        END AS transaction_amount,
        b.event_date AS transaction_date,
        'Credit Card' AS payment_method,
        'USD' AS currency_code,
        CONCAT('INV-', b.event_id, '-', DATE_PART('year', b.event_date)) AS invoice_number,
        CASE 
            WHEN b.amount > 0 THEN 'Completed'
            ELSE 'Failed'
        END AS transaction_status,
        b.load_timestamp,
        b.update_timestamp,
        b.source_system
    FROM deduped_billing_events b
    INNER JOIN {{ ref('si_users') }} u ON b.user_id = u.user_id
),

final_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        transaction_amount,
        transaction_date,
        payment_method,
        currency_code,
        invoice_number,
        transaction_status,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN event_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN user_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN event_type != 'Other' THEN 0.2 ELSE 0 END +
             CASE WHEN transaction_amount IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN transaction_date IS NOT NULL THEN 0.2 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_billing_events
)

SELECT * FROM final_billing_events
