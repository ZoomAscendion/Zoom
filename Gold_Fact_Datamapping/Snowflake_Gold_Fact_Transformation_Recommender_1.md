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

### 1. Go_Fact_Meeting_Activity Transformation Rules

#### 1.1 Data Source Integration and Key Generation

**Rationale:** Establish proper dimensional relationships and ensure unique fact record identification while integrating data from multiple Silver layer sources.

**SQL Example:**
```sql
INSERT INTO GOLD.Go_Fact_Meeting_Activity (
    FACT_MEETING_ACTIVITY_ID,
    DATE_KEY,
    USER_KEY,
    MEETING_TYPE_KEY,
    MEETING_DATE,
    MEETING_DURATION_MINUTES,
    PARTICIPANT_COUNT,
    MEETING_TYPE,
    RECORDING_ENABLED_FLAG,
    FEATURE_USAGE_COUNT,
    TOTAL_ATTENDANCE_MINUTES,
    HOST_PLAN_TYPE,
    MEETING_STATUS,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('FACT_MEET_', m.MEETING_ID, '_', TO_CHAR(m.START_TIME, 'YYYYMMDD')) AS FACT_MEETING_ACTIVITY_ID,
    DATE(m.START_TIME) AS DATE_KEY,
    m.HOST_ID AS USER_KEY,
    UPPER(REPLACE(m.MEETING_TYPE, ' ', '_')) AS MEETING_TYPE_KEY,
    DATE(m.START_TIME) AS MEETING_DATE,
    COALESCE(m.DURATION_MINUTES, 0) AS MEETING_DURATION_MINUTES,
    COALESCE(m.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
    m.MEETING_TYPE,
    CASE WHEN m.RECORDING_STATUS = 'Yes' THEN TRUE ELSE FALSE END AS RECORDING_ENABLED_FLAG,
    COALESCE(fu.FEATURE_COUNT, 0) AS FEATURE_USAGE_COUNT,
    COALESCE(att.TOTAL_ATTENDANCE, 0) AS TOTAL_ATTENDANCE_MINUTES,
    u.PLAN_TYPE AS HOST_PLAN_TYPE,
    m.MEETING_STATUS,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SILVER_LAYER' AS SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS m
LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
LEFT JOIN (
    SELECT 
        MEETING_ID,
        COUNT(DISTINCT FEATURE_NAME) AS FEATURE_COUNT
    FROM SILVER.SI_FEATURE_USAGE
    GROUP BY MEETING_ID
) fu ON m.MEETING_ID = fu.MEETING_ID
LEFT JOIN (
    SELECT 
        MEETING_ID,
        SUM(ATTENDANCE_DURATION) AS TOTAL_ATTENDANCE
    FROM SILVER.SI_PARTICIPANTS
    GROUP BY MEETING_ID
) att ON m.MEETING_ID = att.MEETING_ID
WHERE m.DATA_QUALITY_SCORE >= 0.8
  AND m.MEETING_STATUS = 'Completed'
  AND m.DURATION_MINUTES > 0;
```

#### 1.2 Data Quality and Validation Rules

**Rationale:** Ensure data integrity and consistency by applying business rules and validation checks before loading into fact tables.

**SQL Example:**
```sql
-- Data Quality Validation for Meeting Activity Facts
WITH validated_meetings AS (
    SELECT *,
        CASE 
            WHEN DURATION_MINUTES <= 0 THEN 'INVALID_DURATION'
            WHEN DURATION_MINUTES > 1440 THEN 'EXCESSIVE_DURATION'
            WHEN PARTICIPANT_COUNT < 1 THEN 'NO_PARTICIPANTS'
            WHEN START_TIME > END_TIME THEN 'INVALID_TIME_RANGE'
            ELSE 'VALID'
        END AS VALIDATION_STATUS
    FROM SILVER.SI_MEETINGS
)
SELECT 
    MEETING_ID,
    VALIDATION_STATUS,
    COUNT(*) as RECORD_COUNT
FROM validated_meetings
GROUP BY MEETING_ID, VALIDATION_STATUS
HAVING VALIDATION_STATUS != 'VALID';
```

#### 1.3 Calculated Metrics and Enrichment

**Rationale:** Add derived metrics and business calculations that support analytical requirements and KPI calculations.

