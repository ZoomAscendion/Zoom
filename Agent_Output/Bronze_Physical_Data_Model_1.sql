_____________________________________________
-- *Author*: AAVA
-- *Created on*: 
-- *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw data storage with metadata tracking
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================
-- Purpose: Store raw data as-is from source systems
-- Architecture: Medallion Bronze Layer
-- Platform: Snowflake
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
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    date_of_birth DATE,
    registration_date TIMESTAMP_NTZ,
    customer_status STRING,
    customer_type STRING,
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
    model STRING,
    sku STRING,
    unit_price NUMBER(10,2),
    cost_price NUMBER(10,2),
    weight NUMBER(8,3),
    dimensions STRING,
    color STRING,
    size STRING,
    inventory_quantity NUMBER,
    reorder_level NUMBER,
    supplier_id NUMBER,
    product_status STRING,
    created_date TIMESTAMP_NTZ,
    discontinued_date TIMESTAMP_NTZ,
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
    order_date TIMESTAMP_NTZ,
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
    discount_amount NUMBER(10,2),
    total_amount NUMBER(12,2),
    currency_code STRING,
    order_source STRING,
    sales_rep_id NUMBER,
    created_by STRING,
    modified_by STRING,
    created_date TIMESTAMP_NTZ,
    modified_date TIMESTAMP_NTZ,
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
    discount_percentage NUMBER(5,2),
    discount_amount NUMBER(8,2),
    line_total NUMBER(10,2),
    tax_amount NUMBER(8,2),
    product_name STRING,
    product_sku STRING,
    product_category STRING,
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
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    supplier_type STRING,
    payment_terms STRING,
    credit_limit NUMBER(12,2),
    tax_id STRING,
    bank_account STRING,
    supplier_status STRING,
    contract_start_date DATE,
    contract_end_date DATE,
    created_date TIMESTAMP_NTZ,
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
    last_stock_count NUMBER,
    last_count_date TIMESTAMP_NTZ,
    unit_cost NUMBER(10,2),
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
    department STRING,
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

-- -----------------------------------------------------
-- 1.8 Payments Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id NUMBER,
    order_id NUMBER,
    customer_id NUMBER,
    payment_method STRING,
    payment_type STRING,
    payment_amount NUMBER(12,2),
    currency_code STRING,
    payment_date TIMESTAMP_NTZ,
    payment_status STRING,
    transaction_id STRING,
    gateway_response STRING,
    authorization_code STRING,
    card_last_four STRING,
    card_type STRING,
    billing_address STRING,
    processing_fee NUMBER(8,2),
    refund_amount NUMBER(10,2),
    refund_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_GATEWAY'
);

-- -----------------------------------------------------
-- 1.9 Shipping Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_shipping (
    shipping_id NUMBER,
    order_id NUMBER,
    tracking_number STRING,
    carrier STRING,
    shipping_method STRING,
    shipping_cost NUMBER(8,2),
    weight NUMBER(8,3),
    dimensions STRING,
    ship_date TIMESTAMP_NTZ,
    estimated_delivery_date TIMESTAMP_NTZ,
    actual_delivery_date TIMESTAMP_NTZ,
    shipping_status STRING,
    origin_address STRING,
    destination_address STRING,
    signature_required BOOLEAN,
    insurance_value NUMBER(10,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SHIPPING_SYSTEM'
);

-- -----------------------------------------------------
-- 1.10 Customer Interactions Data Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_customer_interactions (
    interaction_id NUMBER,
    customer_id NUMBER,
    interaction_type STRING,
    interaction_channel STRING,
    interaction_date TIMESTAMP_NTZ,
    subject STRING,
    description STRING,
    priority STRING,
    status STRING,
    assigned_to STRING,
    resolution STRING,
    resolution_date TIMESTAMP_NTZ,
    satisfaction_rating NUMBER,
    follow_up_required BOOLEAN,
    follow_up_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
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
    records_failed NUMBER,
    error_message STRING,
    batch_id STRING,
    source_file_name STRING,
    source_file_size NUMBER,
    checksum STRING
);

-- =====================================================
-- 3. COMMENTS AND DOCUMENTATION
-- =====================================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_customers IS 'Raw customer data from CRM system - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_products IS 'Raw product catalog data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_orders IS 'Raw order transaction data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_order_items IS 'Raw order line item details - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Raw supplier master data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_inventory IS 'Raw inventory levels and stock data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Raw sales representative data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_payments IS 'Raw payment transaction data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_shipping IS 'Raw shipping and delivery data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_customer_interactions IS 'Raw customer service interaction data - Bronze layer storage';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit trail for Bronze layer data processing activities';

-- =====================================================
-- 4. BRONZE LAYER IMPLEMENTATION NOTES
-- =====================================================

/*
BRONZE LAYER DESIGN PRINCIPLES:

1. **Raw Data Storage**: Tables store data exactly as received from source systems
2. **No Transformations**: Minimal to no data transformations applied
3. **Metadata Tracking**: All tables include load_timestamp, update_timestamp, and source_system
4. **Snowflake Compatibility**: Uses Snowflake-native data types and features
5. **No Constraints**: No primary keys, foreign keys, or check constraints implemented
6. **Audit Trail**: Comprehensive audit logging for data lineage and troubleshooting
7. **Scalable Design**: Leverages Snowflake's micro-partitioned storage
8. **Table Naming**: All Bronze tables prefixed with 'bz_' for clear identification

DATA TYPES USED:
- NUMBER: For all numeric data (integers and decimals)
- STRING: For variable-length text data
- TIMESTAMP_NTZ: For date/time data without timezone
- DATE: For date-only data
- BOOLEAN: For true/false values

METADATA COLUMNS:
- load_timestamp: When the record was first loaded
- update_timestamp: When the record was last updated
- source_system: Identifies the originating system

NEXT STEPS:
1. Implement data ingestion pipelines using COPY INTO commands
2. Set up streams for change data capture
3. Create tasks for automated data loading
4. Implement data quality checks before promoting to Silver layer
5. Set up monitoring and alerting for data pipeline failures
*/

-- =====================================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =====================================================