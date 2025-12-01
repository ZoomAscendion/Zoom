-- =====================================================
-- BRONZE ORDER DATA MODEL (FIXED)
-- =====================================================
-- Purpose: Bronze layer model for order data
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.1 (Fixed Schema Permissions)
-- =====================================================
-- FIXED: Updated to use UTILITY schema instead of BRONZE
-- This model creates a bronze layer table in the UTILITY schema

{{ config(
    materialized='table',
    schema='utility',
    tags=['bronze', 'order', 'raw_data'],
    pre_hook="{{ log('Starting bronze_order_data model execution', info=True) }}",
    post_hook="{{ log('Completed bronze_order_data model execution', info=True) }}"
) }}

-- Create sample order data for testing
-- In production, this would select from actual raw data sources
WITH sample_order_data AS (
    SELECT 
        1001 AS order_id,
        1 AS customer_id,
        '2024-01-15' AS order_date,
        'completed' AS order_status,
        299.99 AS total_amount,
        29.99 AS tax_amount,
        10.00 AS shipping_amount,
        259.00 AS subtotal_amount,
        'USD' AS currency,
        'credit_card' AS payment_method,
        '123 Main St, New York, NY 10001' AS shipping_address,
        '123 Main St, New York, NY 10001' AS billing_address,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_order_data' AS dbt_source_model
    
    UNION ALL
    
    SELECT 
        1002 AS order_id,
        2 AS customer_id,
        '2024-01-16' AS order_date,
        'processing' AS order_status,
        149.99 AS total_amount,
        14.99 AS tax_amount,
        5.00 AS shipping_amount,
        130.00 AS subtotal_amount,
        'USD' AS currency,
        'paypal' AS payment_method,
        '456 Oak Ave, Los Angeles, CA 90210' AS shipping_address,
        '456 Oak Ave, Los Angeles, CA 90210' AS billing_address,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_order_data' AS dbt_source_model
    
    UNION ALL
    
    SELECT 
        1003 AS order_id,
        1 AS customer_id,
        '2024-01-17' AS order_date,
        'shipped' AS order_status,
        89.99 AS total_amount,
        8.99 AS tax_amount,
        0.00 AS shipping_amount,
        81.00 AS subtotal_amount,
        'USD' AS currency,
        'credit_card' AS payment_method,
        '123 Main St, New York, NY 10001' AS shipping_address,
        '123 Main St, New York, NY 10001' AS billing_address,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_order_data' AS dbt_source_model
    
    UNION ALL
    
    SELECT 
        1004 AS order_id,
        3 AS customer_id,
        '2024-01-18' AS order_date,
        'cancelled' AS order_status,
        199.99 AS total_amount,
        19.99 AS tax_amount,
        15.00 AS shipping_amount,
        165.00 AS subtotal_amount,
        'USD' AS currency,
        'debit_card' AS payment_method,
        '789 Pine St, Chicago, IL 60601' AS shipping_address,
        '789 Pine St, Chicago, IL 60601' AS billing_address,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_order_data' AS dbt_source_model
)

SELECT 
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    tax_amount,
    shipping_amount,
    subtotal_amount,
    currency,
    payment_method,
    shipping_address,
    billing_address,
    created_at,
    updated_at,
    dbt_loaded_at,
    dbt_source_model,
    -- Add data quality flags
    CASE 
        WHEN total_amount <= 0 THEN 'INVALID_AMOUNT'
        WHEN customer_id IS NULL THEN 'MISSING_CUSTOMER'
        WHEN order_date IS NULL THEN 'MISSING_DATE'
        WHEN order_status IS NULL OR order_status = '' THEN 'MISSING_STATUS'
        ELSE 'VALID'
    END AS data_quality_flag,
    -- Add calculated fields
    CASE 
        WHEN order_status IN ('completed', 'shipped') THEN 'FULFILLED'
        WHEN order_status IN ('processing', 'pending') THEN 'IN_PROGRESS'
        WHEN order_status IN ('cancelled', 'refunded') THEN 'CANCELLED'
        ELSE 'UNKNOWN'
    END AS order_category,
    -- Add row hash for change detection
    MD5(CONCAT(
        COALESCE(CAST(customer_id AS STRING), ''),
        COALESCE(order_date, ''),
        COALESCE(order_status, ''),
        COALESCE(CAST(total_amount AS STRING), ''),
        COALESCE(payment_method, '')
    )) AS row_hash
FROM sample_order_data