**SQL Example:**
```sql
-- Enhanced Meeting Activity with Calculated Metrics
SELECT 
    m.*,
    -- Engagement Metrics
    CASE 
        WHEN m.DURATION_MINUTES > 0 THEN 
            ROUND((att.TOTAL_ATTENDANCE / (m.DURATION_MINUTES * m.PARTICIPANT_COUNT)) * 100, 2)
        ELSE 0 
    END AS ENGAGEMENT_RATE_PERCENT,
    
    -- Meeting Efficiency Score
    CASE 
        WHEN m.DURATION_MINUTES BETWEEN 15 AND 60 AND m.PARTICIPANT_COUNT BETWEEN 2 AND 10 THEN 'HIGH'
        WHEN m.DURATION_MINUTES BETWEEN 5 AND 120 AND m.PARTICIPANT_COUNT BETWEEN 1 AND 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS EFFICIENCY_SCORE,
    
    -- Feature Adoption Level
    CASE 
        WHEN fu.FEATURE_COUNT >= 5 THEN 'HIGH_ADOPTION'
        WHEN fu.FEATURE_COUNT BETWEEN 2 AND 4 THEN 'MEDIUM_ADOPTION'
        WHEN fu.FEATURE_COUNT = 1 THEN 'LOW_ADOPTION'
        ELSE 'NO_FEATURES'
    END AS FEATURE_ADOPTION_LEVEL
FROM SILVER.SI_MEETINGS m
LEFT JOIN (
    SELECT MEETING_ID, SUM(ATTENDANCE_DURATION) AS TOTAL_ATTENDANCE
    FROM SILVER.SI_PARTICIPANTS GROUP BY MEETING_ID
) att ON m.MEETING_ID = att.MEETING_ID
LEFT JOIN (
    SELECT MEETING_ID, COUNT(DISTINCT FEATURE_NAME) AS FEATURE_COUNT
    FROM SILVER.SI_FEATURE_USAGE GROUP BY MEETING_ID
) fu ON m.MEETING_ID = fu.MEETING_ID;
```

### 2. Go_Fact_Support_Metrics Transformation Rules

#### 2.1 Support Ticket Fact Generation with SLA Calculations

**Rationale:** Transform support ticket data into analytical facts with proper SLA calculations and resolution metrics.

**SQL Example:**
```sql
INSERT INTO GOLD.Go_Fact_Support_Metrics (
    FACT_SUPPORT_METRICS_ID,
    DATE_KEY,
    USER_KEY,
    SUPPORT_CATEGORY_KEY,
    TICKET_DATE,
    RESOLUTION_TIME_HOURS,
    TICKET_TYPE,
    PRIORITY_LEVEL,
    RESOLUTION_STATUS,
    FIRST_CONTACT_RESOLUTION_FLAG,
    ESCALATION_FLAG,
    CUSTOMER_PLAN_TYPE,
    SATISFACTION_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('FACT_SUPP_', st.TICKET_ID, '_', TO_CHAR(st.OPEN_DATE, 'YYYYMMDD')) AS FACT_SUPPORT_METRICS_ID,
    st.OPEN_DATE AS DATE_KEY,
    st.USER_ID AS USER_KEY,
    CONCAT(st.TICKET_TYPE, '_', st.PRIORITY_LEVEL) AS SUPPORT_CATEGORY_KEY,
    st.OPEN_DATE AS TICKET_DATE,
    COALESCE(st.RESOLUTION_TIME_HOURS, 0) AS RESOLUTION_TIME_HOURS,
    st.TICKET_TYPE,
    st.PRIORITY_LEVEL,
    st.RESOLUTION_STATUS,
    CASE WHEN st.RESOLUTION_TIME_HOURS <= 4 THEN TRUE ELSE FALSE END AS FIRST_CONTACT_RESOLUTION_FLAG,
    CASE 
        WHEN st.PRIORITY_LEVEL = 'Critical' AND st.RESOLUTION_TIME_HOURS > 4 THEN TRUE
        WHEN st.PRIORITY_LEVEL = 'High' AND st.RESOLUTION_TIME_HOURS > 24 THEN TRUE
        WHEN st.PRIORITY_LEVEL = 'Medium' AND st.RESOLUTION_TIME_HOURS > 72 THEN TRUE
        WHEN st.PRIORITY_LEVEL = 'Low' AND st.RESOLUTION_TIME_HOURS > 168 THEN TRUE
        ELSE FALSE
    END AS ESCALATION_FLAG,
    u.PLAN_TYPE AS CUSTOMER_PLAN_TYPE,
    -- Generate satisfaction score based on resolution time and priority
    CASE 
        WHEN st.RESOLUTION_TIME_HOURS <= 2 THEN 5
        WHEN st.RESOLUTION_TIME_HOURS <= 8 THEN 4
        WHEN st.RESOLUTION_TIME_HOURS <= 24 THEN 3
        WHEN st.RESOLUTION_TIME_HOURS <= 72 THEN 2
        ELSE 1
    END AS SATISFACTION_SCORE,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SILVER_LAYER' AS SOURCE_SYSTEM
FROM SILVER.SI_SUPPORT_TICKETS st
LEFT JOIN SILVER.SI_USERS u ON st.USER_ID = u.USER_ID
WHERE st.DATA_QUALITY_SCORE >= 0.8
  AND st.RESOLUTION_STATUS IN ('Resolved', 'Closed');
```

