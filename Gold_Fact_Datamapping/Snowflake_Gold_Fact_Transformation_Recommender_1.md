_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive transformation rules for Fact tables in the Gold layer of Zoom Platform Analytics System
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Snowflake Gold Fact Transformation Recommender

## Overview

This document provides comprehensive transformation rules specifically for Fact tables in the Gold layer of the Zoom Platform Analytics System. These transformations ensure that key metrics, calculated fields, and relationships are structured correctly, enriched with necessary data points, and aligned with downstream reporting and performance optimization needs.

## Transformation Rules for Fact Tables

### 1. Go_MEETING_FACTS Transformation Rules

#### 1.1 Data Source Integration and Enrichment

**Rationale:** Meeting facts require integration of data from multiple Silver layer tables (Si_MEETINGS, Si_PARTICIPANTS, Si_FEATURE_USAGE, Si_USERS) to create comprehensive meeting analytics with enriched business context.

**SQL Example:**
```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_MEETING_FACTS (
    meeting_date,
    host_name,
    meeting_topic,
    duration_minutes,
    meeting_type,
    participant_count,
    total_attendance_minutes,
    average_attendance_percentage,
    feature_usage_count,
    business_hours_flag,
    meeting_size_category,
    meeting_id,
    host_id,
    start_time,
    end_time,
    time_zone,
    load_date,
    update_date,
    source_system
)
SELECT 
    DATE(m.start_time) as meeting_date,
    u.user_name as host_name,
    m.meeting_topic,
    m.duration_minutes,
    m.meeting_type,
    COALESCE(p.participant_count, 0) as participant_count,
    COALESCE(p.total_attendance_minutes, 0) as total_attendance_minutes,
    CASE 
        WHEN m.duration_minutes > 0 AND p.total_attendance_minutes > 0 
        THEN ROUND((p.total_attendance_minutes::FLOAT / (m.duration_minutes * p.participant_count)) * 100, 2)
        ELSE 0 
    END as average_attendance_percentage,
    COALESCE(f.feature_usage_count, 0) as feature_usage_count,
    m.business_hours_flag,
    m.meeting_size_category,
    m.meeting_id,
    m.host_id,
    m.start_time,
    m.end_time,
    m.time_zone,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    m.source_system
FROM DB_POC_ZOOM.SILVER.Si_MEETINGS m
LEFT JOIN DB_POC_ZOOM.SILVER.Si_USERS u ON m.host_id = u.user_id
LEFT JOIN (
    SELECT 
        meeting_id,
        COUNT(*) as participant_count,
        SUM(attendance_duration_minutes) as total_attendance_minutes
    FROM DB_POC_ZOOM.SILVER.Si_PARTICIPANTS 
    GROUP BY meeting_id
) p ON m.meeting_id = p.meeting_id
LEFT JOIN (
    SELECT 
        meeting_id,
        SUM(usage_count) as feature_usage_count
    FROM DB_POC_ZOOM.SILVER.Si_FEATURE_USAGE 
    GROUP BY meeting_id
) f ON m.meeting_id = f.meeting_id
WHERE m.load_date >= CURRENT_DATE() - 1;
```

#### 1.2 Data Quality and Validation Rules

**Rationale:** Ensure data integrity by applying business rules and constraints defined in the conceptual model, including duration limits, valid timestamps, and referential integrity.

**SQL Example:**
```sql
-- Data Quality Validation for Meeting Facts
INSERT INTO DB_POC_ZOOM.GOLD.Go_DATA_VALIDATION_ERRORS (
    error_key,
    source_table_name,
    target_table_name,
    error_type,
    error_description,
    affected_column,
    error_value,
    error_severity,
    error_date,
    error_timestamp,
    resolution_status,
    validation_rule_name
)
SELECT 
    'MEETING_DURATION_INVALID_' || meeting_id as error_key,
    'Si_MEETINGS' as source_table_name,
    'Go_MEETING_FACTS' as target_table_name,
    'BUSINESS_RULE_VIOLATION' as error_type,
    'Meeting duration exceeds maximum allowed limit of 1440 minutes' as error_description,
    'duration_minutes' as affected_column,
    duration_minutes::VARCHAR as error_value,
    'HIGH' as error_severity,
    CURRENT_DATE() as error_date,
    CURRENT_TIMESTAMP() as error_timestamp,
    'OPEN' as resolution_status,
    'MEETING_DURATION_CONSTRAINT' as validation_rule_name
FROM DB_POC_ZOOM.SILVER.Si_MEETINGS
WHERE duration_minutes > 1440 OR duration_minutes < 0;
```

