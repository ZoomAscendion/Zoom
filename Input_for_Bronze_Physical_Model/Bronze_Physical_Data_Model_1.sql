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

-- =====================================================
-- 1. BRONZE LAYER DDL SCRIPTS
-- =====================================================

-- -----------------------------------------------------
-- 1.1 Customer Data Table
-- -----------------------------------------------------
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
    registration_date DATE,
    customer_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- -----------------------------------------------------
-- 1.2 Product Data Table
-- -----------------------------------------------------
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
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- -----------------------------------------------------
-- 1.3 Orders Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_orders (
    order_id NUMBER,
    customer_id NUMBER,
    order_date DATE,
    order_time TIMESTAMP_NTZ,
    order_status STRING,
    payment_method STRING,
    payment_status STRING,
    shipping_address STRING,
    shipping_city STRING,
    shipping_state STRING,
    shipping_zip STRING,
    shipping_country STRING,
    shipping_method STRING,
    shipping_cost NUMBER(8,2),
    tax_amount NUMBER(8,2),
    discount_amount NUMBER(8,2),
    total_amount NUMBER(10,2),
    currency_code STRING,
    sales_rep_id NUMBER,
    order_source STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- -----------------------------------------------------
-- 1.4 Order Items Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    discount_percent NUMBER(5,2),
    discount_amount NUMBER(8,2),
    line_total NUMBER(10,2),
    product_name STRING,
    product_sku STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- -----------------------------------------------------
-- 1.5 Suppliers Data Table
-- -----------------------------------------------------
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
    credit_limit NUMBER(12,2),
    tax_id STRING,
    bank_account STRING,
    supplier_status STRING,
    contract_start_date DATE,
    contract_end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SUPPLIER_MANAGEMENT'
);

-- -----------------------------------------------------
-- 1.6 Inventory Data Table
-- -----------------------------------------------------
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
    last_restock_date DATE,
    last_count_date DATE,
    unit_cost NUMBER(10,4),
    total_value NUMBER(12,2),
    inventory_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'INVENTORY_MANAGEMENT'
);

-- -----------------------------------------------------
-- 1.7 Sales Representatives Data Table
-- -----------------------------------------------------
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
    department STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- -----------------------------------------------------
-- 1.8 Categories Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_categories (
    category_id NUMBER,
    category_name STRING,
    parent_category_id NUMBER,
    category_description STRING,
    category_level NUMBER,
    category_path STRING,
    is_active BOOLEAN,
    display_order NUMBER,
    created_date DATE,
    modified_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- -----------------------------------------------------
-- 1.9 Payments Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id NUMBER,
    order_id NUMBER,
    payment_date DATE,
    payment_time TIMESTAMP_NTZ,
    payment_method STRING,
    payment_provider STRING,
    transaction_id STRING,
    payment_amount NUMBER(10,2),
    currency_code STRING,
    payment_status STRING,
    authorization_code STRING,
    reference_number STRING,
    processing_fee NUMBER(8,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_GATEWAY'
);

-- -----------------------------------------------------
-- 1.10 Shipments Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_shipments (
    shipment_id NUMBER,
    order_id NUMBER,
    tracking_number STRING,
    carrier STRING,
    shipping_method STRING,
    ship_date DATE,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost NUMBER(8,2),
    weight NUMBER(8,3),
    dimensions STRING,
    shipment_status STRING,
    delivery_signature STRING,
    delivery_notes STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SHIPPING_SYSTEM'
);

-- =====================================================
-- 2. AUDIT TABLE
-- =====================================================

-- -----------------------------------------------------
-- 2.1 Bronze Layer Audit Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    processed_by STRING,
    processing_time NUMBER,
    status STRING,
    records_processed NUMBER,
    error_message STRING,
    batch_id STRING,
    file_name STRING,
    file_size NUMBER,
    checksum STRING
);

-- =====================================================
-- 3. BRONZE LAYER COMMENTS AND DOCUMENTATION
-- =====================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_customers IS 'Bronze layer table storing raw customer data from CRM system';
COMMENT ON TABLE Bronze.bz_products IS 'Bronze layer table storing raw product catalog data';
COMMENT ON TABLE Bronze.bz_orders IS 'Bronze layer table storing raw order transaction data';
COMMENT ON TABLE Bronze.bz_order_items IS 'Bronze layer table storing raw order line item details';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Bronze layer table storing raw supplier information';
COMMENT ON TABLE Bronze.bz_inventory IS 'Bronze layer table storing raw inventory levels and stock data';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Bronze layer table storing raw sales representative information';
COMMENT ON TABLE Bronze.bz_categories IS 'Bronze layer table storing raw product category hierarchy';
COMMENT ON TABLE Bronze.bz_payments IS 'Bronze layer table storing raw payment transaction data';
COMMENT ON TABLE Bronze.bz_shipments IS 'Bronze layer table storing raw shipment and delivery data';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit table tracking all data loading activities in Bronze layer';

-- =====================================================
-- 4. BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
IMPLEMENTATION NOTES:

1. DATA TYPES:
   - All tables use Snowflake-compatible data types
   - STRING type used for variable-length text fields
   - NUMBER type used for numeric fields with appropriate precision
   - TIMESTAMP_NTZ used for timestamp fields without timezone
   - DATE type used for date-only fields
   - BOOLEAN type used for true/false flags

2. BRONZE LAYER PRINCIPLES:
   - Tables store raw data as-is from source systems
   - No primary keys, foreign keys, or constraints defined
   - All tables include metadata columns for tracking
   - Table names prefixed with 'bz_' for Bronze layer identification
   - Schema name 'Bronze' used for all tables

3. METADATA COLUMNS:
   - load_timestamp: When the record was first loaded
   - update_timestamp: When the record was last updated
   - source_system: Identifies the originating system

4. AUDIT CAPABILITIES:
   - Comprehensive audit table tracks all loading activities
   - AUTOINCREMENT used for audit record IDs
   - Processing metrics and error tracking included

5. SNOWFLAKE OPTIMIZATIONS:
   - Uses Snowflake's default micro-partitioned storage
   - Compatible with Snowflake's automatic compression
   - Designed for efficient bulk loading via COPY INTO commands
   - No clustering keys defined at Bronze layer (raw data)

6. SCALABILITY CONSIDERATIONS:
   - Tables designed to handle large volumes of raw data
   - Metadata tracking enables data lineage and auditing
   - Structure supports incremental loading patterns
   - Compatible with Snowflake's elastic scaling capabilities

7. DATA LOADING RECOMMENDATIONS:
   - Use COPY INTO commands for bulk data loading
   - Implement error handling and logging
   - Consider using Snowflake Streams for change data capture
   - Leverage Snowflake Tasks for automated processing

8. MAINTENANCE:
   - Regular monitoring of audit logs recommended
   - Periodic cleanup of old audit records may be needed
   - Monitor table sizes and query performance
   - Consider implementing data retention policies
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================