#### 2.2 SLA Compliance and Performance Metrics

**Rationale:** Calculate SLA compliance metrics and performance indicators for support operations analysis.

**SQL Example:**
```sql
-- SLA Compliance Calculation
WITH sla_targets AS (
    SELECT 
        'Critical' as priority, 4 as sla_hours
    UNION ALL
    SELECT 'High', 24
    UNION ALL  
    SELECT 'Medium', 72
    UNION ALL
    SELECT 'Low', 168
),
support_metrics AS (
    SELECT 
        st.*,
        sla.sla_hours,
        CASE WHEN st.RESOLUTION_TIME_HOURS <= sla.sla_hours THEN 1 ELSE 0 END AS sla_met_flag,
        CASE WHEN st.RESOLUTION_TIME_HOURS <= sla.sla_hours THEN 'MET' ELSE 'BREACHED' END AS sla_status
    FROM SILVER.SI_SUPPORT_TICKETS st
    LEFT JOIN sla_targets sla ON st.PRIORITY_LEVEL = sla.priority
)
SELECT 
    TICKET_ID,
    PRIORITY_LEVEL,
    RESOLUTION_TIME_HOURS,
    SLA_HOURS,
    SLA_STATUS,
    SLA_MET_FLAG,
    -- Performance Score (0-100)
    CASE 
        WHEN RESOLUTION_TIME_HOURS <= (SLA_HOURS * 0.5) THEN 100
        WHEN RESOLUTION_TIME_HOURS <= (SLA_HOURS * 0.75) THEN 85
        WHEN RESOLUTION_TIME_HOURS <= SLA_HOURS THEN 70
        WHEN RESOLUTION_TIME_HOURS <= (SLA_HOURS * 1.5) THEN 50
        ELSE 25
    END AS PERFORMANCE_SCORE
FROM support_metrics;
```

### 3. Go_Fact_Revenue_Events Transformation Rules

#### 3.1 Revenue Fact Generation with Currency Standardization

**Rationale:** Standardize all revenue data to USD for consistent financial analysis and ensure proper revenue recognition rules.

