{{ config(
    materialized='table',
    unique_key='product_id',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (record_id, source_table, process_start_time, process_status, created_at) SELECT COALESCE((SELECT MAX(record_id) FROM {{ ref('audit_log') }}), 0) + 1, 'products', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), process_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE source_table = 'products' AND process_status = 'STARTED' AND '{{ this.name }}' != 'audit_log'"
) }}

WITH raw_products AS (
    SELECT 
        product_id,
        product_name,
        category,
        subcategory,
        brand,
        price,
        cost,
        description,
        weight,
        dimensions,
        color,
        size,
        is_active,
        created_date,
        last_updated_date
    FROM {{ source('raw_schema', 'products') }}
    WHERE product_id IS NOT NULL  -- Filter out NULL primary keys
),

deduped_products AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY last_updated_date DESC NULLS LAST, created_date DESC NULLS LAST
        ) AS row_num
    FROM raw_products
),

final_products AS (
    SELECT 
        product_id,
        TRIM(product_name) AS product_name,
        TRIM(category) AS category,
        TRIM(subcategory) AS subcategory,
        TRIM(brand) AS brand,
        COALESCE(price, 0) AS price,
        COALESCE(cost, 0) AS cost,
        TRIM(description) AS description,
        weight,
        TRIM(dimensions) AS dimensions,
        TRIM(color) AS color,
        TRIM(size) AS size,
        COALESCE(is_active, TRUE) AS is_active,
        created_date,
        last_updated_date,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'ACTIVE' AS process_status
    FROM deduped_products
    WHERE row_num = 1
)

SELECT * FROM final_products