#### 1.3 Calculated Fields and Derived Metrics

**Rationale:** Generate business-relevant calculated fields such as engagement scores, meeting efficiency metrics, and categorizations that support KPI calculations and analytical reporting.

**SQL Example:**
```sql
-- Update Meeting Facts with Calculated Fields
UPDATE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS 
SET 
    meeting_efficiency_score = CASE 
        WHEN average_attendance_percentage >= 80 AND feature_usage_count >= 3 THEN 'HIGH'
        WHEN average_attendance_percentage >= 60 AND feature_usage_count >= 2 THEN 'MEDIUM'
        ELSE 'LOW'
    END,
    meeting_productivity_index = ROUND(
        (average_attendance_percentage * 0.6) + 
        (LEAST(feature_usage_count * 10, 40) * 0.4), 2
    )
WHERE load_date = CURRENT_DATE();
```

### 2. Go_BILLING_FACTS Transformation Rules

#### 2.1 Revenue Recognition and Financial Calculations

**Rationale:** Transform billing events into revenue facts with proper revenue recognition rules, currency standardization, and financial metrics calculation for accurate revenue reporting.

**SQL Example:**
```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_BILLING_FACTS (
    transaction_date,
    user_name,
    event_type,
    amount,
    currency_code,
    payment_method,
    transaction_status,
    plan_type,
    company,
    revenue_recognition_amount,
    billing_event_id,
    user_id,
    event_date,
    load_date,
    update_date,
    source_system
)
SELECT 
    b.event_date as transaction_date,
    u.user_name,
    b.event_type,
    b.amount,
    b.currency_code,
    b.payment_method,
    b.transaction_status,
    u.plan_type,
    u.company,
    CASE 
        WHEN b.event_type = 'Subscription' THEN b.amount
        WHEN b.event_type = 'Upgrade' THEN b.amount
        WHEN b.event_type = 'Refund' THEN -b.amount
        ELSE b.amount
    END as revenue_recognition_amount,
    b.billing_event_id,
    b.user_id,
    b.event_date,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    b.source_system
FROM DB_POC_ZOOM.SILVER.Si_BILLING_EVENTS b
INNER JOIN DB_POC_ZOOM.SILVER.Si_USERS u ON b.user_id = u.user_id
WHERE b.load_date >= CURRENT_DATE() - 1
AND b.transaction_status = 'Completed';
```

#### 2.2 Currency Standardization and Exchange Rate Application

**Rationale:** Standardize all financial amounts to a base currency (USD) for consistent reporting and analysis across different geographic regions.

**SQL Example:**
```sql
-- Currency Standardization (assuming exchange rates table exists)
UPDATE DB_POC_ZOOM.GOLD.Go_BILLING_FACTS bf
SET 
    amount_usd = CASE 
        WHEN bf.currency_code = 'USD' THEN bf.amount
        ELSE bf.amount * COALESCE(er.exchange_rate_to_usd, 1.0)
    END,
    revenue_recognition_amount_usd = CASE 
        WHEN bf.currency_code = 'USD' THEN bf.revenue_recognition_amount
        ELSE bf.revenue_recognition_amount * COALESCE(er.exchange_rate_to_usd, 1.0)
    END
FROM (
    SELECT currency_code, exchange_rate_to_usd 
    FROM DB_POC_ZOOM.REFERENCE.EXCHANGE_RATES 
    WHERE rate_date = CURRENT_DATE()
) er
WHERE bf.currency_code = er.currency_code
AND bf.load_date = CURRENT_DATE();
```

### 3. Go_SUPPORT_FACTS Transformation Rules

#### 3.1 SLA Compliance and Performance Metrics

**Rationale:** Calculate support performance metrics including SLA compliance, resolution efficiency, and escalation patterns to enable service reliability analysis.