**SQL Example:**
```sql
INSERT INTO GOLD.Go_Fact_Revenue_Events (
    FACT_REVENUE_EVENTS_ID,
    DATE_KEY,
    USER_KEY,
    LICENSE_KEY,
    TRANSACTION_DATE,
    TRANSACTION_AMOUNT_USD,
    ORIGINAL_AMOUNT,
    CURRENCY_CODE,
    EVENT_TYPE,
    PAYMENT_METHOD,
    LICENSE_TYPE,
    CUSTOMER_PLAN_TYPE,
    TRANSACTION_STATUS,
    MRR_IMPACT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('FACT_REV_', be.EVENT_ID, '_', TO_CHAR(be.TRANSACTION_DATE, 'YYYYMMDD')) AS FACT_REVENUE_EVENTS_ID,
    be.TRANSACTION_DATE AS DATE_KEY,
    be.USER_ID AS USER_KEY,
    COALESCE(l.LICENSE_TYPE, 'UNKNOWN') AS LICENSE_KEY,
    be.TRANSACTION_DATE,
    -- Currency conversion to USD (simplified - in practice, use exchange rate table)
    CASE 
        WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
        WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
        WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
        ELSE be.TRANSACTION_AMOUNT -- Default to original if unknown
    END AS TRANSACTION_AMOUNT_USD,
    be.TRANSACTION_AMOUNT AS ORIGINAL_AMOUNT,
    be.CURRENCY_CODE,
    be.EVENT_TYPE,
    be.PAYMENT_METHOD,
    COALESCE(l.LICENSE_TYPE, 'UNKNOWN') AS LICENSE_TYPE,
    u.PLAN_TYPE AS CUSTOMER_PLAN_TYPE,
    be.TRANSACTION_STATUS,
    -- Calculate MRR Impact
    CASE 
        WHEN be.EVENT_TYPE IN ('Subscription', 'Upgrade') THEN 
            CASE WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
                 WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
                 WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
                 ELSE be.TRANSACTION_AMOUNT END
        WHEN be.EVENT_TYPE = 'Downgrade' THEN 
            -1 * CASE WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
                      WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
                      WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
                      ELSE be.TRANSACTION_AMOUNT END
        WHEN be.EVENT_TYPE = 'Refund' THEN 
            -1 * CASE WHEN be.CURRENCY_CODE = 'USD' THEN be.TRANSACTION_AMOUNT
                      WHEN be.CURRENCY_CODE = 'EUR' THEN be.TRANSACTION_AMOUNT * 1.1
                      WHEN be.CURRENCY_CODE = 'GBP' THEN be.TRANSACTION_AMOUNT * 1.25
                      ELSE be.TRANSACTION_AMOUNT END
        ELSE 0
    END AS MRR_IMPACT,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SILVER_LAYER' AS SOURCE_SYSTEM
FROM SILVER.SI_BILLING_EVENTS be
LEFT JOIN SILVER.SI_USERS u ON be.USER_ID = u.USER_ID
LEFT JOIN SILVER.SI_LICENSES l ON be.USER_ID = l.ASSIGNED_TO_USER_ID 
    AND be.TRANSACTION_DATE BETWEEN l.START_DATE AND COALESCE(l.END_DATE, '2099-12-31')
WHERE be.DATA_QUALITY_SCORE >= 0.8
  AND be.TRANSACTION_STATUS = 'Completed';
```

#### 3.2 Revenue Recognition and Cohort Analysis

**Rationale:** Implement proper revenue recognition rules and enable cohort analysis for customer lifetime value calculations.

**SQL Example:**
```sql
-- Revenue Recognition with Customer Cohorts
WITH customer_cohorts AS (
    SELECT 
        USER_ID,
        MIN(REGISTRATION_DATE) AS COHORT_MONTH,
        PLAN_TYPE AS INITIAL_PLAN
    FROM SILVER.SI_USERS
    GROUP BY USER_ID, PLAN_TYPE
),
revenue_with_cohorts AS (
    SELECT 
        re.*,
        cc.COHORT_MONTH,
        cc.INITIAL_PLAN,
        DATEDIFF('month', cc.COHORT_MONTH, re.TRANSACTION_DATE) AS MONTHS_SINCE_ACQUISITION,
        -- Customer Lifetime Value calculation
        SUM(re.TRANSACTION_AMOUNT_USD) OVER (
            PARTITION BY re.USER_KEY 
            ORDER BY re.TRANSACTION_DATE 
            ROWS UNBOUNDED PRECEDING
        ) AS CUMULATIVE_CLV
    FROM GOLD.Go_Fact_Revenue_Events re
    LEFT JOIN customer_cohorts cc ON re.USER_KEY = cc.USER_ID
)
SELECT 
    *,
    -- Revenue Type Classification
    CASE 
        WHEN MONTHS_SINCE_ACQUISITION = 0 THEN 'NEW_CUSTOMER_REVENUE'
        WHEN EVENT_TYPE = 'Upgrade' THEN 'EXPANSION_REVENUE'
        WHEN EVENT_TYPE = 'Subscription' AND MONTHS_SINCE_ACQUISITION > 0 THEN 'RENEWAL_REVENUE'
        WHEN EVENT_TYPE IN ('Downgrade', 'Refund') THEN 'CONTRACTION_REVENUE'
        ELSE 'OTHER_REVENUE'
    END AS REVENUE_TYPE
FROM revenue_with_cohorts;
```

### 4. Go_Fact_Feature_Usage Transformation Rules

