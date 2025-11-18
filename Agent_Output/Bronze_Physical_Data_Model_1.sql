_____________________________________________
-- *Author*: AAVA
-- *Created on*: 
-- *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw Data Storage
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

/*
===============================================
BRONZE LAYER PHYSICAL DATA MODEL
Medallion Architecture - Raw Data Layer
===============================================

Purpose: Store raw data as-is from source systems with minimal transformation
Compatibility: Snowflake SQL
Layer: Bronze (Raw Data)

Key Principles:
1. Store data in its original format
2. Add metadata columns for lineage tracking
3. No primary keys, foreign keys, or constraints
4. Use Snowflake-compatible data types
5. Include audit capabilities

*/

-- =============================================
-- 1. BRONZE LAYER DDL SCRIPTS
-- =============================================

-- ---------------------------------------------
-- 1.1 Customer Data Table
-- ---------------------------------------------
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
    customer_type STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- ---------------------------------------------
-- 1.2 Product Data Table
-- ---------------------------------------------
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
    discontinued_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- ---------------------------------------------
-- 1.3 Orders Data Table
-- ---------------------------------------------
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
    order_source STRING,
    sales_rep_id NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- ---------------------------------------------
-- 1.4 Order Items Data Table
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
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

-- ---------------------------------------------
-- 1.5 Suppliers Data Table
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 1.6 Inventory Data Table
-- ---------------------------------------------
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
    total_value NUMBER(15,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'WAREHOUSE_MANAGEMENT'
);

-- ---------------------------------------------
-- 1.7 Sales Representatives Data Table
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 1.8 Financial Transactions Data Table
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_financial_transactions (
    transaction_id NUMBER,
    order_id NUMBER,
    customer_id NUMBER,
    transaction_type STRING,
    transaction_date TIMESTAMP_NTZ,
    amount NUMBER(15,2),
    currency_code STRING,
    payment_method STRING,
    payment_gateway STRING,
    transaction_status STRING,
    reference_number STRING,
    gateway_transaction_id STRING,
    processing_fee NUMBER(8,2),
    net_amount NUMBER(15,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PAYMENT_GATEWAY'
);

-- ---------------------------------------------
-- 1.9 Marketing Campaigns Data Table
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_marketing_campaigns (
    campaign_id NUMBER,
    campaign_name STRING,
    campaign_type STRING,
    start_date DATE,
    end_date DATE,
    budget NUMBER(12,2),
    target_audience STRING,
    channel STRING,
    campaign_status STRING,
    created_by STRING,
    created_date TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'MARKETING_AUTOMATION'
);

-- ---------------------------------------------
-- 1.10 Customer Interactions Data Table
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_customer_interactions (
    interaction_id NUMBER,
    customer_id NUMBER,
    interaction_type STRING,
    interaction_date TIMESTAMP_NTZ,
    channel STRING,
    subject STRING,
    description STRING,
    status STRING,
    priority STRING,
    assigned_to STRING,
    resolution_date TIMESTAMP_NTZ,
    satisfaction_score NUMBER(2,1),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- =============================================
-- 2. AUDIT TABLE
-- =============================================

-- ---------------------------------------------
-- 2.1 Bronze Layer Audit Table
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING NOT NULL,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    processed_by STRING DEFAULT USER(),
    processing_time NUMBER,
    status STRING,
    records_processed NUMBER,
    error_message STRING,
    batch_id STRING,
    source_file_name STRING,
    source_file_size NUMBER,
    checksum STRING
);

-- =============================================
-- 3. COMMENTS AND DOCUMENTATION
-- =============================================

-- Add table comments for documentation
COMMENT ON TABLE Bronze.bz_customers IS 'Raw customer data from CRM system - stores customer information as-is from source';
COMMENT ON TABLE Bronze.bz_products IS 'Raw product catalog data - stores product information with minimal transformation';
COMMENT ON TABLE Bronze.bz_orders IS 'Raw order data from order management system - includes all order header information';
COMMENT ON TABLE Bronze.bz_order_items IS 'Raw order line items data - detailed product information for each order';
COMMENT ON TABLE Bronze.bz_suppliers IS 'Raw supplier data from supplier management system';
COMMENT ON TABLE Bronze.bz_inventory IS 'Raw inventory data from warehouse management system';
COMMENT ON TABLE Bronze.bz_sales_reps IS 'Raw sales representative data from HR system';
COMMENT ON TABLE Bronze.bz_financial_transactions IS 'Raw financial transaction data from payment gateways';
COMMENT ON TABLE Bronze.bz_marketing_campaigns IS 'Raw marketing campaign data from marketing automation system';
COMMENT ON TABLE Bronze.bz_customer_interactions IS 'Raw customer interaction data from CRM system';
COMMENT ON TABLE Bronze.bz_audit_log IS 'Audit table for tracking data loading and processing activities in Bronze layer';

-- Add column comments for key metadata fields
COMMENT ON COLUMN Bronze.bz_customers.load_timestamp IS 'Timestamp when record was loaded into Bronze layer';
COMMENT ON COLUMN Bronze.bz_customers.update_timestamp IS 'Timestamp when record was last updated';
COMMENT ON COLUMN Bronze.bz_customers.source_system IS 'Source system identifier for data lineage';

-- =============================================
-- 4. BRONZE LAYER IMPLEMENTATION NOTES
-- =============================================

/*
IMPLEMENTATION GUIDELINES:

1. DATA LOADING:
   - Use COPY INTO statements for bulk loading from external stages
   - Implement error handling and logging for failed loads
   - Use file formats appropriate for source data (CSV, JSON, Parquet)

2. DATA TYPES:
   - All data types are Snowflake-compatible
   - STRING used for variable-length text (up to 16MB)
   - NUMBER used for numeric data with appropriate precision
   - TIMESTAMP_NTZ used for datetime without timezone
   - DATE used for date-only fields

3. METADATA COLUMNS:
   - load_timestamp: When data was first loaded
   - update_timestamp: When data was last modified
   - source_system: Identifies the originating system

4. NO CONSTRAINTS:
   - No primary keys, foreign keys, or check constraints
   - Data stored as-is from source systems
   - Data quality issues handled in Silver layer

5. NAMING CONVENTIONS:
   - All table names prefixed with 'bz_' for Bronze layer
   - Schema name: Bronze
   - Column names use snake_case convention

6. AUDIT CAPABILITIES:
   - Comprehensive audit table for tracking all operations
   - Includes processing metrics and error handling
   - Supports data lineage and compliance requirements

7. SCALABILITY:
   - Tables designed for high-volume data ingestion
   - Snowflake's micro-partitioning handles partitioning automatically
   - Consider clustering keys for very large tables

8. SECURITY:
   - Apply appropriate role-based access controls
   - Consider masking policies for sensitive data
   - Implement row-level security if required
*/

-- =============================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =============================================