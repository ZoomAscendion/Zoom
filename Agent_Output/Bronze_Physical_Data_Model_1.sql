_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw data storage with metadata tracking
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Medallion Architecture - Raw Data Storage Layer
-- Compatible with Snowflake SQL
-- =====================================================

-- 1. CREATE BRONZE SCHEMA
CREATE SCHEMA IF NOT EXISTS Bronze;

-- =====================================================
-- 2. BRONZE LAYER TABLES - RAW DATA STORAGE
-- =====================================================

-- 2.1 Customer Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customers (
    customer_id NUMBER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    address STRING,
    city STRING,
    state STRING,
    zip_code STRING,
    country STRING,
    date_of_birth DATE,
    registration_date TIMESTAMP_NTZ,
    customer_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- 2.2 Product Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_products (
    product_id NUMBER,
    product_name STRING,
    product_description STRING,
    category_id NUMBER,
    category_name STRING,
    brand STRING,
    unit_price NUMBER(10,2),
    cost_price NUMBER(10,2),
    weight NUMBER(8,3),
    dimensions STRING,
    color STRING,
    size STRING,
    stock_quantity NUMBER,
    reorder_level NUMBER,
    supplier_id NUMBER,
    product_status STRING,
    created_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- 2.3 Orders Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_orders (
    order_id NUMBER,
    customer_id NUMBER,
    order_date TIMESTAMP_NTZ,
    order_status STRING,
    payment_method STRING,
    payment_status STRING,
    shipping_address STRING,
    shipping_city STRING,
    shipping_state STRING,
    shipping_zip STRING,
    shipping_country STRING,
    order_total NUMBER(12,2),
    tax_amount NUMBER(10,2),
    shipping_cost NUMBER(8,2),
    discount_amount NUMBER(10,2),
    currency_code STRING,
    sales_rep_id NUMBER,
    order_source STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 2.4 Order Items Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    line_total NUMBER(12,2),
    discount_percent NUMBER(5,2),
    discount_amount NUMBER(10,2),
    tax_rate NUMBER(5,4),
    tax_amount NUMBER(10,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 2.5 Suppliers Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_suppliers (
    supplier_id NUMBER,
    supplier_name STRING,
    contact_person STRING,
    email STRING,
    phone STRING,
    address STRING,
    city STRING,
    state STRING,
    zip_code STRING,
    country STRING,
    supplier_type STRING,
    payment_terms STRING,
    credit_limit NUMBER(15,2),
    supplier_status STRING,
    contract_start_date DATE,
    contract_end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SUPPLIER_MANAGEMENT'
);

-- 2.6 Inventory Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_inventory (
    inventory_id NUMBER,
    product_id NUMBER,
    warehouse_id NUMBER,
    warehouse_name STRING,
    location STRING,
    quantity_on_hand NUMBER,
    quantity_reserved NUMBER,
    quantity_available NUMBER,
    reorder_point NUMBER,
    max_stock_level NUMBER,
    last_stock_count_date DATE,
    unit_cost NUMBER(10,2),
    total_value NUMBER(15,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'WAREHOUSE_MANAGEMENT'
);

-- 2.7 Sales Representatives Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_sales_reps (
    sales_rep_id NUMBER,
    employee_id NUMBER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    hire_date DATE,
    territory STRING,
    manager_id NUMBER,
    commission_rate NUMBER(5,4),
    sales_target NUMBER(15,2),
    employee_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- 2.8 Categories Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_categories (
    category_id NUMBER,
    category_name STRING,
    parent_category_id NUMBER,
    category_description STRING,
    category_level NUMBER,
    is_active BOOLEAN,
    created_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- 2.9 Payments Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id NUMBER,
    order_id NUMBER,
    payment_date TIMESTAMP_NTZ,
    payment_method STRING,
    payment_amount NUMBER(12,2),
    currency_code STRING,
    payment_status STRING,
    transaction_id STRING,
    gateway_response STRING,
    gateway_transaction_id STRING,
    refund_amount NUMBER(12,2),
    refund_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_GATEWAY'
);

-- 2.10 Shipments Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_shipments (
    shipment_id NUMBER,
    order_id NUMBER,
    carrier STRING,
    tracking_number STRING,
    ship_date TIMESTAMP_NTZ,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost NUMBER(8,2),
    weight NUMBER(8,3),
    shipment_status STRING,
    delivery_confirmation STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SHIPPING_SYSTEM'
);

-- =====================================================
-- 3. AUDIT TABLE FOR BRONZE LAYER
-- =====================================================

CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    processed_by STRING,
    processing_time NUMBER,
    status STRING,
    records_processed NUMBER,
    error_message STRING,
    batch_id STRING
);

-- =====================================================
-- 4. BRONZE LAYER COMMENTS AND DOCUMENTATION
-- =====================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_customers IS 'Raw customer data from CRM system - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_products IS 'Raw product catalog data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_orders IS 'Raw order transaction data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_order_items IS 'Raw order line item details - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Raw supplier information - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_inventory IS 'Raw inventory data from warehouse systems - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Raw sales representative data from HR system - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_categories IS 'Raw product category hierarchy - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_payments IS 'Raw payment transaction data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_shipments IS 'Raw shipment and delivery data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit trail for Bronze layer data processing activities';

-- =====================================================
-- 5. BRONZE LAYER FEATURES SUMMARY
-- =====================================================

/*
BRONZE LAYER CHARACTERISTICS:

1. **Raw Data Storage**: Tables store data as-is from source systems
2. **No Constraints**: No primary keys, foreign keys, or check constraints
3. **Snowflake Compatibility**: Uses Snowflake-native data types
4. **Metadata Tracking**: All tables include load_timestamp, update_timestamp, source_system
5. **Audit Trail**: Comprehensive audit table for tracking data processing
6. **Naming Convention**: All tables prefixed with 'bz_' for Bronze layer identification
7. **Schema Organization**: All tables organized under Bronze schema
8. **Data Types**: Optimized for Snowflake (STRING, NUMBER, TIMESTAMP_NTZ, BOOLEAN)
9. **Scalability**: Designed for high-volume data ingestion
10. **Source System Tracking**: Each table tracks its originating system

DATA FLOW:
Source Systems → Bronze Layer (Raw) → Silver Layer (Cleaned) → Gold Layer (Aggregated)

USAGE:
- Data ingestion from multiple source systems
- Historical data preservation
- Data lineage tracking
- Foundation for Silver layer transformations
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================