#### 4.1 Feature Usage Fact Generation with Adoption Metrics

**Rationale:** Transform feature usage data into analytical facts with adoption metrics and usage patterns for product analytics.

**SQL Example:**
```sql
INSERT INTO GOLD.Go_Fact_Feature_Usage (
    FACT_FEATURE_USAGE_ID,
    DATE_KEY,
    USER_KEY,
    FEATURE_KEY,
    USAGE_DATE,
    FEATURE_NAME,
    FEATURE_CATEGORY,
    USAGE_COUNT,
    USAGE_DURATION_MINUTES,
    MEETING_TYPE,
    USER_PLAN_TYPE,
    PARTICIPANT_COUNT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('FACT_FEAT_', fu.USAGE_ID, '_', TO_CHAR(fu.USAGE_DATE, 'YYYYMMDD')) AS FACT_FEATURE_USAGE_ID,
    fu.USAGE_DATE AS DATE_KEY,
    m.HOST_ID AS USER_KEY,
    UPPER(REPLACE(fu.FEATURE_NAME, ' ', '_')) AS FEATURE_KEY,
    fu.USAGE_DATE,
    fu.FEATURE_NAME,
    fu.FEATURE_CATEGORY,
    fu.USAGE_COUNT,
    COALESCE(fu.USAGE_DURATION, 0) AS USAGE_DURATION_MINUTES,
    m.MEETING_TYPE,
    u.PLAN_TYPE AS USER_PLAN_TYPE,
    COALESCE(m.PARTICIPANT_COUNT, 0) AS PARTICIPANT_COUNT,
    CURRENT_DATE() AS LOAD_DATE,
    CURRENT_DATE() AS UPDATE_DATE,
    'SILVER_LAYER' AS SOURCE_SYSTEM
FROM SILVER.SI_FEATURE_USAGE fu
LEFT JOIN SILVER.SI_MEETINGS m ON fu.MEETING_ID = m.MEETING_ID
LEFT JOIN SILVER.SI_USERS u ON m.HOST_ID = u.USER_ID
WHERE fu.DATA_QUALITY_SCORE >= 0.8
  AND fu.USAGE_COUNT > 0;
```

#### 4.2 Feature Adoption and Usage Pattern Analysis

**Rationale:** Calculate feature adoption rates and usage patterns to support product development and user engagement strategies.

**SQL Example:**
```sql
-- Feature Adoption Analysis
WITH feature_adoption AS (
    SELECT 
        FEATURE_NAME,
        FEATURE_CATEGORY,
        COUNT(DISTINCT USER_KEY) AS UNIQUE_USERS,
        COUNT(*) AS TOTAL_USAGE_EVENTS,
        SUM(USAGE_COUNT) AS TOTAL_USAGE_COUNT,
        AVG(USAGE_DURATION_MINUTES) AS AVG_USAGE_DURATION,
        -- Calculate adoption rate
        COUNT(DISTINCT USER_KEY) * 100.0 / (
            SELECT COUNT(DISTINCT USER_ID) 
            FROM SILVER.SI_USERS 
            WHERE ACCOUNT_STATUS = 'Active'
        ) AS ADOPTION_RATE_PERCENT
    FROM GOLD.Go_Fact_Feature_Usage
    WHERE USAGE_DATE >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY FEATURE_NAME, FEATURE_CATEGORY
),
feature_trends AS (
    SELECT 
        FEATURE_NAME,
        DATE_TRUNC('week', USAGE_DATE) AS WEEK_START,
        COUNT(DISTINCT USER_KEY) AS WEEKLY_USERS,
        SUM(USAGE_COUNT) AS WEEKLY_USAGE
    FROM GOLD.Go_Fact_Feature_Usage
    WHERE USAGE_DATE >= DATEADD('day', -90, CURRENT_DATE())
    GROUP BY FEATURE_NAME, DATE_TRUNC('week', USAGE_DATE)
)
SELECT 
    fa.*,
    -- Feature maturity classification
    CASE 
        WHEN fa.ADOPTION_RATE_PERCENT >= 50 THEN 'MATURE'
        WHEN fa.ADOPTION_RATE_PERCENT >= 20 THEN 'GROWING'
        WHEN fa.ADOPTION_RATE_PERCENT >= 5 THEN 'EMERGING'
        ELSE 'EXPERIMENTAL'
    END AS FEATURE_MATURITY,
    -- Usage intensity
    CASE 
        WHEN fa.AVG_USAGE_DURATION >= 10 THEN 'HIGH_INTENSITY'
        WHEN fa.AVG_USAGE_DURATION >= 3 THEN 'MEDIUM_INTENSITY'
        ELSE 'LOW_INTENSITY'
    END AS USAGE_INTENSITY
FROM feature_adoption fa;
```

