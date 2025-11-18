{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT 
        'PROD001' AS product_id,
        'Laptop Computer' AS product_name,
        'Electronics' AS category,
        'Computers' AS subcategory,
        'TechBrand' AS brand,
        999.99 AS price,
        600.00 AS cost,
        'High-performance laptop for business use' AS description,
        2.5 AS weight,
        '14x10x1 inches' AS dimensions,
        'Silver' AS color,
        '14-inch' AS size,
        TRUE AS is_active,
        '2023-01-01'::DATE AS created_date,
        '2024-01-01'::DATE AS last_updated_date
    
    UNION ALL
    
    SELECT 
        'PROD002' AS product_id,
        'Wireless Mouse' AS product_name,
        'Electronics' AS category,
        'Accessories' AS subcategory,
        'TechBrand' AS brand,
        29.99 AS price,
        15.00 AS cost,
        'Ergonomic wireless mouse with long battery life' AS description,
        0.2 AS weight,
        '4x2x1 inches' AS dimensions,
        'Black' AS color,
        'Standard' AS size,
        TRUE AS is_active,
        '2023-02-01'::DATE AS created_date,
        '2024-01-15'::DATE AS last_updated_date
),

filtered_data AS (
    SELECT *
    FROM source_data
    WHERE product_id IS NOT NULL
),

deduped_products AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY last_updated_date DESC NULLS LAST, created_date DESC NULLS LAST
        ) AS row_num
    FROM filtered_data
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
