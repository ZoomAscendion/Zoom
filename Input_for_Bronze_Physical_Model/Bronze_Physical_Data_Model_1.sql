_____________________________________________
-- *Author*: AAVA
-- *Created on*: 
-- *Description*: Bronze Layer Physical Data Model for Medallion Architecture - Raw data storage with metadata tracking
-- *Version*: 1 
-- *Updated on*: 
_____________________________________________

-- =============================================
-- BRONZE LAYER PHYSICAL DATA MODEL
-- =============================================
-- This script creates the Bronze layer tables for the Medallion architecture
-- Bronze layer stores raw data as-is with minimal transformation
-- Compatible with Snowflake SQL standards
-- =============================================

-- 1. AUDIT TABLE
-- =============================================
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

-- 2. CUSTOMER DATA TABLE
-- =============================================
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
    customer_type STRING,
    credit_limit NUMBER(15,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- 3. PRODUCT DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_products (
    product_id NUMBER,
    product_name STRING,
    product_description STRING,
    category_id NUMBER,
    category_name STRING,
    brand STRING,
    model STRING,
    sku STRING,
    unit_price NUMBER(15,2),
    cost_price NUMBER(15,2),
    weight NUMBER(10,3),
    dimensions STRING,
    color STRING,
    size STRING,
    inventory_status STRING,
    created_date DATE,
    discontinued_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'PRODUCT_CATALOG'
);

-- 4. ORDERS DATA TABLE
-- =============================================
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
    subtotal NUMBER(15,2),
    tax_amount NUMBER(15,2),
    shipping_cost NUMBER(15,2),
    discount_amount NUMBER(15,2),
    total_amount NUMBER(15,2),
    currency_code STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 5. ORDER ITEMS DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_order_items (
    order_item_id NUMBER,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(15,2),
    line_total NUMBER(15,2),
    discount_percent NUMBER(5,2),
    discount_amount NUMBER(15,2),
    tax_amount NUMBER(15,2),
    product_name STRING,
    product_sku STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'ORDER_MANAGEMENT'
);

-- 6. INVENTORY DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_inventory (
    inventory_id NUMBER,
    product_id NUMBER,
    warehouse_id NUMBER,
    warehouse_name STRING,
    warehouse_location STRING,
    quantity_on_hand NUMBER,
    quantity_reserved NUMBER,
    quantity_available NUMBER,
    reorder_point NUMBER,
    reorder_quantity NUMBER,
    last_restock_date DATE,
    last_count_date DATE,
    unit_cost NUMBER(15,2),
    inventory_value NUMBER(15,2),
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'INVENTORY_SYSTEM'
);

-- 7. SUPPLIERS DATA TABLE
-- =============================================
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
    credit_rating STRING,
    active_status BOOLEAN,
    contract_start_date DATE,
    contract_end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SUPPLIER_MANAGEMENT'
);

-- 8. EMPLOYEES DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_employees (
    employee_id NUMBER,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    hire_date DATE,
    job_title STRING,
    department STRING,
    manager_id NUMBER,
    salary NUMBER(15,2),
    employment_status STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING,
    date_of_birth DATE,
    emergency_contact_name STRING,
    emergency_contact_phone STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'HR_SYSTEM'
);

-- 9. SALES TRANSACTIONS DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_sales_transactions (
    transaction_id NUMBER,
    order_id NUMBER,
    customer_id NUMBER,
    employee_id NUMBER,
    transaction_date DATE,
    transaction_time TIMESTAMP_NTZ,
    transaction_type STRING,
    payment_method STRING,
    amount NUMBER(15,2),
    currency_code STRING,
    exchange_rate NUMBER(10,6),
    reference_number STRING,
    notes STRING,
    processed_by STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'SALES_SYSTEM'
);

-- 10. MARKETING CAMPAIGNS DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_marketing_campaigns (
    campaign_id NUMBER,
    campaign_name STRING,
    campaign_type STRING,
    channel STRING,
    start_date DATE,
    end_date DATE,
    budget NUMBER(15,2),
    target_audience STRING,
    campaign_status STRING,
    created_by STRING,
    created_date DATE,
    description STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'MARKETING_SYSTEM'
);

-- 11. CUSTOMER INTERACTIONS DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_customer_interactions (
    interaction_id NUMBER,
    customer_id NUMBER,
    employee_id NUMBER,
    interaction_date DATE,
    interaction_time TIMESTAMP_NTZ,
    interaction_type STRING,
    channel STRING,
    subject STRING,
    description STRING,
    resolution STRING,
    status STRING,
    priority STRING,
    duration_minutes NUMBER,
    follow_up_required BOOLEAN,
    follow_up_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'CRM_SYSTEM'
);

-- 12. FINANCIAL TRANSACTIONS DATA TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS Bronze.bz_financial_transactions (
    transaction_id NUMBER,
    account_id NUMBER,
    transaction_date DATE,
    transaction_time TIMESTAMP_NTZ,
    transaction_type STRING,
    debit_amount NUMBER(15,2),
    credit_amount NUMBER(15,2),
    balance NUMBER(15,2),
    currency_code STRING,
    description STRING,
    reference_number STRING,
    processed_by STRING,
    approval_status STRING,
    approved_by STRING,
    approval_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    update_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_system STRING DEFAULT 'FINANCIAL_SYSTEM'
);

-- =============================================
-- BRONZE LAYER COMMENTS AND DOCUMENTATION
-- =============================================

-- Table Naming Convention: All Bronze layer tables use 'bz_' prefix
-- Data Types: Using Snowflake-compatible data types (STRING, NUMBER, TIMESTAMP_NTZ, DATE, BOOLEAN)
-- No Constraints: Following Bronze layer principles - no primary keys, foreign keys, or constraints
-- Metadata Columns: Each table includes load_timestamp, update_timestamp, and source_system for tracking
-- Audit Table: Centralized logging for all Bronze layer operations
-- Storage: Using Snowflake's default micro-partitioned storage format
-- Schema: All tables created in Bronze schema

-- =============================================
-- END OF BRONZE LAYER PHYSICAL DATA MODEL
-- =============================================