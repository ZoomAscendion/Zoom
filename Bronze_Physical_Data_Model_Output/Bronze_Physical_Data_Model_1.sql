_____________________________________________
-- *Author*: AAVA
-- *Created on*:   
-- *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw data storage with metadata tracking
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Medallion Architecture - Bronze Layer (Raw Data)
-- Compatible with Snowflake SQL
-- =====================================================

-- 1. CREATE BRONZE SCHEMA
CREATE SCHEMA IF NOT EXISTS Bronze;

-- 2. BRONZE LAYER TABLES - RAW DATA STORAGE

-- 2.1 Bronze Customer Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customers (
    customer_id NUMBER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    date_of_birth DATE,
    registration_date DATE,
    customer_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- 2.2 Bronze Product Table
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
    created_date DATE,
    discontinued_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_SYSTEM'
);

-- 2.3 Bronze Orders Table
CREATE TABLE IF NOT EXISTS Bronze.bz_orders (
    order_id NUMBER,
    customer_id NUMBER,
    order_date DATE,
    order_time TIMESTAMP_NTZ,
    order_status STRING,
    payment_method STRING,
    payment_status STRING,
    shipping_method STRING,
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
    subtotal_amount NUMBER(12,2),
    tax_amount NUMBER(10,2),
    shipping_amount NUMBER(8,2),
    discount_amount NUMBER(8,2),
    total_amount NUMBER(12,2),
    currency_code STRING,
    order_source STRING,
    sales_rep_id NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_SYSTEM'
);

-- 2.4 Bronze Order Items Table
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    discount_percentage NUMBER(5,2),
    discount_amount NUMBER(8,2),
    line_total NUMBER(10,2),
    product_name STRING,
    product_sku STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_SYSTEM'
);

-- 2.5 Bronze Suppliers Table
CREATE TABLE IF NOT EXISTS Bronze.bz_suppliers (
    supplier_id NUMBER,
    supplier_name STRING,
    contact_person STRING,
    email STRING,
    phone STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    supplier_type STRING,
    payment_terms STRING,
    credit_limit NUMBER(12,2),
    supplier_status STRING,
    contract_start_date DATE,
    contract_end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SUPPLIER_SYSTEM'
);

-- 2.6 Bronze Inventory Table
CREATE TABLE IF NOT EXISTS Bronze.bz_inventory (
    inventory_id NUMBER,
    product_id NUMBER,
    warehouse_id NUMBER,
    warehouse_name STRING,
    location_code STRING,
    quantity_on_hand NUMBER,
    quantity_reserved NUMBER,
    quantity_available NUMBER,
    reorder_point NUMBER,
    max_stock_level NUMBER,
    last_stock_count_date DATE,
    unit_cost NUMBER(10,2),
    total_value NUMBER(12,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'INVENTORY_SYSTEM'
);

-- 2.7 Bronze Sales Representatives Table
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
    sales_target NUMBER(12,2),
    employee_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- 2.8 Bronze Payments Table
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id NUMBER,
    order_id NUMBER,
    payment_date DATE,
    payment_time TIMESTAMP_NTZ,
    payment_method STRING,
    payment_amount NUMBER(12,2),
    currency_code STRING,
    payment_status STRING,
    transaction_id STRING,
    gateway_response STRING,
    card_last_four STRING,
    card_type STRING,
    processing_fee NUMBER(8,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_SYSTEM'
);

-- 2.9 Bronze Shipments Table
CREATE TABLE IF NOT EXISTS Bronze.bz_shipments (
    shipment_id NUMBER,
    order_id NUMBER,
    tracking_number STRING,
    carrier STRING,
    shipping_method STRING,
    ship_date DATE,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipment_status STRING,
    shipping_cost NUMBER(8,2),
    weight NUMBER(8,3),
    dimensions STRING,
    delivery_signature STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SHIPPING_SYSTEM'
);

-- 2.10 Bronze Returns Table
CREATE TABLE IF NOT EXISTS Bronze.bz_returns (
    return_id NUMBER,
    order_id NUMBER,
    order_item_id NUMBER,
    customer_id NUMBER,
    return_date DATE,
    return_reason STRING,
    return_status STRING,
    quantity_returned NUMBER,
    refund_amount NUMBER(10,2),
    restocking_fee NUMBER(8,2),
    condition_received STRING,
    processed_by STRING,
    processed_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'RETURN_SYSTEM'
);

-- 3. AUDIT TABLE FOR BRONZE LAYER
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    processed_by STRING,
    processing_time NUMBER,
    status STRING,
    error_message STRING,
    records_processed NUMBER,
    records_failed NUMBER
);

