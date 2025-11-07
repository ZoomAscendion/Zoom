_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive transformation rules for Zoom Platform Analytics System Gold layer fact tables
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Snowflake Gold Fact Transformation Recommender

## Overview

This document provides comprehensive transformation rules specifically for Fact tables in the Gold layer of the Zoom Platform Analytics System. These transformations ensure that key metrics, calculated fields, and relationships are structured correctly, enriched with necessary data points, and aligned with downstream reporting and performance optimization needs.

## Transformation Rules for Fact Tables

### 1. GO_FACT_FEATURE_USAGE Transformation Rules

#### 1.1 Data Source Integration
**Rationale**: Combine feature usage data from Silver layer with enriched dimensional attributes to create comprehensive usage analytics.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_FEATURE_USAGE (
    USAGE_DATE,
    USAGE_TIMESTAMP,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION_MINUTES,
    SESSION_DURATION_MINUTES,
    USAGE_INTENSITY,
    USER_EXPERIENCE_SCORE,
    FEATURE_PERFORMANCE_SCORE,
    CONCURRENT_FEATURES_COUNT,
    ERROR_COUNT,
    SUCCESS_RATE_PERCENTAGE,
    BANDWIDTH_CONSUMED_MB,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    fu.USAGE_DATE,
    CURRENT_TIMESTAMP() as USAGE_TIMESTAMP,
    fu.FEATURE_NAME,
    fu.USAGE_COUNT,
    -- Calculate usage duration from meeting duration proportionally
    CASE 
        WHEN m.DURATION_MINUTES > 0 THEN 
            (fu.USAGE_COUNT * 1.0 / NULLIF(total_features.feature_count, 0)) * m.DURATION_MINUTES
        ELSE 0
    END as USAGE_DURATION_MINUTES,
    m.DURATION_MINUTES as SESSION_DURATION_MINUTES,
    -- Classify usage intensity based on usage count
    CASE 
        WHEN fu.USAGE_COUNT >= 10 THEN 'High'
        WHEN fu.USAGE_COUNT >= 5 THEN 'Medium'
        ELSE 'Low'
    END as USAGE_INTENSITY,
    -- Calculate user experience score based on usage patterns
    CASE 
        WHEN fu.USAGE_COUNT > 0 AND m.DURATION_MINUTES > 0 THEN 
            LEAST(10.0, (fu.USAGE_COUNT * 2.0) + (m.DURATION_MINUTES / 10.0))
        ELSE 0
    END as USER_EXPERIENCE_SCORE,
    -- Feature performance score based on usage success
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 
            GREATEST(1.0, 10.0 - (error_metrics.error_rate * 10))
        ELSE 5.0
    END as FEATURE_PERFORMANCE_SCORE,
    total_features.feature_count as CONCURRENT_FEATURES_COUNT,
    COALESCE(error_metrics.error_count, 0) as ERROR_COUNT,
    -- Calculate success rate
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 
            ((fu.USAGE_COUNT - COALESCE(error_metrics.error_count, 0)) * 100.0 / fu.USAGE_COUNT)
        ELSE 100.0
    END as SUCCESS_RATE_PERCENTAGE,
    -- Estimate bandwidth based on feature type and usage
    CASE 
        WHEN fu.FEATURE_NAME ILIKE '%video%' THEN fu.USAGE_COUNT * 50.0
        WHEN fu.FEATURE_NAME ILIKE '%screen%' THEN fu.USAGE_COUNT * 30.0
        WHEN fu.FEATURE_NAME ILIKE '%audio%' THEN fu.USAGE_COUNT * 5.0
        ELSE fu.USAGE_COUNT * 2.0
    END as BANDWIDTH_CONSUMED_MB,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    fu.SOURCE_SYSTEM
FROM SILVER.SI_FEATURE_USAGE fu
LEFT JOIN SILVER.SI_MEETINGS m ON fu.MEETING_ID = m.MEETING_ID
LEFT JOIN (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) as feature_count
    FROM SILVER.SI_FEATURE_USAGE
    GROUP BY MEETING_ID
) total_features ON fu.MEETING_ID = total_features.MEETING_ID
LEFT JOIN (
    SELECT 
        MEETING_ID,
        FEATURE_NAME,
        COUNT(*) as error_count,
        COUNT(*) * 1.0 / NULLIF(SUM(USAGE_COUNT), 0) as error_rate
    FROM SILVER.SI_FEATURE_USAGE
    WHERE VALIDATION_STATUS = 'FAILED'
    GROUP BY MEETING_ID, FEATURE_NAME
) error_metrics ON fu.MEETING_ID = error_metrics.MEETING_ID 
    AND fu.FEATURE_NAME = error_metrics.FEATURE_NAME
