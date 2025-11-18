{{ config(
    materialized='table',
    unique_key='order_id',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (record_id, source_table, process_start_time, process_status, created_at) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1, 'orders', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), process_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE source_table = 'orders' AND process_status = 'STARTED' AND '{{ this.name }}' != 'audit_log'"
) }}

WITH raw_orders AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        order_status,
        total_amount,
        currency,
        payment_method,
        shipping_address,
        billing_address,
        discount_amount,
        tax_amount,
        shipping_cost,
        order_source
    FROM {{ source('raw_schema', 'orders') }}
    WHERE order_id IS NOT NULL  -- Filter out NULL primary keys
),

deduped_orders AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY order_date DESC NULLS LAST
        ) AS row_num
    FROM raw_orders
),

final_orders AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        UPPER(TRIM(order_status)) AS order_status,
        COALESCE(total_amount, 0) AS total_amount,
        UPPER(TRIM(currency)) AS currency,
        TRIM(payment_method) AS payment_method,
        TRIM(shipping_address) AS shipping_address,
        TRIM(billing_address) AS billing_address,
        COALESCE(discount_amount, 0) AS discount_amount,
        COALESCE(tax_amount, 0) AS tax_amount,
        COALESCE(shipping_cost, 0) AS shipping_cost,
        TRIM(order_source) AS order_source,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'ACTIVE' AS process_status
    FROM deduped_orders
    WHERE row_num = 1
)

SELECT * FROM final_orders
