_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw data ingestion layer with metadata tracking
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- Medallion Architecture - Raw Data Layer
-- Compatible with Snowflake SQL
-- =====================================================

-- 1. CREATE BRONZE SCHEMA
CREATE SCHEMA IF NOT EXISTS Bronze;

-- =====================================================
-- 2. BRONZE LAYER DATA TABLES
-- =====================================================

-- 2.1 Customer Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customers (
    customer_id INTEGER,
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

-- 2.2 Product Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_products (
    product_id INTEGER,
    product_name STRING,
    product_description STRING,
    category_id INTEGER,
    category_name STRING,
    brand STRING,
    unit_price NUMBER(10,2),
    cost_price NUMBER(10,2),
    weight NUMBER(8,3),
    dimensions STRING,
    color STRING,
    size STRING,
    stock_quantity INTEGER,
    reorder_level INTEGER,
    supplier_id INTEGER,
    product_status STRING,
    created_date DATE,
    discontinued_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- 2.3 Orders Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_orders (
    order_id INTEGER,
    customer_id INTEGER,
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
    billing_address STRING,
    billing_city STRING,
    billing_state STRING,
    billing_zip STRING,
    billing_country STRING,
    subtotal NUMBER(12,2),
    tax_amount NUMBER(10,2),
    shipping_cost NUMBER(8,2),
    discount_amount NUMBER(10,2),
    total_amount NUMBER(12,2),
    currency_code STRING,
    sales_rep_id INTEGER,
    order_source STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 2.4 Order Items Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id INTEGER,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price NUMBER(10,2),
    discount_percent NUMBER(5,2),
    discount_amount NUMBER(10,2),
    line_total NUMBER(12,2),
    product_name STRING,
    product_sku STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 2.5 Suppliers Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_suppliers (
    supplier_id INTEGER,
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
    inventory_id INTEGER,
    product_id INTEGER,
    warehouse_id INTEGER,
    warehouse_name STRING,
    location STRING,
    quantity_on_hand INTEGER,
    quantity_reserved INTEGER,
    quantity_available INTEGER,
    reorder_point INTEGER,
    max_stock_level INTEGER,
    last_restock_date DATE,
    last_count_date DATE,
    unit_cost NUMBER(10,2),
    total_value NUMBER(15,2),
    inventory_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'INVENTORY_MANAGEMENT'
);

-- 2.7 Sales Representatives Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_sales_reps (
    sales_rep_id INTEGER,
    employee_id INTEGER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    hire_date DATE,
    department STRING,
    territory STRING,
    manager_id INTEGER,
    commission_rate NUMBER(5,4),
    sales_target NUMBER(15,2),
    employee_status STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- 2.8 Payments Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_payments (
    payment_id INTEGER,
    order_id INTEGER,
    customer_id INTEGER,
    payment_date DATE,
    payment_time TIMESTAMP_NTZ,
    payment_method STRING,
    payment_provider STRING,
    transaction_id STRING,
    payment_amount NUMBER(12,2),
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

-- 2.9 Shipping Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_shipping (
    shipping_id INTEGER,
    order_id INTEGER,
    tracking_number STRING,
    carrier STRING,
    shipping_method STRING,
    ship_date DATE,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost NUMBER(8,2),
    weight NUMBER(8,3),
    dimensions STRING,
    shipping_status STRING,
    delivery_address STRING,
    delivery_city STRING,
    delivery_state STRING,
    delivery_zip STRING,
    delivery_country STRING,
    signature_required BOOLEAN,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SHIPPING_SYSTEM'
);

-- 2.10 Customer Interactions Data Table
CREATE TABLE IF NOT EXISTS Bronze.bz_customer_interactions (
    interaction_id INTEGER,
    customer_id INTEGER,
    interaction_date DATE,
    interaction_time TIMESTAMP_NTZ,
    interaction_type STRING,
    channel STRING,
    subject STRING,
    description STRING,
    agent_id INTEGER,
    resolution_status STRING,
    priority_level STRING,
    category STRING,
    subcategory STRING,
    resolution_time INTEGER,
    satisfaction_score INTEGER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- =====================================================
-- 3. AUDIT TABLE
-- =====================================================

-- 3.1 Bronze Layer Audit Table
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    processed_by STRING,
    processing_time NUMBER,
    status STRING,
    records_processed INTEGER,
    records_failed INTEGER,
    error_message STRING,
    batch_id STRING,
    file_name STRING,
    file_size NUMBER,
    checksum STRING
);

-- =====================================================
-- 4. COMMENTS ON TABLES
-- =====================================================

COMMENT ON TABLE Bronze.bz_customers IS 'Raw customer data from CRM system - Bronze layer';
COMMENT ON TABLE Bronze.bz_products IS 'Raw product catalog data - Bronze layer';
COMMENT ON TABLE Bronze.bz_orders IS 'Raw order transaction data - Bronze layer';
COMMENT ON TABLE Bronze.bz_order_items IS 'Raw order line item details - Bronze layer';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Raw supplier information - Bronze layer';
COMMENT ON TABLE Bronze.bz_inventory IS 'Raw inventory data from warehouse systems - Bronze layer';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Raw sales representative data from HR system - Bronze layer';
COMMENT ON TABLE Bronze.bz_payments IS 'Raw payment transaction data - Bronze layer';
COMMENT ON TABLE Bronze.bz_shipping IS 'Raw shipping and delivery data - Bronze layer';
COMMENT ON TABLE Bronze.bz_customer_interactions IS 'Raw customer service interaction data - Bronze layer';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit trail for Bronze layer data processing';

-- =====================================================
-- 5. BRONZE LAYER DESIGN PRINCIPLES FOLLOWED:
-- =====================================================
-- • Raw data stored as-is without transformation
-- • All tables prefixed with 'bz_' for Bronze layer identification
-- • Metadata columns added for data lineage tracking
-- • Snowflake-compatible data types used (STRING, NUMBER, TIMESTAMP_NTZ, etc.)
-- • No primary keys, foreign keys, or constraints as per Bronze layer best practices
-- • CREATE TABLE IF NOT EXISTS syntax for idempotent execution
-- • Audit table for tracking data processing activities
-- • Comments added for documentation
-- • Default values set for metadata columns
-- • Appropriate data types chosen based on expected data ranges
-- =====================================================