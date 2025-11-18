{{ config(
    materialized='table',
    unique_key='customer_id',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (record_id, source_table, process_start_time, process_status, created_at) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1, 'customers', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), process_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE source_table = 'customers' AND process_status = 'STARTED' AND '{{ this.name }}' != 'audit_log'"
) }}

WITH raw_customers AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        address,
        city,
        state,
        zip_code,
        country,
        registration_date,
        last_login_date,
        is_active,
        customer_segment
    FROM {{ source('raw_schema', 'customers') }}
    WHERE customer_id IS NOT NULL  -- Filter out NULL primary keys
),

deduped_customers AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY last_login_date DESC NULLS LAST, registration_date DESC NULLS LAST
        ) AS row_num
    FROM raw_customers
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
