-- =====================================================
-- BRONZE CUSTOMER DATA MODEL (FIXED)
-- =====================================================
-- Purpose: Bronze layer model for customer data
-- Author: AAVA
-- Created: 2024-11-11
-- Version: 1.1 (Fixed Schema Permissions)
-- =====================================================
-- FIXED: Updated to use UTILITY schema instead of BRONZE
-- This model creates a bronze layer table in the UTILITY schema

{{ config(
    materialized='table',
    schema='utility',
    tags=['bronze', 'customer', 'raw_data'],
    pre_hook="{{ log('Starting bronze_customer_data model execution', info=True) }}",
    post_hook="{{ log('Completed bronze_customer_data model execution', info=True) }}"
) }}

-- Create sample customer data for testing
-- In production, this would select from actual raw data sources
WITH sample_customer_data AS (
    SELECT 
        1 AS customer_id,
        'John Doe' AS customer_name,
        'john.doe@email.com' AS email,
        '123-456-7890' AS phone,
        '123 Main St' AS address,
        'New York' AS city,
        'NY' AS state,
        '10001' AS zip_code,
        'USA' AS country,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'active' AS status,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_customer_data' AS dbt_source_model
    
    UNION ALL
    
    SELECT 
        2 AS customer_id,
        'Jane Smith' AS customer_name,
        'jane.smith@email.com' AS email,
        '987-654-3210' AS phone,
        '456 Oak Ave' AS address,
        'Los Angeles' AS city,
        'CA' AS state,
        '90210' AS zip_code,
        'USA' AS country,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'active' AS status,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_customer_data' AS dbt_source_model
    
    UNION ALL
    
    SELECT 
        3 AS customer_id,
        'Bob Johnson' AS customer_name,
        'bob.johnson@email.com' AS email,
        '555-123-4567' AS phone,
        '789 Pine St' AS address,
        'Chicago' AS city,
        'IL' AS state,
        '60601' AS zip_code,
        'USA' AS country,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'inactive' AS status,
        CURRENT_TIMESTAMP() AS dbt_loaded_at,
        'bronze_customer_data' AS dbt_source_model
)

SELECT 
    customer_id,
    customer_name,
    email,
    phone,
    address,
    city,
    state,
    zip_code,
    country,
    created_at,
    updated_at,
    status,
    dbt_loaded_at,
    dbt_source_model,
    -- Add data quality flags
    CASE 
        WHEN email IS NULL OR email = '' THEN 'MISSING_EMAIL'
        WHEN phone IS NULL OR phone = '' THEN 'MISSING_PHONE'
        WHEN address IS NULL OR address = '' THEN 'MISSING_ADDRESS'
        ELSE 'VALID'
    END AS data_quality_flag,
    -- Add row hash for change detection
    MD5(CONCAT(
        COALESCE(customer_name, ''),
        COALESCE(email, ''),
        COALESCE(phone, ''),
        COALESCE(address, ''),
        COALESCE(status, '')
    )) AS row_hash
FROM sample_customer_data