## Data Quality and Validation Framework

### 5. Cross-Fact Table Validation Rules

#### 5.1 Referential Integrity Validation

**Rationale:** Ensure data consistency across fact tables and validate foreign key relationships.

**SQL Example:**
```sql
-- Cross-Fact Validation Query
WITH fact_user_validation AS (
    SELECT 'Go_Fact_Meeting_Activity' as table_name, USER_KEY, COUNT(*) as record_count
    FROM GOLD.Go_Fact_Meeting_Activity
    GROUP BY USER_KEY
    UNION ALL
    SELECT 'Go_Fact_Support_Metrics', USER_KEY, COUNT(*)
    FROM GOLD.Go_Fact_Support_Metrics
    GROUP BY USER_KEY
    UNION ALL
    SELECT 'Go_Fact_Revenue_Events', USER_KEY, COUNT(*)
    FROM GOLD.Go_Fact_Revenue_Events
    GROUP BY USER_KEY
    UNION ALL
    SELECT 'Go_Fact_Feature_Usage', USER_KEY, COUNT(*)
    FROM GOLD.Go_Fact_Feature_Usage
    GROUP BY USER_KEY
),
orphaned_records AS (
    SELECT 
        fv.table_name,
        fv.USER_KEY,
        fv.record_count
    FROM fact_user_validation fv
    LEFT JOIN GOLD.Go_Dim_User du ON fv.USER_KEY = du.USER_BUSINESS_KEY
    WHERE du.USER_BUSINESS_KEY IS NULL
)
SELECT 
    table_name,
    COUNT(*) as orphaned_user_keys,
    SUM(record_count) as affected_records
FROM orphaned_records
GROUP BY table_name;
```

#### 5.2 Business Rule Validation

**Rationale:** Validate business logic and constraints across fact tables to ensure data integrity.

**SQL Example:**
```sql
-- Business Rule Validation
WITH validation_results AS (
    -- Rule 1: Meeting duration should be positive
    SELECT 
        'MEETING_DURATION_POSITIVE' as rule_name,
        COUNT(*) as violation_count
    FROM GOLD.Go_Fact_Meeting_Activity
    WHERE MEETING_DURATION_MINUTES <= 0
    
    UNION ALL
    
    -- Rule 2: Revenue amounts should be positive for subscriptions
    SELECT 
        'REVENUE_POSITIVE_FOR_SUBSCRIPTIONS',
        COUNT(*)
    FROM GOLD.Go_Fact_Revenue_Events
    WHERE EVENT_TYPE = 'Subscription' AND TRANSACTION_AMOUNT_USD <= 0
    
    UNION ALL
    
    -- Rule 3: Support resolution time should be positive
    SELECT 
        'SUPPORT_RESOLUTION_TIME_POSITIVE',
        COUNT(*)
    FROM GOLD.Go_Fact_Support_Metrics
    WHERE RESOLUTION_TIME_HOURS < 0
    
    UNION ALL
    
    -- Rule 4: Feature usage count should be positive
    SELECT 
        'FEATURE_USAGE_COUNT_POSITIVE',
        COUNT(*)
    FROM GOLD.Go_Fact_Feature_Usage
    WHERE USAGE_COUNT <= 0
)
SELECT 
    rule_name,
    violation_count,
    CASE WHEN violation_count = 0 THEN 'PASS' ELSE 'FAIL' END as validation_status
FROM validation_results;
```

## Performance Optimization Guidelines

### 6. Clustering and Partitioning Recommendations

#### 6.1 Clustering Key Implementation

**Rationale:** Optimize query performance by implementing appropriate clustering keys based on common query patterns.

