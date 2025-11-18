{{ config(
    materialized='table',
    unique_key='customer_id'
) }}

{% if this.name != 'audit_log' %}
    {% set audit_start %}
        INSERT INTO {{ ref('audit_log') }} (
            record_id, source_table, process_start_time, process_status, created_at
        ) 
        SELECT 
            COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1,
            'customers',
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
            'customers',
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
        'CUST001' AS customer_id,
        'John' AS first_name,
        'Doe' AS last_name,
        'john.doe@email.com' AS email,
        '555-1234' AS phone,
        '123 Main St' AS address,
        'New York' AS city,
        'NY' AS state,
        '10001' AS zip_code,
        'USA' AS country,
        '2023-01-01'::DATE AS registration_date,
        '2024-01-01'::TIMESTAMP AS last_login_date,
        TRUE AS is_active,
        'PREMIUM' AS customer_segment
    
    UNION ALL
    
    SELECT 
        'CUST002' AS customer_id,
        'Jane' AS first_name,
        'Smith' AS last_name,
        'jane.smith@email.com' AS email,
        '555-5678' AS phone,
        '456 Oak Ave' AS address,
        'Los Angeles' AS city,
        'CA' AS state,
        '90210' AS zip_code,
        'USA' AS country,
        '2023-02-01'::DATE AS registration_date,
        '2024-01-15'::TIMESTAMP AS last_login_date,
        TRUE AS is_active,
        'STANDARD' AS customer_segment
),

filtered_data AS (
    SELECT *
    FROM source_data
    WHERE customer_id IS NOT NULL
),

deduped_customers AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY last_login_date DESC NULLS LAST, registration_date DESC NULLS LAST
        ) AS row_num
    FROM filtered_data
),

final_customers AS (
    SELECT 
        customer_id,
        TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        LOWER(TRIM(email)) AS email,
        TRIM(phone) AS phone,
        TRIM(address) AS address,
        TRIM(city) AS city,
        TRIM(state) AS state,
        TRIM(zip_code) AS zip_code,
        TRIM(country) AS country,
        registration_date,
        last_login_date,
        COALESCE(is_active, FALSE) AS is_active,
        COALESCE(customer_segment, 'UNKNOWN') AS customer_segment,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'ACTIVE' AS process_status
    FROM deduped_customers
    WHERE row_num = 1
)

SELECT * FROM final_customers