**SQL Example:**
```sql
INSERT INTO DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS (
    ticket_date,
    user_name,
    ticket_type,
    priority_level,
    resolution_status,
    resolution_time_hours,
    first_response_time_hours,
    escalation_flag,
    sla_breach_flag,
    company,
    plan_type,
    assigned_agent,
    support_ticket_id,
    user_id,
    issue_description,
    open_date,
    close_date,
    load_date,
    update_date,
    source_system
)
SELECT 
    s.open_date as ticket_date,
    u.user_name,
    s.ticket_type,
    s.priority_level,
    s.resolution_status,
    s.resolution_time_hours,
    s.first_response_time_hours,
    s.escalation_flag,
    CASE 
        WHEN s.priority_level = 'Critical' AND s.first_response_time_hours > 1 THEN TRUE
        WHEN s.priority_level = 'High' AND s.resolution_time_hours > 24 THEN TRUE
        WHEN s.priority_level = 'Medium' AND s.resolution_time_hours > 72 THEN TRUE
        ELSE FALSE
    END as sla_breach_flag,
    u.company,
    u.plan_type,
    'System_Agent' as assigned_agent, -- Placeholder for actual agent assignment
    s.support_ticket_id,
    s.user_id,
    s.issue_description,
    s.open_date,
    s.close_date,
    CURRENT_DATE() as load_date,
    CURRENT_DATE() as update_date,
    s.source_system
FROM DB_POC_ZOOM.SILVER.Si_SUPPORT_TICKETS s
INNER JOIN DB_POC_ZOOM.SILVER.Si_USERS u ON s.user_id = u.user_id
WHERE s.load_date >= CURRENT_DATE() - 1;
```

#### 3.2 Customer Satisfaction and Service Quality Metrics

**Rationale:** Derive service quality indicators and customer satisfaction proxies based on resolution patterns, escalation frequency, and ticket characteristics.

**SQL Example:**
```sql
-- Calculate Service Quality Score
UPDATE DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS 
SET 
    service_quality_score = CASE 
        WHEN sla_breach_flag = FALSE AND escalation_flag = FALSE AND resolution_time_hours <= (
            CASE priority_level 
                WHEN 'Critical' THEN 4
                WHEN 'High' THEN 12
                WHEN 'Medium' THEN 48
                ELSE 120
            END
        ) THEN 'EXCELLENT'
        WHEN sla_breach_flag = FALSE AND escalation_flag = FALSE THEN 'GOOD'
        WHEN sla_breach_flag = TRUE OR escalation_flag = TRUE THEN 'POOR'
        ELSE 'AVERAGE'
    END,
    customer_impact_score = CASE 
        WHEN priority_level = 'Critical' THEN 100
        WHEN priority_level = 'High' THEN 75
        WHEN priority_level = 'Medium' THEN 50
        WHEN priority_level = 'Low' THEN 25
        ELSE 0
    END
WHERE load_date = CURRENT_DATE();
```

## 4. Cross-Fact Table Transformation Rules

### 4.1 Data Consistency and Referential Integrity

**Rationale:** Ensure consistent data relationships across all fact tables and maintain referential integrity with dimension tables.

**SQL Example:**
```sql
-- Validate User References Across All Fact Tables
INSERT INTO DB_POC_ZOOM.GOLD.Go_DATA_VALIDATION_ERRORS (
    error_key,
    source_table_name,
    target_table_name,
    error_type,
    error_description,
    error_severity,
    error_date,
    error_timestamp,
    resolution_status,
    validation_rule_name
)
SELECT 
    'ORPHANED_USER_REFERENCE_' || fact_table || '_' || user_identifier as error_key,
    fact_table as source_table_name,
    'Go_USER_DIMENSION' as target_table_name,
    'REFERENTIAL_INTEGRITY_VIOLATION' as error_type,
    'User reference not found in dimension table' as error_description,
    'HIGH' as error_severity,
    CURRENT_DATE() as error_date,
    CURRENT_TIMESTAMP() as error_timestamp,
    'OPEN' as resolution_status,
    'USER_DIMENSION_REFERENTIAL_INTEGRITY' as validation_rule_name
FROM (
    SELECT 'Go_MEETING_FACTS' as fact_table, host_name as user_identifier FROM DB_POC_ZOOM.GOLD.Go_MEETING_FACTS
    UNION ALL
    SELECT 'Go_BILLING_FACTS' as fact_table, user_name as user_identifier FROM DB_POC_ZOOM.GOLD.Go_BILLING_FACTS
    UNION ALL
    SELECT 'Go_SUPPORT_FACTS' as fact_table, user_name as user_identifier FROM DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS
) fact_users
WHERE user_identifier NOT IN (
    SELECT user_name FROM DB_POC_ZOOM.GOLD.Go_USER_DIMENSION WHERE current_flag = TRUE
);
```

### 4.2 Temporal Alignment and Date Standardization

**Rationale:** Ensure all fact tables use consistent date formats and time zone handling for accurate cross-fact analysis and reporting.