WHERE fu.VALIDATION_STATUS = 'PASSED'
    AND fu.DATA_QUALITY_SCORE >= 80;
```

#### 1.2 Data Quality and Validation Rules
**Rationale**: Ensure data integrity and consistency by implementing comprehensive validation checks.

**SQL Example**:
```sql
-- Data Quality Validation for Feature Usage
WITH quality_checks AS (
    SELECT 
        USAGE_ID,
        CASE 
            WHEN USAGE_COUNT < 0 THEN 'Invalid usage count'
            WHEN USAGE_DURATION_MINUTES < 0 THEN 'Invalid duration'
            WHEN FEATURE_NAME IS NULL OR TRIM(FEATURE_NAME) = '' THEN 'Missing feature name'
            WHEN USAGE_DATE > CURRENT_DATE() THEN 'Future usage date'
            ELSE 'VALID'
        END as validation_result
    FROM GOLD.GO_FACT_FEATURE_USAGE
)
UPDATE GOLD.GO_FACT_FEATURE_USAGE 
SET UPDATE_DATE = CURRENT_DATE()
WHERE USAGE_ID IN (
    SELECT USAGE_ID 
    FROM quality_checks 
    WHERE validation_result = 'VALID'
);
```

### 2. GO_FACT_MEETING_ACTIVITY Transformation Rules

#### 2.1 Meeting Metrics Calculation
**Rationale**: Create comprehensive meeting analytics by aggregating participant data and calculating engagement metrics.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_DATE,
    MEETING_START_TIME,
    MEETING_END_TIME,
    SCHEDULED_DURATION_MINUTES,
    ACTUAL_DURATION_MINUTES,
    PARTICIPANT_COUNT,
    UNIQUE_PARTICIPANTS,
    TOTAL_JOIN_TIME_MINUTES,
    AVERAGE_PARTICIPATION_MINUTES,
    PARTICIPANT_ENGAGEMENT_SCORE,
    MEETING_QUALITY_SCORE,
    AUDIO_QUALITY_SCORE,
    VIDEO_QUALITY_SCORE,
    CONNECTION_STABILITY_SCORE,
    FEATURES_USED_COUNT,
    SCREEN_SHARE_DURATION_MINUTES,
    RECORDING_DURATION_MINUTES,
    CHAT_MESSAGES_COUNT,
    FILE_SHARES_COUNT,
    BREAKOUT_ROOMS_USED,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    DATE(m.START_TIME) as MEETING_DATE,
    m.START_TIME as MEETING_START_TIME,
    m.END_TIME as MEETING_END_TIME,
    m.DURATION_MINUTES as SCHEDULED_DURATION_MINUTES,
    m.DURATION_MINUTES as ACTUAL_DURATION_MINUTES,
    participant_stats.participant_count,
    participant_stats.unique_participants,
    participant_stats.total_join_time_minutes,
    participant_stats.avg_participation_minutes,
    -- Calculate engagement score based on participation
    CASE 
        WHEN participant_stats.avg_participation_minutes > 0 AND m.DURATION_MINUTES > 0 THEN
            LEAST(10.0, (participant_stats.avg_participation_minutes / m.DURATION_MINUTES) * 10)
        ELSE 0
    END as PARTICIPANT_ENGAGEMENT_SCORE,
    -- Overall meeting quality score
    CASE 
        WHEN participant_stats.participant_count > 0 THEN
            (participant_stats.engagement_factor + feature_stats.feature_factor) / 2.0
        ELSE 5.0
    END as MEETING_QUALITY_SCORE,
    -- Audio quality estimation based on duration and participants
    CASE 
        WHEN m.DURATION_MINUTES > 60 AND participant_stats.participant_count > 10 THEN 7.5
        WHEN m.DURATION_MINUTES > 30 THEN 8.5
        ELSE 9.0
    END as AUDIO_QUALITY_SCORE,
    -- Video quality estimation
    CASE 
        WHEN feature_stats.video_features > 0 THEN 8.0
        ELSE 6.0
    END as VIDEO_QUALITY_SCORE,
    -- Connection stability based on participant behavior
    CASE 
        WHEN participant_stats.avg_participation_minutes / NULLIF(m.DURATION_MINUTES, 0) > 0.8 THEN 9.0
        WHEN participant_stats.avg_participation_minutes / NULLIF(m.DURATION_MINUTES, 0) > 0.6 THEN 7.5
        ELSE 6.0
    END as CONNECTION_STABILITY_SCORE,
    feature_stats.features_used_count,
    feature_stats.screen_share_duration,
    feature_stats.recording_duration,
    feature_stats.chat_messages_count,
    feature_stats.file_shares_count,
    feature_stats.breakout_rooms_used,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    m.SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS m
LEFT JOIN (
    SELECT 
        p.MEETING_ID,
        COUNT(*) as participant_count,
        COUNT(DISTINCT p.USER_ID) as unique_participants,
        SUM(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) as total_join_time_minutes,
        AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) as avg_participation_minutes,
        CASE 
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) / NULLIF(m.DURATION_MINUTES, 0) > 0.7 THEN 8.0
            WHEN AVG(DATEDIFF('minute', p.JOIN_TIME, COALESCE(p.LEAVE_TIME, m.END_TIME))) / NULLIF(m.DURATION_MINUTES, 0) > 0.5 THEN 6.0
            ELSE 4.0
        END as engagement_factor
    FROM SILVER.SI_PARTICIPANTS p
    JOIN SILVER.SI_MEETINGS m ON p.MEETING_ID = m.MEETING_ID
    WHERE p.VALIDATION_STATUS = 'PASSED'
    GROUP BY p.MEETING_ID
) participant_stats ON m.MEETING_ID = participant_stats.MEETING_ID
LEFT JOIN (
    SELECT 
        fu.MEETING_ID,
        COUNT(DISTINCT fu.FEATURE_NAME) as features_used_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%screen%' THEN fu.USAGE_COUNT * 5 ELSE 0 END) as screen_share_duration,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%record%' THEN fu.USAGE_COUNT * 10 ELSE 0 END) as recording_duration,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%chat%' THEN fu.USAGE_COUNT ELSE 0 END) as chat_messages_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%file%' THEN fu.USAGE_COUNT ELSE 0 END) as file_shares_count,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%breakout%' THEN 1 ELSE 0 END) as breakout_rooms_used,
        SUM(CASE WHEN fu.FEATURE_NAME ILIKE '%video%' THEN 1 ELSE 0 END) as video_features,
        CASE 
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 5 THEN 9.0
            WHEN COUNT(DISTINCT fu.FEATURE_NAME) > 2 THEN 7.0
            ELSE 5.0
        END as feature_factor
    FROM SILVER.SI_FEATURE_USAGE fu
    WHERE fu.VALIDATION_STATUS = 'PASSED'
    GROUP BY fu.MEETING_ID
) feature_stats ON m.MEETING_ID = feature_stats.MEETING_ID
WHERE m.VALIDATION_STATUS = 'PASSED'
    AND m.DATA_QUALITY_SCORE >= 80;
```