-- 4. BRONZE LAYER DATA QUALITY TRACKING TABLE
CREATE TABLE IF NOT EXISTS Bronze.bz_data_quality_log (
    quality_check_id NUMBER AUTOINCREMENT,
    table_name STRING,
    check_type STRING,
    check_description STRING,
    check_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    records_checked NUMBER,
    records_passed NUMBER,
    records_failed NUMBER,
    quality_score NUMBER(5,2),
    status STRING
);

-- 5. BRONZE LAYER SOURCE SYSTEM MAPPING TABLE
CREATE TABLE IF NOT EXISTS Bronze.bz_source_system_mapping (
    mapping_id NUMBER AUTOINCREMENT,
    source_system STRING,
    source_table STRING,
    target_table STRING,
    field_mapping STRING,
    transformation_rules STRING,
    active_flag BOOLEAN DEFAULT TRUE,
    created_date DATE DEFAULT CURRENT_DATE(),
    updated_date DATE DEFAULT CURRENT_DATE()
);

-- =====================================================
-- BRONZE LAYER COMMENTS AND DOCUMENTATION
-- =====================================================

-- Table Comments
COMMENT ON TABLE Bronze.bz_customers IS 'Bronze layer raw customer data from CRM system';
COMMENT ON TABLE Bronze.bz_products IS 'Bronze layer raw product catalog data';
COMMENT ON TABLE Bronze.bz_orders IS 'Bronze layer raw order transaction data';
COMMENT ON TABLE Bronze.bz_order_items IS 'Bronze layer raw order line item data';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Bronze layer raw supplier master data';
COMMENT ON TABLE Bronze.bz_inventory IS 'Bronze layer raw inventory position data';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Bronze layer raw sales representative data';
COMMENT ON TABLE Bronze.bz_payments IS 'Bronze layer raw payment transaction data';
COMMENT ON TABLE Bronze.bz_shipments IS 'Bronze layer raw shipment tracking data';
COMMENT ON TABLE Bronze.bz_returns IS 'Bronze layer raw return transaction data';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit trail for Bronze layer data processing';
COMMENT ON TABLE Bronze.bz_data_quality_log IS 'Data quality monitoring for Bronze layer';
COMMENT ON TABLE Bronze.bz_source_system_mapping IS 'Source to target mapping configuration';

-- =====================================================
-- BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
1. All tables use Snowflake-compatible data types (STRING, NUMBER, DATE, TIMESTAMP_NTZ, BOOLEAN)
2. No primary keys, foreign keys, or constraints as per Bronze layer requirements
3. All table names prefixed with 'bz_' for Bronze layer identification
4. Metadata columns (load_timestamp, update_timestamp, source_system) added to all tables
5. Audit table with AUTOINCREMENT for tracking data processing
6. Tables designed to store raw data as-is from source systems
7. CREATE TABLE IF NOT EXISTS syntax used for safe deployment
8. Default values set for metadata columns where appropriate
9. Comments added for documentation and maintenance
10. Data quality and source mapping tables included for operational support

Snowflake Features Utilized:
- Micro-partitioned storage (default)
- AUTOINCREMENT for surrogate keys
- TIMESTAMP_NTZ for timezone-neutral timestamps
- Default values for automatic metadata population
- Schema-qualified table names (Bronze.table_name)
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================