**SQL Example:**
```sql
-- Standardize Date Fields Across All Fact Tables
CREATE OR REPLACE PROCEDURE STANDARDIZE_FACT_TABLE_DATES()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Update Meeting Facts
    UPDATE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS 
    SET meeting_date_key = TO_CHAR(meeting_date, 'YYYYMMDD')::NUMBER
    WHERE meeting_date_key IS NULL;
    
    -- Update Billing Facts
    UPDATE DB_POC_ZOOM.GOLD.Go_BILLING_FACTS 
    SET transaction_date_key = TO_CHAR(transaction_date, 'YYYYMMDD')::NUMBER
    WHERE transaction_date_key IS NULL;
    
    -- Update Support Facts
    UPDATE DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS 
    SET ticket_date_key = TO_CHAR(ticket_date, 'YYYYMMDD')::NUMBER
    WHERE ticket_date_key IS NULL;
    
    RETURN 'Date standardization completed successfully';
END;
$$;
```

## 5. Performance Optimization Rules

### 5.1 Clustering and Partitioning Strategy

**Rationale:** Optimize query performance by implementing appropriate clustering keys and partitioning strategies based on common query patterns and data access requirements.

**SQL Example:**
```sql
-- Implement Clustering for Fact Tables
ALTER TABLE DB_POC_ZOOM.GOLD.Go_MEETING_FACTS CLUSTER BY (meeting_date, host_name);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_BILLING_FACTS CLUSTER BY (transaction_date, user_name);
ALTER TABLE DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS CLUSTER BY (ticket_date, priority_level);

-- Create Materialized Views for Common Aggregations
CREATE OR REPLACE SECURE VIEW DB_POC_ZOOM.GOLD.VW_DAILY_MEETING_SUMMARY AS
SELECT 
    meeting_date,
    COUNT(*) as total_meetings,
    SUM(duration_minutes) as total_meeting_minutes,
    COUNT(DISTINCT host_name) as unique_hosts,
    AVG(participant_count) as avg_participants_per_meeting,
    SUM(feature_usage_count) as total_feature_usage
FROM DB_POC_ZOOM.GOLD.Go_MEETING_FACTS
GROUP BY meeting_date;
```

### 5.2 Incremental Loading Strategy

**Rationale:** Implement efficient incremental loading patterns to minimize processing time and resource consumption while ensuring data freshness.

**SQL Example:**
```sql
-- Incremental Load Pattern for Fact Tables
CREATE OR REPLACE PROCEDURE INCREMENTAL_LOAD_FACT_TABLES(LOAD_DATE DATE)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Delete existing records for the load date
    DELETE FROM DB_POC_ZOOM.GOLD.Go_MEETING_FACTS WHERE meeting_date = LOAD_DATE;
    DELETE FROM DB_POC_ZOOM.GOLD.Go_BILLING_FACTS WHERE transaction_date = LOAD_DATE;
    DELETE FROM DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS WHERE ticket_date = LOAD_DATE;
    
    -- Insert new records
    INSERT INTO DB_POC_ZOOM.GOLD.Go_MEETING_FACTS 
    SELECT /* Meeting Facts transformation logic for LOAD_DATE */;
    
    INSERT INTO DB_POC_ZOOM.GOLD.Go_BILLING_FACTS 
    SELECT /* Billing Facts transformation logic for LOAD_DATE */;
    
    INSERT INTO DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS 
    SELECT /* Support Facts transformation logic for LOAD_DATE */;
    
    RETURN 'Incremental load completed for date: ' || LOAD_DATE;
END;
$$;
```

## 6. Data Quality and Monitoring Rules

### 6.1 Automated Data Quality Checks

**Rationale:** Implement comprehensive data quality monitoring to ensure fact table data meets business requirements and maintains high quality standards.

**SQL Example:**
```sql
-- Comprehensive Data Quality Check Procedure
CREATE OR REPLACE PROCEDURE RUN_FACT_TABLE_QUALITY_CHECKS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Check for null values in critical fields
    INSERT INTO DB_POC_ZOOM.GOLD.Go_DATA_VALIDATION_ERRORS
    SELECT 
        'NULL_CHECK_' || table_name || '_' || column_name || '_' || CURRENT_TIMESTAMP()::STRING as error_key,
        table_name as source_table_name,
        table_name as target_table_name,
        'NULL_VALUE_VIOLATION' as error_type,
        'Critical field contains null values' as error_description,
        column_name as affected_column,
        'NULL' as error_value,
        'HIGH' as error_severity,
        CURRENT_DATE() as error_date,
        CURRENT_TIMESTAMP() as error_timestamp,
        'OPEN' as resolution_status,
        'CRITICAL_FIELD_NULL_CHECK' as validation_rule_name
    FROM (
        SELECT 'Go_MEETING_FACTS' as table_name, 'meeting_date' as column_name, COUNT(*) as null_count
        FROM DB_POC_ZOOM.GOLD.Go_MEETING_FACTS WHERE meeting_date IS NULL
        UNION ALL
        SELECT 'Go_BILLING_FACTS' as table_name, 'transaction_date' as column_name, COUNT(*) as null_count
        FROM DB_POC_ZOOM.GOLD.Go_BILLING_FACTS WHERE transaction_date IS NULL
        UNION ALL
        SELECT 'Go_SUPPORT_FACTS' as table_name, 'ticket_date' as column_name, COUNT(*) as null_count
        FROM DB_POC_ZOOM.GOLD.Go_SUPPORT_FACTS WHERE ticket_date IS NULL
    ) quality_checks
    WHERE null_count > 0;
    
    RETURN 'Data quality checks completed';
END;
$$;
```

