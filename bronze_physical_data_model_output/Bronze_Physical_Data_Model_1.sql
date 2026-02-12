_____________________________________________
-- *Author*: AAVA
-- *Created on*: 2025-12-02
-- *Description*: Bronze layer Physical Data Model for Medallion architecture on Snowflake
-- *Version*: 1
-- *Updated on*: 2025-12-02
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Medallion Architecture - Raw Data Storage Layer
-- Compatible with Snowflake SQL
-- =====================================================

-- Create Bronze Schema if not exists
CREATE SCHEMA IF NOT EXISTS Bronze;

-- =====================================================
-- 1. AUDIT TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING,
    -- Metadata columns
    load_timestamp_meta TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'BRONZE_LAYER'
);

-- =====================================================
-- 2. CUSTOMER DATA TABLES
-- =====================================================

-- Customer Master Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customers (
    customer_id NUMBER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    date_of_birth DATE,
    gender STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    customer_status STRING,
    registration_date DATE,
    last_login_date TIMESTAMP_NTZ,
    preferred_language STRING,
    marketing_consent BOOLEAN,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- Customer Preferences Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customer_preferences (
    preference_id NUMBER,
    customer_id NUMBER,
    preference_type STRING,
    preference_value STRING,
    is_active BOOLEAN,
    created_date DATE,
    modified_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- =====================================================
-- 3. PRODUCT DATA TABLES
-- =====================================================

-- Product Master Table
CREATE TABLE IF NOT EXISTS Bronze.bz_products (
    product_id NUMBER,
    product_name STRING,
    product_description STRING,
    category_id NUMBER,
    category_name STRING,
    subcategory_id NUMBER,
    subcategory_name STRING,
    brand STRING,
    manufacturer STRING,
    unit_price NUMBER(10,2),
    cost_price NUMBER(10,2),
    currency_code STRING,
    weight NUMBER(8,3),
    dimensions STRING,
    color STRING,
    size STRING,
    sku STRING,
    barcode STRING,
    product_status STRING,
    launch_date DATE,
    discontinue_date DATE,
    warranty_period NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_SYSTEM'
);

-- Product Inventory Table
CREATE TABLE IF NOT EXISTS Bronze.bz_product_inventory (
    inventory_id NUMBER,
    product_id NUMBER,
    warehouse_id NUMBER,
    warehouse_name STRING,
    location STRING,
    quantity_on_hand NUMBER,
    quantity_reserved NUMBER,
    quantity_available NUMBER,
    reorder_level NUMBER,
    max_stock_level NUMBER,
    last_stock_update TIMESTAMP_NTZ,
    inventory_value NUMBER(12,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'INVENTORY_SYSTEM'
);

-- =====================================================
-- 4. ORDER DATA TABLES
-- =====================================================

-- Orders Header Table
CREATE TABLE IF NOT EXISTS Bronze.bz_orders (
    order_id NUMBER,
    customer_id NUMBER,
    order_number STRING,
    order_date DATE,
    order_time TIMESTAMP_NTZ,
    order_status STRING,
    order_type STRING,
    channel STRING,
    sales_rep_id NUMBER,
    sales_rep_name STRING,
    subtotal_amount NUMBER(12,2),
    tax_amount NUMBER(10,2),
    shipping_amount NUMBER(10,2),
    discount_amount NUMBER(10,2),
    total_amount NUMBER(12,2),
    currency_code STRING,
    payment_method STRING,
    payment_status STRING,
    shipping_address_line1 STRING,
    shipping_address_line2 STRING,
    shipping_city STRING,
    shipping_state STRING,
    shipping_postal_code STRING,
    shipping_country STRING,
    billing_address_line1 STRING,
    billing_address_line2 STRING,
    billing_city STRING,
    billing_state STRING,
    billing_postal_code STRING,
    billing_country STRING,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_SYSTEM'
);

-- Order Line Items Table
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    product_name STRING,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    line_total NUMBER(12,2),
    discount_percent NUMBER(5,2),
    discount_amount NUMBER(10,2),
    tax_amount NUMBER(10,2),
    item_status STRING,
    shipped_quantity NUMBER,
    returned_quantity NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_SYSTEM'
);

-- =====================================================
-- 5. FINANCIAL DATA TABLES
-- =====================================================

-- Payments Table
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id NUMBER,
    order_id NUMBER,
    customer_id NUMBER,
    payment_method STRING,
    payment_type STRING,
    payment_date DATE,
    payment_time TIMESTAMP_NTZ,
    payment_amount NUMBER(12,2),
    currency_code STRING,
    payment_status STRING,
    transaction_id STRING,
    gateway_response STRING,
    authorization_code STRING,
    card_last_four STRING,
    card_type STRING,
    processing_fee NUMBER(8,2),
    refund_amount NUMBER(12,2),
    refund_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_SYSTEM'
);

-- Refunds Table
CREATE TABLE IF NOT EXISTS Bronze.bz_refunds (
    refund_id NUMBER,
    order_id NUMBER,
    payment_id NUMBER,
    customer_id NUMBER,
    refund_amount NUMBER(12,2),
    refund_reason STRING,
    refund_date DATE,
    refund_status STRING,
    refund_method STRING,
    processed_by STRING,
    approval_required BOOLEAN,
    approved_by STRING,
    approval_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'REFUND_SYSTEM'
);

-- =====================================================
-- 6. EMPLOYEE DATA TABLES
-- =====================================================

-- Employees Table
CREATE TABLE IF NOT EXISTS Bronze.bz_employees (
    employee_id NUMBER,
    employee_number STRING,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    hire_date DATE,
    termination_date DATE,
    job_title STRING,
    department STRING,
    manager_id NUMBER,
    manager_name STRING,
    salary NUMBER(10,2),
    commission_rate NUMBER(5,4),
    employment_status STRING,
    employment_type STRING,
    location STRING,
    office_address STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- =====================================================
-- 7. MARKETING DATA TABLES
-- =====================================================

-- Campaigns Table
CREATE TABLE IF NOT EXISTS Bronze.bz_marketing_campaigns (
    campaign_id NUMBER,
    campaign_name STRING,
    campaign_type STRING,
    channel STRING,
    start_date DATE,
    end_date DATE,
    budget_amount NUMBER(12,2),
    actual_spend NUMBER(12,2),
    target_audience STRING,
    campaign_status STRING,
    created_by STRING,
    created_date DATE,
    modified_by STRING,
    modified_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'MARKETING_SYSTEM'
);

-- Campaign Performance Table
CREATE TABLE IF NOT EXISTS Bronze.bz_campaign_performance (
    performance_id NUMBER,
    campaign_id NUMBER,
    date_key DATE,
    impressions NUMBER,
    clicks NUMBER,
    conversions NUMBER,
    cost_per_click NUMBER(8,4),
    cost_per_conversion NUMBER(10,2),
    revenue_generated NUMBER(12,2),
    return_on_ad_spend NUMBER(8,4),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'MARKETING_SYSTEM'
);

-- =====================================================
-- 8. WEB ANALYTICS DATA TABLES
-- =====================================================

-- Website Sessions Table
CREATE TABLE IF NOT EXISTS Bronze.bz_web_sessions (
    session_id STRING,
    customer_id NUMBER,
    visitor_id STRING,
    session_start_time TIMESTAMP_NTZ,
    session_end_time TIMESTAMP_NTZ,
    session_duration NUMBER,
    page_views NUMBER,
    bounce_rate NUMBER(5,4),
    traffic_source STRING,
    referrer_url STRING,
    landing_page STRING,
    exit_page STRING,
    device_type STRING,
    browser STRING,
    operating_system STRING,
    ip_address STRING,
    location_country STRING,
    location_city STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'WEB_ANALYTICS'
);

-- Page Views Table
CREATE TABLE IF NOT EXISTS Bronze.bz_page_views (
    page_view_id STRING,
    session_id STRING,
    customer_id NUMBER,
    page_url STRING,
    page_title STRING,
    page_category STRING,
    view_timestamp TIMESTAMP_NTZ,
    time_on_page NUMBER,
    scroll_depth NUMBER(5,2),
    exit_page BOOLEAN,
    conversion_event BOOLEAN,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'WEB_ANALYTICS'
);

-- =====================================================
-- 9. SOCIAL MEDIA DATA TABLES
-- =====================================================

-- Social Media Posts Table
CREATE TABLE IF NOT EXISTS Bronze.bz_social_media_posts (
    post_id STRING,
    platform STRING,
    account_name STRING,
    post_content STRING,
    post_type STRING,
    post_date DATE,
    post_time TIMESTAMP_NTZ,
    author STRING,
    hashtags STRING,
    mentions STRING,
    likes_count NUMBER,
    shares_count NUMBER,
    comments_count NUMBER,
    reach NUMBER,
    impressions NUMBER,
    engagement_rate NUMBER(5,4),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SOCIAL_MEDIA_API'
);

-- =====================================================
-- 10. EXTERNAL DATA TABLES
-- =====================================================

-- Weather Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_weather_data (
    weather_id NUMBER,
    location STRING,
    date_key DATE,
    temperature_high NUMBER(5,2),
    temperature_low NUMBER(5,2),
    humidity NUMBER(5,2),
    precipitation NUMBER(6,3),
    wind_speed NUMBER(5,2),
    weather_condition STRING,
    visibility NUMBER(5,2),
    uv_index NUMBER(3,1),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'WEATHER_API'
);

-- Economic Indicators Table
CREATE TABLE IF NOT EXISTS Bronze.bz_economic_indicators (
    indicator_id NUMBER,
    indicator_name STRING,
    indicator_value NUMBER(15,6),
    indicator_unit STRING,
    country STRING,
    region STRING,
    date_key DATE,
    data_source STRING,
    frequency STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ECONOMIC_DATA_API'
);

-- =====================================================
-- 11. LOG AND ERROR TABLES
-- =====================================================

-- Data Quality Issues Table
CREATE TABLE IF NOT EXISTS Bronze.bz_data_quality_issues (
    issue_id NUMBER AUTOINCREMENT,
    source_table STRING,
    source_column STRING,
    issue_type STRING,
    issue_description STRING,
    record_identifier STRING,
    issue_severity STRING,
    detected_timestamp TIMESTAMP_NTZ,
    resolved_timestamp TIMESTAMP_NTZ,
    resolution_notes STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'DATA_QUALITY_MONITOR'
);

-- ETL Process Log Table
CREATE TABLE IF NOT EXISTS Bronze.bz_etl_process_log (
    log_id NUMBER AUTOINCREMENT,
    process_name STRING,
    process_type STRING,
    start_timestamp TIMESTAMP_NTZ,
    end_timestamp TIMESTAMP_NTZ,
    duration_seconds NUMBER,
    records_processed NUMBER,
    records_inserted NUMBER,
    records_updated NUMBER,
    records_failed NUMBER,
    process_status STRING,
    error_message STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ETL_FRAMEWORK'
);

-- =====================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. Raw Data Storage: Tables store data as-is from source systems
2. No Data Transformation: Minimal to no data cleansing or transformation
3. Schema-on-Read: Flexible schema to accommodate source system changes
4. Audit Trail: Complete lineage and audit information
5. Metadata Enrichment: Standard metadata columns for tracking
6. Snowflake Optimization: Designed for Snowflake's micro-partitioned storage

TABLE NAMING CONVENTION:
- Prefix: 'bz_' indicates Bronze layer
- Schema: 'Bronze' for all Bronze layer objects
- Names: Descriptive and consistent with source systems

DATA TYPES:
- STRING: Variable length text data (Snowflake optimized)
- NUMBER: Numeric data with appropriate precision and scale
- TIMESTAMP_NTZ: Timestamp without timezone (recommended for Bronze)
- DATE: Date-only values
- BOOLEAN: True/false values

METADATA COLUMNS (Standard across all tables):
- load_timestamp: When record was loaded into Bronze
- update_timestamp: When record was last updated
- source_system: Originating system identifier

AUDIT AND MONITORING:
- bz_audit_log: Central audit table for all Bronze operations
- bz_data_quality_issues: Data quality monitoring
- bz_etl_process_log: ETL process tracking

SNOWFLAKE SPECIFIC FEATURES:
- CREATE TABLE IF NOT EXISTS: Idempotent table creation
- AUTOINCREMENT: Snowflake's auto-incrementing sequence
- Default values for metadata columns
- Optimized for Snowflake's columnar storage

NOTE: This Bronze layer design follows Medallion architecture principles
and is optimized for Snowflake's cloud data warehouse capabilities.
No primary keys, foreign keys, or constraints are defined as per
Bronze layer best practices for maximum flexibility.
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================