**SQL Example:**
```sql
-- Clustering recommendations for fact tables
ALTER TABLE GOLD.Go_Fact_Meeting_Activity 
CLUSTER BY (DATE_KEY, USER_KEY);

ALTER TABLE GOLD.Go_Fact_Support_Metrics 
CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY);

ALTER TABLE GOLD.Go_Fact_Revenue_Events 
CLUSTER BY (DATE_KEY, LICENSE_KEY);

ALTER TABLE GOLD.Go_Fact_Feature_Usage 
CLUSTER BY (DATE_KEY, FEATURE_KEY);
```

#### 6.2 Incremental Loading Strategy

**Rationale:** Implement efficient incremental loading to minimize processing time and resource usage.

**SQL Example:**
```sql
-- Incremental Loading Pattern
MERGE INTO GOLD.Go_Fact_Meeting_Activity AS target
USING (
    SELECT 
        CONCAT('FACT_MEET_', m.MEETING_ID, '_', TO_CHAR(m.START_TIME, 'YYYYMMDD')) AS FACT_MEETING_ACTIVITY_ID,
        DATE(m.START_TIME) AS DATE_KEY,
        m.HOST_ID AS USER_KEY,
        -- ... other columns
    FROM SILVER.SI_MEETINGS m
    WHERE m.UPDATE_DATE >= DATEADD('day', -1, CURRENT_DATE())
      AND m.DATA_QUALITY_SCORE >= 0.8
) AS source
ON target.FACT_MEETING_ACTIVITY_ID = source.FACT_MEETING_ACTIVITY_ID
WHEN MATCHED THEN
    UPDATE SET 
        MEETING_DURATION_MINUTES = source.MEETING_DURATION_MINUTES,
        PARTICIPANT_COUNT = source.PARTICIPANT_COUNT,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (
        FACT_MEETING_ACTIVITY_ID,
        DATE_KEY,
        USER_KEY,
        -- ... other columns
    )
    VALUES (
        source.FACT_MEETING_ACTIVITY_ID,
        source.DATE_KEY,
        source.USER_KEY,
        -- ... other values
    );
```

## Monitoring and Alerting

### 7. Data Quality Monitoring

#### 7.1 Automated Quality Checks

**Rationale:** Implement automated monitoring to detect data quality issues early and ensure reliable fact table data.

**SQL Example:**
```sql
-- Data Quality Monitoring Dashboard
WITH quality_metrics AS (
    SELECT 
        'Go_Fact_Meeting_Activity' as table_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN MEETING_DURATION_MINUTES > 0 THEN 1 END) as valid_duration_records,
        COUNT(CASE WHEN USER_KEY IS NOT NULL THEN 1 END) as records_with_user_key,
        MAX(LOAD_DATE) as last_load_date
    FROM GOLD.Go_Fact_Meeting_Activity
    WHERE DATE_KEY >= DATEADD('day', -7, CURRENT_DATE())
    
    UNION ALL
    
    SELECT 
        'Go_Fact_Revenue_Events',
        COUNT(*),
        COUNT(CASE WHEN TRANSACTION_AMOUNT_USD > 0 THEN 1 END),
        COUNT(CASE WHEN USER_KEY IS NOT NULL THEN 1 END),
        MAX(LOAD_DATE)
    FROM GOLD.Go_Fact_Revenue_Events
    WHERE DATE_KEY >= DATEADD('day', -7, CURRENT_DATE())
)
SELECT 
    table_name,
    total_records,
    ROUND((valid_duration_records * 100.0 / total_records), 2) as data_quality_percent,
    ROUND((records_with_user_key * 100.0 / total_records), 2) as completeness_percent,
    last_load_date,
    CASE 
        WHEN last_load_date < DATEADD('day', -1, CURRENT_DATE()) THEN 'STALE_DATA'
        WHEN (valid_duration_records * 100.0 / total_records) < 95 THEN 'QUALITY_ISSUE'
        ELSE 'HEALTHY'
    END as status
FROM quality_metrics;
```

## Conclusion

These transformation rules provide a comprehensive framework for converting Silver layer data into Gold layer fact tables optimized for analytics and reporting. The rules ensure:

1. **Data Quality**: Robust validation and cleansing processes
2. **Performance**: Optimized clustering and incremental loading strategies
3. **Consistency**: Standardized transformation patterns across all fact tables
4. **Scalability**: Efficient processing methods that can handle growing data volumes
5. **Monitoring**: Automated quality checks and alerting mechanisms

Implementing these rules will result in reliable, well-structured fact tables that support accurate business intelligence and analytics for the Zoom Platform Analytics System.