## 7. Business Rule Implementation

### 7.1 KPI Calculation Rules

**Rationale:** Implement standardized KPI calculations directly in the transformation layer to ensure consistency across all reporting and analytics use cases.

**SQL Example:**
```sql
-- Daily Active Users (DAU) Calculation
CREATE OR REPLACE VIEW DB_POC_ZOOM.GOLD.VW_DAILY_ACTIVE_USERS AS
SELECT 
    meeting_date,
    COUNT(DISTINCT host_name) as daily_active_users,
    COUNT(*) as total_meetings,
    SUM(duration_minutes) as total_meeting_minutes,
    AVG(duration_minutes) as average_meeting_duration
FROM DB_POC_ZOOM.GOLD.Go_MEETING_FACTS
GROUP BY meeting_date;

-- Monthly Recurring Revenue (MRR) Calculation
CREATE OR REPLACE VIEW DB_POC_ZOOM.GOLD.VW_MONTHLY_RECURRING_REVENUE AS
SELECT 
    DATE_TRUNC('MONTH', transaction_date) as revenue_month,
    SUM(CASE WHEN event_type = 'Subscription' THEN revenue_recognition_amount ELSE 0 END) as subscription_revenue,
    SUM(CASE WHEN event_type = 'Upgrade' THEN revenue_recognition_amount ELSE 0 END) as upgrade_revenue,
    SUM(CASE WHEN event_type = 'Refund' THEN revenue_recognition_amount ELSE 0 END) as refund_amount,
    SUM(revenue_recognition_amount) as total_revenue
FROM DB_POC_ZOOM.GOLD.Go_BILLING_FACTS
WHERE event_type IN ('Subscription', 'Upgrade', 'Refund')
GROUP BY DATE_TRUNC('MONTH', transaction_date);
```

## 8. Error Handling and Recovery

### 8.1 Transformation Error Recovery

**Rationale:** Implement robust error handling and recovery mechanisms to ensure data pipeline resilience and minimize data loss during transformation failures.

**SQL Example:**
```sql
-- Error Recovery Procedure
CREATE OR REPLACE PROCEDURE RECOVER_FAILED_TRANSFORMATIONS(RECOVERY_DATE DATE)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Log recovery attempt
    INSERT INTO DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT (
        audit_key,
        pipeline_name,
        execution_start_time,
        execution_status,
        processed_by
    ) VALUES (
        'RECOVERY_' || RECOVERY_DATE || '_' || CURRENT_TIMESTAMP(),
        'FACT_TABLE_RECOVERY',
        CURRENT_TIMESTAMP(),
        'RUNNING',
        'SYSTEM_RECOVERY_PROCESS'
    );
    
    -- Attempt to reprocess failed records
    CALL INCREMENTAL_LOAD_FACT_TABLES(RECOVERY_DATE);
    
    -- Update audit log
    UPDATE DB_POC_ZOOM.GOLD.Go_PIPELINE_AUDIT 
    SET 
        execution_end_time = CURRENT_TIMESTAMP(),
        execution_status = 'COMPLETED',
        execution_duration_seconds = DATEDIFF('second', execution_start_time, CURRENT_TIMESTAMP())
    WHERE audit_key = 'RECOVERY_' || RECOVERY_DATE || '_' || CURRENT_TIMESTAMP();
    
    RETURN 'Recovery process completed for date: ' || RECOVERY_DATE;
END;
$$;
```

## Conclusion

These comprehensive transformation rules ensure that the Gold layer fact tables are optimized for analytical workloads, maintain high data quality standards, and support the business requirements defined in the Zoom Platform Analytics System. The rules cover data integration, quality validation, performance optimization, and business logic implementation to create a robust and reliable analytical foundation.

Regular monitoring and maintenance of these transformation rules will ensure continued data accuracy and system performance as the platform evolves and scales.