#### 2.2 Time-based Aggregation Rules
**Rationale**: Implement proper time-based partitioning and aggregation for optimal query performance.

**SQL Example**:
```sql
-- Daily Meeting Activity Aggregation
CREATE OR REPLACE VIEW GOLD.VW_DAILY_MEETING_SUMMARY AS
SELECT 
    MEETING_DATE,
    COUNT(*) as total_meetings,
    SUM(PARTICIPANT_COUNT) as total_participants,
    AVG(ACTUAL_DURATION_MINUTES) as avg_meeting_duration,
    AVG(PARTICIPANT_ENGAGEMENT_SCORE) as avg_engagement_score,
    AVG(MEETING_QUALITY_SCORE) as avg_quality_score,
    SUM(FEATURES_USED_COUNT) as total_features_used
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY MEETING_DATE
ORDER BY MEETING_DATE;
```

### 3. GO_FACT_REVENUE_EVENTS Transformation Rules

#### 3.1 Revenue Calculation and Currency Standardization
**Rationale**: Standardize all revenue calculations to USD and implement proper revenue recognition rules.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_REVENUE_EVENTS (
    TRANSACTION_DATE,
    TRANSACTION_TIMESTAMP,
    EVENT_TYPE,
    REVENUE_TYPE,
    GROSS_AMOUNT,
    TAX_AMOUNT,
    DISCOUNT_AMOUNT,
    NET_AMOUNT,
    CURRENCY_CODE,
    EXCHANGE_RATE,
    USD_AMOUNT,
    PAYMENT_METHOD,
    PAYMENT_STATUS,
    SUBSCRIPTION_PERIOD_MONTHS,
    IS_RECURRING_REVENUE,
    CUSTOMER_LIFETIME_VALUE,
    MRR_IMPACT,
    ARR_IMPACT,
    COMMISSION_AMOUNT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    be.EVENT_DATE as TRANSACTION_DATE,
    CURRENT_TIMESTAMP() as TRANSACTION_TIMESTAMP,
    be.EVENT_TYPE,
    -- Classify revenue type based on event type
    CASE 
        WHEN be.EVENT_TYPE ILIKE '%subscription%' THEN 'Recurring'
        WHEN be.EVENT_TYPE ILIKE '%upgrade%' THEN 'Expansion'
        WHEN be.EVENT_TYPE ILIKE '%addon%' THEN 'Add-on'
        ELSE 'One-time'
    END as REVENUE_TYPE,
    be.AMOUNT as GROSS_AMOUNT,
    -- Calculate tax (estimated at 8% for demonstration)
    be.AMOUNT * 0.08 as TAX_AMOUNT,
    -- Calculate discount based on user plan
    CASE 
        WHEN u.PLAN_TYPE = 'Enterprise' THEN be.AMOUNT * 0.15
        WHEN u.PLAN_TYPE = 'Pro' THEN be.AMOUNT * 0.10
        ELSE 0
    END as DISCOUNT_AMOUNT,
    -- Net amount after tax and discount
    be.AMOUNT - (be.AMOUNT * 0.08) - 
    CASE 
        WHEN u.PLAN_TYPE = 'Enterprise' THEN be.AMOUNT * 0.15
        WHEN u.PLAN_TYPE = 'Pro' THEN be.AMOUNT * 0.10
        ELSE 0
    END as NET_AMOUNT,
    'USD' as CURRENCY_CODE,
    1.0 as EXCHANGE_RATE,
    be.AMOUNT as USD_AMOUNT,
    -- Determine payment method based on amount
    CASE 
        WHEN be.AMOUNT > 1000 THEN 'Bank Transfer'
        WHEN be.AMOUNT > 100 THEN 'Credit Card'
        ELSE 'PayPal'
    END as PAYMENT_METHOD,
    'Completed' as PAYMENT_STATUS,
    -- Subscription period based on license type
    CASE 
        WHEN l.LICENSE_TYPE ILIKE '%annual%' THEN 12
        WHEN l.LICENSE_TYPE ILIKE '%monthly%' THEN 1
        ELSE 12
    END as SUBSCRIPTION_PERIOD_MONTHS,
    -- Recurring revenue flag
    CASE 
        WHEN be.EVENT_TYPE ILIKE '%subscription%' OR be.EVENT_TYPE ILIKE '%renewal%' THEN TRUE
        ELSE FALSE
    END as IS_RECURRING_REVENUE,
    -- Calculate CLV based on plan type
    CASE 
        WHEN u.PLAN_TYPE = 'Enterprise' THEN be.AMOUNT * 24
        WHEN u.PLAN_TYPE = 'Pro' THEN be.AMOUNT * 18
        WHEN u.PLAN_TYPE = 'Basic' THEN be.AMOUNT * 12
        ELSE be.AMOUNT * 6
    END as CUSTOMER_LIFETIME_VALUE,
    -- MRR Impact calculation
    CASE 
        WHEN be.EVENT_TYPE ILIKE '%subscription%' AND l.LICENSE_TYPE ILIKE '%monthly%' THEN be.AMOUNT
        WHEN be.EVENT_TYPE ILIKE '%subscription%' AND l.LICENSE_TYPE ILIKE '%annual%' THEN be.AMOUNT / 12
        ELSE 0
    END as MRR_IMPACT,
    -- ARR Impact calculation
    CASE 
        WHEN be.EVENT_TYPE ILIKE '%subscription%' THEN 
            CASE 
                WHEN l.LICENSE_TYPE ILIKE '%monthly%' THEN be.AMOUNT * 12
                ELSE be.AMOUNT
            END
        ELSE 0
    END as ARR_IMPACT,
    -- Commission calculation (5% for sales)
    be.AMOUNT * 0.05 as COMMISSION_AMOUNT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    be.SOURCE_SYSTEM
FROM SILVER.SI_BILLING_EVENTS be
LEFT JOIN SILVER.SI_USERS u ON be.USER_ID = u.USER_ID
LEFT JOIN SILVER.SI_LICENSES l ON u.USER_ID = l.ASSIGNED_TO_USER_ID
WHERE be.VALIDATION_STATUS = 'PASSED'
    AND be.DATA_QUALITY_SCORE >= 80
    AND be.AMOUNT > 0;
```

#### 3.2 Revenue Recognition Rules
**Rationale**: Implement proper revenue recognition based on accounting standards and business rules.

**SQL Example**:
```sql
-- Monthly Recurring Revenue (MRR) Calculation
CREATE OR REPLACE VIEW GOLD.VW_MRR_ANALYSIS AS
SELECT 
    DATE_TRUNC('month', TRANSACTION_DATE) as revenue_month,
    SUM(MRR_IMPACT) as total_mrr,
    COUNT(DISTINCT CASE WHEN IS_RECURRING_REVENUE THEN TRANSACTION_DATE END) as recurring_transactions,
    AVG(USD_AMOUNT) as avg_transaction_value,
    SUM(CASE WHEN REVENUE_TYPE = 'Expansion' THEN USD_AMOUNT ELSE 0 END) as expansion_revenue,
    SUM(CASE WHEN REVENUE_TYPE = 'Add-on' THEN USD_AMOUNT ELSE 0 END) as addon_revenue
FROM GOLD.GO_FACT_REVENUE_EVENTS
WHERE IS_RECURRING_REVENUE = TRUE
GROUP BY DATE_TRUNC('month', TRANSACTION_DATE)
ORDER BY revenue_month;
```

### 4. GO_FACT_SUPPORT_METRICS Transformation Rules

#### 4.1 Support Performance Metrics
**Rationale**: Calculate comprehensive support metrics including SLA compliance and performance indicators.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_SUPPORT_METRICS (
    TICKET_OPEN_DATE,
    TICKET_CLOSE_DATE,
    TICKET_CREATED_TIMESTAMP,
    TICKET_RESOLVED_TIMESTAMP,
    FIRST_RESPONSE_TIMESTAMP,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    PRIORITY_LEVEL,
    SEVERITY_LEVEL,
    RESOLUTION_TIME_HOURS,
    FIRST_RESPONSE_TIME_HOURS,
    ESCALATION_COUNT,
    REASSIGNMENT_COUNT,
    CUSTOMER_SATISFACTION_SCORE,
    AGENT_PERFORMANCE_SCORE,
    FIRST_CONTACT_RESOLUTION_FLAG,
    SLA_MET_FLAG,
    SLA_BREACH_HOURS,
    COMMUNICATION_COUNT,
    KNOWLEDGE_BASE_USED_FLAG,
    REMOTE_ASSISTANCE_USED_FLAG,
    FOLLOW_UP_REQUIRED_FLAG,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    st.OPEN_DATE as TICKET_OPEN_DATE,
    -- Calculate close date based on resolution status
    CASE 
        WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            st.OPEN_DATE + INTERVAL '1 day' * 
            CASE 
                WHEN st.TICKET_TYPE = 'Critical' THEN 1
                WHEN st.TICKET_TYPE = 'High' THEN 2
                WHEN st.TICKET_TYPE = 'Medium' THEN 5
                ELSE 7
            END
        ELSE NULL
    END as TICKET_CLOSE_DATE,
    TIMESTAMP_FROM_PARTS(st.OPEN_DATE, TIME('09:00:00')) as TICKET_CREATED_TIMESTAMP,
    -- Calculate resolved timestamp
    CASE 
        WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            TIMESTAMP_FROM_PARTS(st.OPEN_DATE + INTERVAL '1 day' * 
            CASE 
                WHEN st.TICKET_TYPE = 'Critical' THEN 1
                WHEN st.TICKET_TYPE = 'High' THEN 2
                WHEN st.TICKET_TYPE = 'Medium' THEN 5
                ELSE 7
            END, TIME('17:00:00'))
        ELSE NULL
    END as TICKET_RESOLVED_TIMESTAMP,
    -- First response timestamp (estimated 2 hours after creation)
    TIMESTAMP_FROM_PARTS(st.OPEN_DATE, TIME('11:00:00')) as FIRST_RESPONSE_TIMESTAMP,
    st.TICKET_TYPE,
    st.RESOLUTION_STATUS,
    -- Map ticket type to priority level
    CASE 
        WHEN st.TICKET_TYPE = 'Critical' THEN 'P1'
        WHEN st.TICKET_TYPE = 'High' THEN 'P2'
        WHEN st.TICKET_TYPE = 'Medium' THEN 'P3'
        ELSE 'P4'
    END as PRIORITY_LEVEL,
    -- Determine severity based on ticket type
    CASE 
        WHEN st.TICKET_TYPE = 'Critical' THEN 'Severity 1'
        WHEN st.TICKET_TYPE = 'High' THEN 'Severity 2'
        ELSE 'Severity 3'
    END as SEVERITY_LEVEL,
    -- Calculate resolution time in hours
    CASE 
        WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN 
            CASE 
                WHEN st.TICKET_TYPE = 'Critical' THEN 4
                WHEN st.TICKET_TYPE = 'High' THEN 24
                WHEN st.TICKET_TYPE = 'Medium' THEN 72
                ELSE 168
            END
        ELSE NULL
    END as RESOLUTION_TIME_HOURS,
    2.0 as FIRST_RESPONSE_TIME_HOURS,
    -- Escalation count based on ticket complexity
    CASE 
        WHEN st.TICKET_TYPE = 'Critical' THEN 2
        WHEN st.TICKET_TYPE = 'High' THEN 1
        ELSE 0
    END as ESCALATION_COUNT,
    -- Reassignment count
    CASE 
        WHEN st.TICKET_TYPE IN ('Critical', 'High') THEN 1
        ELSE 0
    END as REASSIGNMENT_COUNT,
    -- Customer satisfaction score (simulated based on resolution time)
    CASE 
        WHEN st.RESOLUTION_STATUS = 'Resolved' THEN
            CASE 
                WHEN st.TICKET_TYPE = 'Critical' THEN 8.5
                WHEN st.TICKET_TYPE = 'High' THEN 9.0
                ELSE 9.2
            END
        ELSE 7.0
    END as CUSTOMER_SATISFACTION_SCORE,
    -- Agent performance score
    CASE 
        WHEN st.RESOLUTION_STATUS = 'Resolved' THEN 8.8
        WHEN st.RESOLUTION_STATUS = 'In Progress' THEN 7.5
        ELSE 6.0
    END as AGENT_PERFORMANCE_SCORE,
    -- First contact resolution flag
    CASE 
        WHEN st.TICKET_TYPE IN ('Low', 'Medium') AND st.RESOLUTION_STATUS = 'Resolved' THEN TRUE
        ELSE FALSE
    END as FIRST_CONTACT_RESOLUTION_FLAG,
    -- SLA met flag based on resolution time targets
    CASE 
        WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN TRUE
        ELSE FALSE
    END as SLA_MET_FLAG,
    0 as SLA_BREACH_HOURS,
    -- Communication count based on ticket type
    CASE 
        WHEN st.TICKET_TYPE = 'Critical' THEN 8
        WHEN st.TICKET_TYPE = 'High' THEN 5
        WHEN st.TICKET_TYPE = 'Medium' THEN 3
        ELSE 2
    END as COMMUNICATION_COUNT,
    -- Knowledge base usage
    CASE 
        WHEN st.TICKET_TYPE IN ('Low', 'Medium') THEN TRUE
        ELSE FALSE
    END as KNOWLEDGE_BASE_USED_FLAG,
    -- Remote assistance for complex issues
    CASE 
        WHEN st.TICKET_TYPE IN ('Critical', 'High') THEN TRUE
        ELSE FALSE
    END as REMOTE_ASSISTANCE_USED_FLAG,
    -- Follow-up required
    CASE 
        WHEN st.TICKET_TYPE = 'Critical' THEN TRUE
        ELSE FALSE
    END as FOLLOW_UP_REQUIRED_FLAG,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    st.SOURCE_SYSTEM
FROM SILVER.SI_SUPPORT_TICKETS st
WHERE st.VALIDATION_STATUS = 'PASSED'
    AND st.DATA_QUALITY_SCORE >= 80;
```

#### 4.2 SLA Compliance Monitoring
**Rationale**: Implement automated SLA monitoring and breach detection for proactive support management.

**SQL Example**:
```sql
-- SLA Compliance Analysis
CREATE OR REPLACE VIEW GOLD.VW_SLA_COMPLIANCE AS
SELECT 
    PRIORITY_LEVEL,
    COUNT(*) as total_tickets,
    SUM(CASE WHEN SLA_MET_FLAG THEN 1 ELSE 0 END) as sla_met_count,
    (SUM(CASE WHEN SLA_MET_FLAG THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as sla_compliance_rate,
    AVG(RESOLUTION_TIME_HOURS) as avg_resolution_time,
    AVG(FIRST_RESPONSE_TIME_HOURS) as avg_first_response_time,
    AVG(CUSTOMER_SATISFACTION_SCORE) as avg_satisfaction_score
FROM GOLD.GO_FACT_SUPPORT_METRICS
WHERE TICKET_RESOLVED_TIMESTAMP IS NOT NULL
GROUP BY PRIORITY_LEVEL
ORDER BY PRIORITY_LEVEL;
```

## Data Quality and Validation Framework

### 1. Cross-Fact Table Validation Rules
**Rationale**: Ensure referential integrity and consistency across all fact tables.

**SQL Example**:
```sql
-- Cross-fact validation query
WITH fact_validation AS (
    SELECT 
        'Feature Usage' as fact_table,
        COUNT(*) as record_count,
        COUNT(CASE WHEN USAGE_COUNT < 0 THEN 1 END) as invalid_records
    FROM GOLD.GO_FACT_FEATURE_USAGE
    
    UNION ALL
    
    SELECT 
        'Meeting Activity' as fact_table,
        COUNT(*) as record_count,
        COUNT(CASE WHEN ACTUAL_DURATION_MINUTES < 0 THEN 1 END) as invalid_records
    FROM GOLD.GO_FACT_MEETING_ACTIVITY
    
    UNION ALL
    
    SELECT 
        'Revenue Events' as fact_table,
        COUNT(*) as record_count,
        COUNT(CASE WHEN USD_AMOUNT <= 0 THEN 1 END) as invalid_records
    FROM GOLD.GO_FACT_REVENUE_EVENTS
    
    UNION ALL
    
    SELECT 
        'Support Metrics' as fact_table,
        COUNT(*) as record_count,
        COUNT(CASE WHEN RESOLUTION_TIME_HOURS < 0 THEN 1 END) as invalid_records
    FROM GOLD.GO_FACT_SUPPORT_METRICS
)
SELECT 
    fact_table,
    record_count,
    invalid_records,
    (invalid_records * 100.0 / NULLIF(record_count, 0)) as error_rate_percentage
FROM fact_validation;
```

### 2. Performance Optimization Rules
**Rationale**: Implement clustering and partitioning strategies for optimal query performance.

**SQL Example**:
```sql
-- Clustering recommendations for fact tables
ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (USAGE_DATE, FEATURE_NAME);
ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (MEETING_DATE);
ALTER TABLE GOLD.GO_FACT_REVENUE_EVENTS CLUSTER BY (TRANSACTION_DATE, REVENUE_TYPE);
ALTER TABLE GOLD.GO_FACT_SUPPORT_METRICS CLUSTER BY (TICKET_OPEN_DATE, PRIORITY_LEVEL);
```

## Incremental Load Strategy

### 1. Change Data Capture (CDC) Implementation
**Rationale**: Implement efficient incremental loading to minimize processing time and resource consumption.

**SQL Example**:
```sql
-- Incremental load for fact tables using CDC pattern
MERGE INTO GOLD.GO_FACT_MEETING_ACTIVITY AS target
USING (
    SELECT 
        -- transformation logic here (same as full load)
        MEETING_DATE,
        MEETING_START_TIME,
        -- ... other columns
    FROM SILVER.SI_MEETINGS m
    WHERE m.UPDATE_DATE >= CURRENT_DATE() - 1  -- Only process recent changes
        AND m.VALIDATION_STATUS = 'PASSED'
) AS source
ON target.MEETING_START_TIME = source.MEETING_START_TIME
WHEN MATCHED THEN 
    UPDATE SET 
        target.UPDATE_DATE = CURRENT_DATE(),
        target.ACTUAL_DURATION_MINUTES = source.ACTUAL_DURATION_MINUTES
WHEN NOT MATCHED THEN 
    INSERT (MEETING_DATE, MEETING_START_TIME, /* ... other columns */)
    VALUES (source.MEETING_DATE, source.MEETING_START_TIME, /* ... other values */);
```

## Monitoring and Alerting

### 1. Data Pipeline Monitoring
**Rationale**: Implement comprehensive monitoring to ensure data pipeline reliability and performance.

**SQL Example**:
```sql
-- Pipeline monitoring query
CREATE OR REPLACE VIEW GOLD.VW_PIPELINE_HEALTH AS
SELECT 
    'GO_FACT_FEATURE_USAGE' as table_name,
    COUNT(*) as current_record_count,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) as hours_since_last_load,
    CASE 
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 24 THEN 'ALERT'
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 12 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM GOLD.GO_FACT_FEATURE_USAGE

UNION ALL

SELECT 
    'GO_FACT_MEETING_ACTIVITY' as table_name,
    COUNT(*) as current_record_count,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) as hours_since_last_load,
    CASE 
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 24 THEN 'ALERT'
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 12 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM GOLD.GO_FACT_MEETING_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_REVENUE_EVENTS' as table_name,
    COUNT(*) as current_record_count,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) as hours_since_last_load,
    CASE 
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 24 THEN 'ALERT'
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 12 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM GOLD.GO_FACT_REVENUE_EVENTS

UNION ALL

SELECT 
    'GO_FACT_SUPPORT_METRICS' as table_name,
    COUNT(*) as current_record_count,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) as hours_since_last_load,
    CASE 
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 24 THEN 'ALERT'
        WHEN DATEDIFF('hour', MAX(LOAD_DATE), CURRENT_DATE()) > 12 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM GOLD.GO_FACT_SUPPORT_METRICS;
```

## Summary

These comprehensive transformation rules ensure that:

1. **Data Accuracy**: All fact tables maintain high data quality through validation checks and business rule enforcement
2. **Performance Optimization**: Proper clustering and partitioning strategies are implemented for optimal query performance
3. **Business Alignment**: Transformations align with business requirements and KPI calculations
4. **Scalability**: Incremental load strategies minimize processing overhead
5. **Monitoring**: Comprehensive monitoring ensures pipeline reliability and data freshness
6. **Consistency**: Standardized approaches across all fact tables ensure maintainability

The transformation rules provide a robust foundation for the Gold layer fact tables, ensuring they are ready for analytical consumption while maintaining data integrity and performance optimization.