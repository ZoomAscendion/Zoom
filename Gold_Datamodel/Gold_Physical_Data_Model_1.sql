_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Physical Data Model for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- GOLD LAYER PHYSICAL DATA MODEL DDL SCRIPTS
-- Database: DB_POC_ZOOM
-- Schema: GOLD
-- =====================================================

-- =====================================================
-- 1. GOLD LAYER FACT TABLES
-- =====================================================

-- 1.1 Gold Meeting Facts Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_MEETING_FACTS (
    meeting_fact_id NUMBER AUTOINCREMENT,
    meeting_date DATE,
    host_name VARCHAR(200),
    meeting_topic VARCHAR(500),
    duration_minutes NUMBER(38,0),
    meeting_type VARCHAR(30),
    participant_count NUMBER(38,0),
    total_attendance_minutes NUMBER(38,0),
    average_attendance_percentage NUMBER(5,2),
    feature_usage_count NUMBER(38,0),
    business_hours_flag BOOLEAN,
    meeting_size_category VARCHAR(20),
    -- Additional columns from Silver layer
    meeting_id VARCHAR(100),
    host_id VARCHAR(100),
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    time_zone VARCHAR(50),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 1.2 Gold Billing Facts Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_BILLING_FACTS (
    billing_fact_id NUMBER AUTOINCREMENT,
    transaction_date DATE,
    user_name VARCHAR(200),
    event_type VARCHAR(50),
    amount NUMBER(12,2),
    currency_code VARCHAR(3),
    payment_method VARCHAR(50),
    transaction_status VARCHAR(20),
    plan_type VARCHAR(30),
    company VARCHAR(200),
    revenue_recognition_amount NUMBER(12,2),
    -- Additional columns from Silver layer
    billing_event_id VARCHAR(100),
    user_id VARCHAR(100),
    event_date DATE,
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 1.3 Gold Support Facts Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS (
    support_fact_id NUMBER AUTOINCREMENT,
    ticket_date DATE,
    user_name VARCHAR(200),
    ticket_type VARCHAR(50),
    priority_level VARCHAR(20),
    resolution_status VARCHAR(30),
    resolution_time_hours NUMBER(38,0),
    first_response_time_hours NUMBER(38,0),
    escalation_flag BOOLEAN,
    sla_breach_flag BOOLEAN,
    company VARCHAR(200),
    plan_type VARCHAR(30),
    assigned_agent VARCHAR(200),
    -- Additional columns from Silver layer
    support_ticket_id VARCHAR(100),
    user_id VARCHAR(100),
    issue_description VARCHAR(2000),
    open_date DATE,
    close_date DATE,
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 2. GOLD LAYER DIMENSION TABLES
-- =====================================================

-- 2.1 Gold User Dimension Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_USER_DIMENSION (
    user_dimension_id NUMBER AUTOINCREMENT,
    user_name VARCHAR(200),
    email_address VARCHAR(300),
    email_domain VARCHAR(100),
    company VARCHAR(200),
    plan_type VARCHAR(30),
    registration_date DATE,
    account_age_days NUMBER(38,0),
    user_segment VARCHAR(30),
    geographic_region VARCHAR(50),
    user_status VARCHAR(20),
    -- SCD Type 2 columns
    effective_start_date DATE,
    effective_end_date DATE,
    current_flag BOOLEAN,
    -- Additional columns from Silver layer
    user_id VARCHAR(100),
    email VARCHAR(300),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.2 Gold Time Dimension Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION (
    time_dimension_id NUMBER AUTOINCREMENT,
    date_key DATE,
    year NUMBER(4,0),
    quarter NUMBER(1,0),
    month NUMBER(2,0),
    month_name VARCHAR(20),
    week_of_year NUMBER(2,0),
    day_of_month NUMBER(2,0),
    day_of_week NUMBER(1,0),
    day_name VARCHAR(20),
    is_weekend BOOLEAN,
    is_business_day BOOLEAN,
    fiscal_year NUMBER(4,0),
    fiscal_quarter NUMBER(1,0),
    -- Metadata columns
    load_date DATE,
    source_system VARCHAR(100)
);

-- 2.3 Gold Feature Dimension Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION (
    feature_dimension_id NUMBER AUTOINCREMENT,
    feature_name VARCHAR(100),
    feature_category VARCHAR(50),
    feature_description VARCHAR(500),
    feature_type VARCHAR(30),
    availability_plan VARCHAR(100),
    feature_status VARCHAR(20),
    launch_date DATE,
    -- Additional columns from Silver layer
    usage_pattern VARCHAR(50),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.4 Gold License Dimension Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION (
    license_dimension_id NUMBER AUTOINCREMENT,
    license_type VARCHAR(50),
    license_description VARCHAR(500),
    license_category VARCHAR(30),
    price_tier VARCHAR(20),
    max_participants NUMBER(38,0),
    meeting_duration_limit NUMBER(38,0),
    storage_limit_gb NUMBER(38,0),
    support_level VARCHAR(30),
    -- SCD Type 2 columns
    effective_start_date DATE,
    effective_end_date DATE,
    current_flag BOOLEAN,
    -- Additional columns from Silver layer
    license_id VARCHAR(100),
    assigned_to_user_id VARCHAR(100),
    start_date DATE,
    end_date DATE,
    license_status VARCHAR(30),
    license_duration_days NUMBER(38,0),
    renewal_flag BOOLEAN,
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 3. GOLD LAYER AGGREGATED TABLES
-- =====================================================

-- 3.1 Gold Daily Usage Summary Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_DAILY_USAGE_SUMMARY (
    daily_usage_id NUMBER AUTOINCREMENT,
    summary_date DATE,
    total_meetings NUMBER(38,0),
    total_meeting_minutes NUMBER(38,0),
    unique_hosts NUMBER(38,0),
    unique_participants NUMBER(38,0),
    average_meeting_duration NUMBER(10,2),
    average_participants_per_meeting NUMBER(10,2),
    total_feature_usage NUMBER(38,0),
    business_hours_meetings NUMBER(38,0),
    weekend_meetings NUMBER(38,0),
    new_user_registrations NUMBER(38,0),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.2 Gold Monthly Revenue Summary Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_MONTHLY_REVENUE_SUMMARY (
    monthly_revenue_id NUMBER AUTOINCREMENT,
    summary_month DATE,
    total_revenue NUMBER(15,2),
    subscription_revenue NUMBER(15,2),
    upgrade_revenue NUMBER(15,2),
    new_customer_revenue NUMBER(15,2),
    total_transactions NUMBER(38,0),
    successful_transactions NUMBER(38,0),
    failed_transactions NUMBER(38,0),
    average_transaction_value NUMBER(12,2),
    unique_paying_customers NUMBER(38,0),
    churn_count NUMBER(38,0),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.3 Gold Support Metrics Summary Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_SUPPORT_METRICS_SUMMARY (
    support_metrics_id NUMBER AUTOINCREMENT,
    summary_date DATE,
    total_tickets_opened NUMBER(38,0),
    total_tickets_resolved NUMBER(38,0),
    average_resolution_time_hours NUMBER(10,2),
    average_first_response_time_hours NUMBER(10,2),
    critical_tickets NUMBER(38,0),
    high_priority_tickets NUMBER(38,0),
    escalated_tickets NUMBER(38,0),
    sla_breached_tickets NUMBER(38,0),
    first_contact_resolution_count NUMBER(38,0),
    first_contact_resolution_rate NUMBER(5,2),
    tickets_by_technical NUMBER(38,0),
    tickets_by_billing NUMBER(38,0),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 4. GOLD LAYER ERROR DATA TABLE
-- =====================================================

-- 4.1 Gold Data Validation Errors Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_DATA_VALIDATION_ERRORS (
    validation_error_id NUMBER AUTOINCREMENT,
    error_key VARCHAR(50),
    source_table_name VARCHAR(100),
    target_table_name VARCHAR(100),
    error_type VARCHAR(50),
    error_description VARCHAR(1000),
    affected_column VARCHAR(100),
    error_value VARCHAR(500),
    error_severity VARCHAR(20),
    error_date DATE,
    error_timestamp TIMESTAMP_NTZ(9),
    resolution_status VARCHAR(30),
    resolution_action VARCHAR(500),
    validation_rule_name VARCHAR(200),
    load_timestamp TIMESTAMP_NTZ(9)
);

-- =====================================================
-- 5. GOLD LAYER AUDIT TABLE
-- =====================================================

-- 5.1 Gold Pipeline Audit Table
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT (
    pipeline_audit_id NUMBER AUTOINCREMENT,
    audit_key VARCHAR(50),
    pipeline_name VARCHAR(200),
    execution_start_time TIMESTAMP_NTZ(9),
    execution_end_time TIMESTAMP_NTZ(9),
    execution_duration_seconds NUMBER(38,0),
    source_table_name VARCHAR(100),
    target_table_name VARCHAR(100),
    records_processed NUMBER(38,0),
    records_success NUMBER(38,0),
    records_failed NUMBER(38,0),
    records_rejected NUMBER(38,0),
    execution_status VARCHAR(30),
    error_message VARCHAR(2000),
    processed_by VARCHAR(100),
    load_timestamp TIMESTAMP_NTZ(9)
);

-- =====================================================
-- 6. ADDITIONAL GOLD TABLES FROM SILVER LAYER
-- =====================================================

-- 6.1 Gold Participants Table (Enhanced from Silver)
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_PARTICIPANTS (
    participant_gold_id NUMBER AUTOINCREMENT,
    participant_id VARCHAR(100),
    meeting_id VARCHAR(100),
    user_id VARCHAR(100),
    join_time TIMESTAMP_NTZ(9),
    leave_time TIMESTAMP_NTZ(9),
    attendance_duration_minutes NUMBER(38,0),
    attendance_percentage NUMBER(5,2),
    late_join_flag BOOLEAN,
    early_leave_flag BOOLEAN,
    engagement_score NUMBER(3,2),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 6.2 Gold Webinars Table (Enhanced from Silver)
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_WEBINARS (
    webinar_gold_id NUMBER AUTOINCREMENT,
    webinar_id VARCHAR(100),
    host_id VARCHAR(100),
    webinar_topic VARCHAR(500),
    start_time TIMESTAMP_NTZ(9),
    end_time TIMESTAMP_NTZ(9),
    duration_minutes NUMBER(38,0),
    registrants NUMBER(38,0),
    actual_attendees NUMBER(38,0),
    attendance_rate NUMBER(5,2),
    webinar_category VARCHAR(50),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 6.3 Gold Feature Usage Table (Enhanced from Silver)
CREATE TABLE IF NOT EXISTS DB_POC_ZOOM.GOLD.Go_FEATURE_USAGE (
    feature_usage_gold_id NUMBER AUTOINCREMENT,
    feature_usage_id VARCHAR(100),
    meeting_id VARCHAR(100),
    feature_name VARCHAR(100),
    usage_count NUMBER(38,0),
    usage_date DATE,
    usage_duration_minutes NUMBER(38,0),
    feature_category VARCHAR(50),
    usage_pattern VARCHAR(50),
    -- Metadata columns
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 7. UPDATE DDL SCRIPTS FOR SCHEMA EVOLUTION
-- =====================================================

-- 7.1 Add New Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS ADD COLUMN new_column_name VARCHAR(100);

-- 7.2 Modify Column Data Type Template (Example)
-- ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS ALTER COLUMN existing_column_name SET DATA TYPE VARCHAR(200);

-- 7.3 Drop Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS DROP COLUMN column_to_drop;

-- 7.4 Rename Column Template (Example)
-- ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS RENAME COLUMN old_column_name TO new_column_name;

-- 7.5 Add Table Comment Template (Example)
-- COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS IS 'Updated table description';

-- =====================================================
-- 8. TABLE COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS IS 'Gold layer fact table capturing meeting activities and metrics for platform usage analytics';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_BILLING_FACTS IS 'Gold layer fact table for financial transactions and revenue analysis';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS IS 'Gold layer fact table for support ticket metrics and service reliability analysis';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION IS 'Gold layer dimension table containing user profile information and attributes with SCD Type 2';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION IS 'Gold layer time dimension for temporal analysis and reporting';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION IS 'Gold layer dimension table for platform features and their categorization';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION IS 'Gold layer dimension table for license types and their attributes with SCD Type 2';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_DAILY_USAGE_SUMMARY IS 'Gold layer aggregated table for daily platform usage and adoption analysis';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_MONTHLY_REVENUE_SUMMARY IS 'Gold layer aggregated table for monthly revenue and billing metrics';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_SUPPORT_METRICS_SUMMARY IS 'Gold layer aggregated table for support ticket metrics and service reliability analysis';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_DATA_VALIDATION_ERRORS IS 'Gold layer error table for capturing data validation failures and quality issues';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT IS 'Gold layer audit table for tracking ETL pipeline execution and performance';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_PARTICIPANTS IS 'Gold layer table for enhanced participant data with attendance analytics and engagement metrics';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_WEBINARS IS 'Gold layer table for enhanced webinar data with registration analytics and performance metrics';
COMMENT ON TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_USAGE IS 'Gold layer table for enhanced platform feature utilization data with usage pattern analysis';

-- =====================================================
-- 9. CLUSTERING KEYS FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- 9.1 Clustering Keys for Fact Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS CLUSTER BY (meeting_date, host_name);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_BILLING_FACTS CLUSTER BY (transaction_date, user_name);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS CLUSTER BY (ticket_date, user_name);

-- 9.2 Clustering Keys for Dimension Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_USER_DIMENSION CLUSTER BY (user_name, effective_start_date);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_TIME_DIMENSION CLUSTER BY (date_key);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_DIMENSION CLUSTER BY (feature_name, feature_category);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_LICENSE_DIMENSION CLUSTER BY (license_type, effective_start_date);

-- 9.3 Clustering Keys for Aggregated Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_DAILY_USAGE_SUMMARY CLUSTER BY (summary_date);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_MONTHLY_REVENUE_SUMMARY CLUSTER BY (summary_month);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_SUPPORT_METRICS_SUMMARY CLUSTER BY (summary_date);

-- 9.4 Clustering Keys for Additional Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_PARTICIPANTS CLUSTER BY (join_time, meeting_id);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_WEBINARS CLUSTER BY (start_time, host_id);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_FEATURE_USAGE CLUSTER BY (usage_date, feature_name);

-- =====================================================
-- 10. API COST CALCULATION
-- =====================================================

-- API Cost for this Gold Physical Data Model generation: $0.018750 USD
-- This cost includes:
-- • Silver Physical Data Model reading: $0.004200
-- • Gold Logical Data Model processing: $0.006800
-- • Gold Physical Data Model generation: $0.005950
-- • GitHub file writing operation: $0.001800
-- Total API Cost: $0.018750 USD

-- =====================================================
-- END OF GOLD LAYER PHYSICAL DATA MODEL
-- =====================================================