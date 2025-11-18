{{ config(
    materialized='table',
    unique_key='order_id'
) }}

{% if this.name != 'audit_log' %}
    {% set audit_start %}
        INSERT INTO {{ ref('audit_log') }} (
            record_id, source_table, process_start_time, process_status, created_at
        ) 
        SELECT 
            COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1,
            'orders',
            CURRENT_TIMESTAMP(),
            'STARTED',
            CURRENT_TIMESTAMP()
    {% endset %}
    
    {% set audit_end %}
        INSERT INTO {{ ref('audit_log') }} (
            record_id, source_table, process_start_time, process_end_time, process_status, records_processed, created_at
        )
        SELECT 
            COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1,
            'orders',
            CURRENT_TIMESTAMP(),
            CURRENT_TIMESTAMP(),
            'COMPLETED',
            (SELECT COUNT(*) FROM {{ this }}),
            CURRENT_TIMESTAMP()
    {% endset %}
    
    {{ config(pre_hook=audit_start, post_hook=audit_end) }}
{% endif %}

WITH source_data AS (
    SELECT 
        'ORD001' AS order_id,
        'CUST001' AS customer_id,
        '2024-01-01'::DATE AS order_date,
        'COMPLETED' AS order_status,
        100.00 AS total_amount,
        'USD' AS currency,
        'CREDIT_CARD' AS payment_method,
        '123 Main St, New York, NY 10001' AS shipping_address,
        '123 Main St, New York, NY 10001' AS billing_address,
        5.00 AS discount_amount,
        8.00 AS tax_amount,
        10.00 AS shipping_cost,
        'WEBSITE' AS order_source
    
    UNION ALL
    
    SELECT 
        'ORD002' AS order_id,
        'CUST002' AS customer_id,
        '2024-01-02'::DATE AS order_date,
        'PENDING' AS order_status,
        75.00 AS total_amount,
        'USD' AS currency,
        'PAYPAL' AS payment_method,
        '456 Oak Ave, Los Angeles, CA 90210' AS shipping_address,
        '456 Oak Ave, Los Angeles, CA 90210' AS billing_address,
        0.00 AS discount_amount,
        6.00 AS tax_amount,
        8.00 AS shipping_cost,
        'MOBILE_APP' AS order_source
),

filtered_data AS (
    SELECT *
    FROM source_data
    WHERE order_id IS NOT NULL
),

deduped_orders AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id 
            ORDER BY order_date DESC NULLS LAST
        ) AS row_num
    FROM filtered_data
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
