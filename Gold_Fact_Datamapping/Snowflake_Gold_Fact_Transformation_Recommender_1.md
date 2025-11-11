_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive transformation rules for Fact tables in Gold layer supporting dimensional modeling and BI integration
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Snowflake Gold Fact Transformation Recommender

## Transformation Rules for Fact Tables

### 1. GO_FACT_MEETING_ACTIVITY Transformation Rules

#### 1.1 Data Source Integration and Joins

**Rationale**: Combine meeting data from multiple Silver layer tables to create comprehensive meeting activity facts with proper dimensional relationships for BI integration.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (
    USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY,
    MEETING_DATE, MEETING_TOPIC, START_TIME, END_TIME, DURATION_MINUTES,
    PARTICIPANT_COUNT, TOTAL_JOIN_TIME_MINUTES, AVERAGE_PARTICIPATION_MINUTES,
    FEATURES_USED_COUNT, SCREEN_SHARE_USAGE_COUNT, RECORDING_USAGE_COUNT,
    CHAT_USAGE_COUNT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    du.USER_KEY,
    dm.MEETING_KEY,
    dd.DATE_KEY,
    df.FEATURE_KEY,
    DATE(sm.START_TIME) as MEETING_DATE,
    sm.MEETING_TOPIC,
    sm.START_TIME,
    sm.END_TIME,
    sm.DURATION_MINUTES,
    COUNT(DISTINCT sp.USER_ID) as PARTICIPANT_COUNT,
    SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) as TOTAL_JOIN_TIME_MINUTES,
    AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME)) as AVERAGE_PARTICIPATION_MINUTES,
    COUNT(DISTINCT sf.FEATURE_NAME) as FEATURES_USED_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Screen Share' THEN sf.USAGE_COUNT ELSE 0 END) as SCREEN_SHARE_USAGE_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Recording' THEN sf.USAGE_COUNT ELSE 0 END) as RECORDING_USAGE_COUNT,
    SUM(CASE WHEN sf.FEATURE_NAME = 'Chat' THEN sf.USAGE_COUNT ELSE 0 END) as CHAT_USAGE_COUNT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS sm
JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
LEFT JOIN SILVER.SI_PARTICIPANTS sp ON sm.MEETING_ID = sp.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
LEFT JOIN GOLD.GO_DIM_FEATURE df ON sf.FEATURE_NAME = df.FEATURE_NAME
WHERE sm.VALIDATION_STATUS = 'PASSED'
GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, df.FEATURE_KEY, 
         sm.MEETING_TOPIC, sm.START_TIME, sm.END_TIME, sm.DURATION_MINUTES;
```

#### 1.2 Meeting Quality Score Calculation

**Rationale**: Calculate comprehensive meeting quality scores based on participant engagement, feature usage, and technical performance metrics.

**SQL Example**:
```sql
UPDATE GOLD.GO_FACT_MEETING_ACTIVITY 
SET MEETING_QUALITY_SCORE = (
    CASE 
        WHEN PARTICIPANT_COUNT >= 5 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.8) THEN 5.0
        WHEN PARTICIPANT_COUNT >= 3 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.6) THEN 4.0
        WHEN PARTICIPANT_COUNT >= 2 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.4) THEN 3.0
        WHEN PARTICIPANT_COUNT >= 1 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.2) THEN 2.0
        ELSE 1.0
    END
),
AUDIO_QUALITY_SCORE = (
    CASE 
        WHEN CONNECTION_ISSUES_COUNT = 0 THEN 5.0
        WHEN CONNECTION_ISSUES_COUNT <= 2 THEN 4.0
        WHEN CONNECTION_ISSUES_COUNT <= 5 THEN 3.0
        WHEN CONNECTION_ISSUES_COUNT <= 10 THEN 2.0
        ELSE 1.0
    END
)
WHERE MEETING_QUALITY_SCORE IS NULL;
```

#### 1.3 Meeting Categorization and Enrichment

**Rationale**: Enrich meeting facts with calculated fields for business analysis including meeting categories, engagement metrics, and performance indicators.

**SQL Example**:
```sql
UPDATE GOLD.GO_FACT_MEETING_ACTIVITY 
SET 
    PEAK_CONCURRENT_PARTICIPANTS = (
        SELECT MAX(concurrent_count)
        FROM (
            SELECT COUNT(*) as concurrent_count
            FROM SILVER.SI_PARTICIPANTS sp2
            WHERE sp2.MEETING_ID = GO_FACT_MEETING_ACTIVITY.MEETING_KEY
            AND sp2.JOIN_TIME <= sp2.LEAVE_TIME
            GROUP BY sp2.JOIN_TIME
        )
    ),
    LATE_JOINERS_COUNT = (
        SELECT COUNT(*)
        FROM SILVER.SI_PARTICIPANTS sp3
        WHERE sp3.MEETING_ID = GO_FACT_MEETING_ACTIVITY.MEETING_KEY
        AND sp3.JOIN_TIME > DATEADD('minute', 5, GO_FACT_MEETING_ACTIVITY.START_TIME)
    ),
    EARLY_LEAVERS_COUNT = (
        SELECT COUNT(*)
        FROM SILVER.SI_PARTICIPANTS sp4
        WHERE sp4.MEETING_ID = GO_FACT_MEETING_ACTIVITY.MEETING_KEY
        AND sp4.LEAVE_TIME < DATEADD('minute', -5, GO_FACT_MEETING_ACTIVITY.END_TIME)
    )
WHERE PEAK_CONCURRENT_PARTICIPANTS IS NULL;
```

### 2. GO_FACT_SUPPORT_ACTIVITY Transformation Rules

#### 2.1 Support Ticket Metrics Calculation

**Rationale**: Transform support ticket data into comprehensive metrics including resolution times, SLA compliance, and customer satisfaction tracking with dimensional relationships.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_SUPPORT_ACTIVITY (
    USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY,
    TICKET_OPEN_DATE, TICKET_CLOSE_DATE, TICKET_TYPE, RESOLUTION_STATUS,
    PRIORITY_LEVEL, RESOLUTION_TIME_HOURS, FIRST_CONTACT_RESOLUTION_FLAG,
    SLA_MET, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    du.USER_KEY,
    dd.DATE_KEY,
    dsc.SUPPORT_CATEGORY_KEY,
    st.OPEN_DATE as TICKET_OPEN_DATE,
    CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
         THEN st.OPEN_DATE + INTERVAL '1 DAY' -- Placeholder for actual close date
         ELSE NULL END as TICKET_CLOSE_DATE,
    st.TICKET_TYPE,
    st.RESOLUTION_STATUS,
    COALESCE(dsc.PRIORITY_LEVEL, 'Medium') as PRIORITY_LEVEL,
    CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
         THEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY')
         ELSE NULL END as RESOLUTION_TIME_HOURS,
    FALSE as FIRST_CONTACT_RESOLUTION_FLAG, -- To be updated based on interaction count
    CASE WHEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY') <= dsc.SLA_TARGET_HOURS
         THEN TRUE ELSE FALSE END as SLA_MET,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_SUPPORT_TICKETS st
JOIN GOLD.GO_DIM_USER du ON st.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
JOIN GOLD.GO_DIM_DATE dd ON st.OPEN_DATE = dd.DATE_KEY
JOIN GOLD.GO_DIM_SUPPORT_CATEGORY dsc ON st.TICKET_TYPE = dsc.SUPPORT_CATEGORY
WHERE st.VALIDATION_STATUS = 'PASSED';
```

#### 2.2 SLA Compliance and Performance Metrics

**Rationale**: Calculate advanced support metrics including SLA compliance, escalation tracking, and customer satisfaction correlation.

**SQL Example**:
```sql
UPDATE GOLD.GO_FACT_SUPPORT_ACTIVITY 
SET 
    SLA_BREACH_HOURS = CASE 
        WHEN RESOLUTION_TIME_HOURS > (
            SELECT SLA_TARGET_HOURS 
            FROM GOLD.GO_DIM_SUPPORT_CATEGORY dsc 
            WHERE dsc.SUPPORT_CATEGORY_KEY = GO_FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY
        ) THEN RESOLUTION_TIME_HOURS - (
            SELECT SLA_TARGET_HOURS 
            FROM GOLD.GO_DIM_SUPPORT_CATEGORY dsc 
            WHERE dsc.SUPPORT_CATEGORY_KEY = GO_FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY
        )
        ELSE 0
    END,
    CUSTOMER_SATISFACTION_SCORE = (
        CASE 
            WHEN RESOLUTION_TIME_HOURS <= 4 AND FIRST_CONTACT_RESOLUTION_FLAG = TRUE THEN 5.0
            WHEN RESOLUTION_TIME_HOURS <= 24 AND ESCALATION_COUNT = 0 THEN 4.0
            WHEN RESOLUTION_TIME_HOURS <= 72 AND ESCALATION_COUNT <= 1 THEN 3.0
            WHEN RESOLUTION_TIME_HOURS <= 168 THEN 2.0
            ELSE 1.0
        END
    ),
    PREVENTABLE_ISSUE = (
        CASE 
            WHEN TICKET_TYPE IN ('Password Reset', 'Account Lockout', 'Basic Setup') THEN TRUE
            ELSE FALSE
        END
    )
WHERE RESOLUTION_TIME_HOURS IS NOT NULL;
```

### 3. GO_FACT_REVENUE_ACTIVITY Transformation Rules

#### 3.1 Revenue Event Processing and Currency Standardization

**Rationale**: Transform billing events into comprehensive revenue facts with currency standardization, MRR/ARR calculations, and dimensional relationships for financial analysis.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_REVENUE_ACTIVITY (
    USER_KEY, LICENSE_KEY, DATE_KEY,
    TRANSACTION_DATE, EVENT_TYPE, AMOUNT, CURRENCY,
    SUBSCRIPTION_REVENUE_AMOUNT, ONE_TIME_REVENUE_AMOUNT,
    NET_REVENUE_AMOUNT, USD_AMOUNT, MRR_IMPACT, ARR_IMPACT,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    du.USER_KEY,
    dl.LICENSE_KEY,
    dd.DATE_KEY,
    be.EVENT_DATE as TRANSACTION_DATE,
    be.EVENT_TYPE,
    be.AMOUNT,
    'USD' as CURRENCY, -- Assuming standardized currency
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT ELSE 0 END as SUBSCRIPTION_REVENUE_AMOUNT,
    CASE WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
         THEN be.AMOUNT ELSE 0 END as ONE_TIME_REVENUE_AMOUNT,
    CASE WHEN be.EVENT_TYPE = 'Refund' 
         THEN -be.AMOUNT ELSE be.AMOUNT END as NET_REVENUE_AMOUNT,
    be.AMOUNT as USD_AMOUNT, -- Assuming already in USD
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT / 12 ELSE 0 END as MRR_IMPACT,
    CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
         THEN be.AMOUNT ELSE 0 END as ARR_IMPACT,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_BILLING_EVENTS be
JOIN GOLD.GO_DIM_USER du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
JOIN GOLD.GO_DIM_DATE dd ON be.EVENT_DATE = dd.DATE_KEY
LEFT JOIN SILVER.SI_LICENSES sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
LEFT JOIN GOLD.GO_DIM_LICENSE dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
WHERE be.VALIDATION_STATUS = 'PASSED';
```

#### 3.2 Customer Lifetime Value and Churn Risk Calculation

**Rationale**: Calculate advanced revenue metrics including customer lifetime value, churn risk scoring, and revenue attribution for comprehensive financial analysis.

**SQL Example**:
```sql
UPDATE GOLD.GO_FACT_REVENUE_ACTIVITY 
SET 
    CUSTOMER_LIFETIME_VALUE = (
        SELECT SUM(NET_REVENUE_AMOUNT)
        FROM GOLD.GO_FACT_REVENUE_ACTIVITY fra2
        WHERE fra2.USER_KEY = GO_FACT_REVENUE_ACTIVITY.USER_KEY
        AND fra2.TRANSACTION_DATE <= GO_FACT_REVENUE_ACTIVITY.TRANSACTION_DATE
    ),
    CHURN_RISK_SCORE = (
        CASE 
            WHEN EVENT_TYPE = 'Downgrade' THEN 4.0
            WHEN EVENT_TYPE = 'Refund' THEN 3.5
            WHEN DATEDIFF('day', TRANSACTION_DATE, CURRENT_DATE()) > 90 
                 AND EVENT_TYPE = 'Subscription' THEN 3.0
            WHEN NET_REVENUE_AMOUNT < 0 THEN 2.5
            ELSE 1.0
        END
    ),
    PAYMENT_STATUS = (
        CASE 
            WHEN EVENT_TYPE = 'Refund' THEN 'Refunded'
            WHEN NET_REVENUE_AMOUNT > 0 THEN 'Successful'
            WHEN NET_REVENUE_AMOUNT = 0 THEN 'Pending'
            ELSE 'Failed'
        END
    )
WHERE CUSTOMER_LIFETIME_VALUE IS NULL;
```

### 4. GO_FACT_FEATURE_USAGE Transformation Rules

#### 4.1 Feature Usage Metrics and Adoption Scoring

**Rationale**: Transform feature usage data into comprehensive metrics including adoption scores, usage patterns, and performance indicators with dimensional relationships.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_FACT_FEATURE_USAGE (
    DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY,
    USAGE_DATE, USAGE_TIMESTAMP, FEATURE_NAME, USAGE_COUNT,
    USAGE_DURATION_MINUTES, FEATURE_ADOPTION_SCORE, SUCCESS_RATE,
    LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    dd.DATE_KEY,
    df.FEATURE_KEY,
    du.USER_KEY,
    dm.MEETING_KEY,
    fu.USAGE_DATE,
    fu.USAGE_DATE::TIMESTAMP_NTZ as USAGE_TIMESTAMP,
    fu.FEATURE_NAME,
    fu.USAGE_COUNT,
    COALESCE(sm.DURATION_MINUTES, 0) as USAGE_DURATION_MINUTES,
    CASE 
        WHEN fu.USAGE_COUNT >= 10 THEN 5.0
        WHEN fu.USAGE_COUNT >= 5 THEN 4.0
        WHEN fu.USAGE_COUNT >= 3 THEN 3.0
        WHEN fu.USAGE_COUNT >= 1 THEN 2.0
        ELSE 1.0
    END as FEATURE_ADOPTION_SCORE,
    CASE 
        WHEN fu.USAGE_COUNT > 0 THEN 100.0
        ELSE 0.0
    END as SUCCESS_RATE,
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_FEATURE_USAGE fu
JOIN GOLD.GO_DIM_DATE dd ON fu.USAGE_DATE = dd.DATE_KEY
JOIN GOLD.GO_DIM_FEATURE df ON fu.FEATURE_NAME = df.FEATURE_NAME
LEFT JOIN SILVER.SI_MEETINGS sm ON fu.MEETING_ID = sm.MEETING_ID
LEFT JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
LEFT JOIN GOLD.GO_DIM_MEETING dm ON fu.MEETING_ID = dm.MEETING_KEY
WHERE fu.VALIDATION_STATUS = 'PASSED';
```

#### 4.2 Feature Performance and User Experience Metrics

**Rationale**: Calculate advanced feature metrics including performance scores, user experience ratings, and usage context analysis for product optimization.

**SQL Example**:
```sql
UPDATE GOLD.GO_FACT_FEATURE_USAGE 
SET 
    FEATURE_PERFORMANCE_SCORE = (
        CASE 
            WHEN ERROR_COUNT = 0 AND SUCCESS_RATE = 100.0 THEN 5.0
            WHEN ERROR_COUNT <= 1 AND SUCCESS_RATE >= 95.0 THEN 4.0
            WHEN ERROR_COUNT <= 3 AND SUCCESS_RATE >= 85.0 THEN 3.0
            WHEN ERROR_COUNT <= 5 AND SUCCESS_RATE >= 70.0 THEN 2.0
            ELSE 1.0
        END
    ),
    USER_EXPERIENCE_RATING = (
        CASE 
            WHEN FEATURE_ADOPTION_SCORE >= 4.0 AND FEATURE_PERFORMANCE_SCORE >= 4.0 THEN 5.0
            WHEN FEATURE_ADOPTION_SCORE >= 3.0 AND FEATURE_PERFORMANCE_SCORE >= 3.0 THEN 4.0
            WHEN FEATURE_ADOPTION_SCORE >= 2.0 AND FEATURE_PERFORMANCE_SCORE >= 2.0 THEN 3.0
            WHEN FEATURE_ADOPTION_SCORE >= 1.0 AND FEATURE_PERFORMANCE_SCORE >= 1.0 THEN 2.0
            ELSE 1.0
        END
    ),
    USAGE_CONTEXT = (
        CASE 
            WHEN USAGE_DURATION_MINUTES >= 60 THEN 'Extended Session'
            WHEN USAGE_DURATION_MINUTES >= 30 THEN 'Standard Session'
            WHEN USAGE_DURATION_MINUTES >= 15 THEN 'Short Session'
            WHEN USAGE_DURATION_MINUTES >= 5 THEN 'Brief Session'
            ELSE 'Quick Access'
        END
    )
WHERE FEATURE_PERFORMANCE_SCORE IS NULL;
```

### 5. Data Quality and Validation Rules

#### 5.1 Fact Table Data Quality Validation

**Rationale**: Implement comprehensive data quality checks to ensure fact table accuracy, completeness, and consistency before promoting to Gold layer.

**SQL Example**:
```sql
-- Data Quality Validation for Meeting Activity Facts
INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
    ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
    ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
    VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
)
SELECT 
    UUID_STRING() as ERROR_ID,
    CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
    'SILVER.SI_MEETINGS' as SOURCE_TABLE_NAME,
    'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
    'Data Integrity' as ERROR_TYPE,
    'Business Rule Violation' as ERROR_CATEGORY,
    'High' as ERROR_SEVERITY,
    'Meeting duration exceeds 24 hours: ' || DURATION_MINUTES || ' minutes' as ERROR_MESSAGE,
    'MEETING_DURATION_VALIDATION' as VALIDATION_RULE_NAME,
    CURRENT_DATE() as LOAD_DATE,
    'GOLD_FACT_VALIDATION' as SOURCE_SYSTEM
FROM GOLD.GO_FACT_MEETING_ACTIVITY
WHERE DURATION_MINUTES > 1440; -- 24 hours
```

#### 5.2 Foreign Key Relationship Validation

**Rationale**: Validate foreign key relationships between fact tables and dimension tables to ensure referential integrity for BI tool integration.

**SQL Example**:
```sql
-- Validate Foreign Key Relationships
INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
    ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
    ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
    VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
)
SELECT 
    UUID_STRING() as ERROR_ID,
    CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
    'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
    'GOLD.GO_DIM_USER' as TARGET_TABLE_NAME,
    'Referential Integrity' as ERROR_TYPE,
    'Missing Foreign Key' as ERROR_CATEGORY,
    'Critical' as ERROR_SEVERITY,
    'USER_KEY not found in dimension table: ' || USER_KEY as ERROR_MESSAGE,
    'FK_USER_KEY_VALIDATION' as VALIDATION_RULE_NAME,
    CURRENT_DATE() as LOAD_DATE,
    'GOLD_FACT_VALIDATION' as SOURCE_SYSTEM
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
LEFT JOIN GOLD.GO_DIM_USER du ON fma.USER_KEY = du.USER_KEY
WHERE du.USER_KEY IS NULL AND fma.USER_KEY IS NOT NULL;
```

### 6. Aggregation and Summary Table Rules

#### 6.1 Daily Usage Summary Aggregation

**Rationale**: Create daily aggregated metrics from fact tables to support high-level reporting and dashboard performance optimization.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_AGG_DAILY_USAGE_SUMMARY (
    DATE_KEY, SUMMARY_DATE, TOTAL_MEETINGS, TOTAL_MEETING_MINUTES,
    UNIQUE_HOSTS, UNIQUE_PARTICIPANTS, AVERAGE_MEETING_DURATION,
    AVERAGE_PARTICIPANTS_PER_MEETING, LOAD_DATE, SOURCE_SYSTEM
)
SELECT 
    DATE_KEY,
    MEETING_DATE as SUMMARY_DATE,
    COUNT(*) as TOTAL_MEETINGS,
    SUM(DURATION_MINUTES) as TOTAL_MEETING_MINUTES,
    COUNT(DISTINCT USER_KEY) as UNIQUE_HOSTS,
    SUM(PARTICIPANT_COUNT) as UNIQUE_PARTICIPANTS,
    AVG(DURATION_MINUTES) as AVERAGE_MEETING_DURATION,
    AVG(PARTICIPANT_COUNT) as AVERAGE_PARTICIPANTS_PER_MEETING,
    CURRENT_DATE() as LOAD_DATE,
    'GOLD_AGGREGATION_ETL' as SOURCE_SYSTEM
FROM GOLD.GO_FACT_MEETING_ACTIVITY
WHERE MEETING_DATE >= CURRENT_DATE() - INTERVAL '7 DAYS'
GROUP BY DATE_KEY, MEETING_DATE;
```

#### 6.2 Monthly Revenue Summary Aggregation

**Rationale**: Create monthly revenue aggregations with MRR/ARR calculations and license utilization metrics for financial reporting.

**SQL Example**:
```sql
INSERT INTO GOLD.GO_AGG_MONTHLY_REVENUE_SUMMARY (
    DATE_KEY, LICENSE_KEY, SUMMARY_MONTH, TOTAL_REVENUE,
    SUBSCRIPTION_REVENUE, ONE_TIME_REVENUE, NET_REVENUE,
    MONTHLY_RECURRING_REVENUE, LOAD_DATE, SOURCE_SYSTEM
)
SELECT 
    DATE_TRUNC('MONTH', TRANSACTION_DATE) as DATE_KEY,
    LICENSE_KEY,
    DATE_TRUNC('MONTH', TRANSACTION_DATE) as SUMMARY_MONTH,
    SUM(AMOUNT) as TOTAL_REVENUE,
    SUM(SUBSCRIPTION_REVENUE_AMOUNT) as SUBSCRIPTION_REVENUE,
    SUM(ONE_TIME_REVENUE_AMOUNT) as ONE_TIME_REVENUE,
    SUM(NET_REVENUE_AMOUNT) as NET_REVENUE,
    SUM(MRR_IMPACT) as MONTHLY_RECURRING_REVENUE,
    CURRENT_DATE() as LOAD_DATE,
    'GOLD_AGGREGATION_ETL' as SOURCE_SYSTEM
FROM GOLD.GO_FACT_REVENUE_ACTIVITY
WHERE TRANSACTION_DATE >= DATE_TRUNC('MONTH', CURRENT_DATE()) - INTERVAL '12 MONTHS'
GROUP BY DATE_TRUNC('MONTH', TRANSACTION_DATE), LICENSE_KEY;
```

### 7. Performance Optimization Rules

#### 7.1 Clustering and Partitioning Strategy

**Rationale**: Implement clustering keys on fact tables to optimize query performance for common analytical patterns and BI tool usage.

**SQL Example**:
```sql
-- Cluster fact tables by commonly used dimensions
ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY);
ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY);
ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY CLUSTER BY (DATE_KEY, USER_KEY, LICENSE_KEY);
ALTER TABLE GOLD.GO_FACT_FEATURE_USAGE CLUSTER BY (DATE_KEY, FEATURE_KEY, USER_KEY);

-- Create materialized views for frequently accessed aggregations
CREATE MATERIALIZED VIEW GOLD.MV_DAILY_MEETING_METRICS AS
SELECT 
    DATE_KEY,
    COUNT(*) as DAILY_MEETINGS,
    SUM(DURATION_MINUTES) as TOTAL_MINUTES,
    AVG(PARTICIPANT_COUNT) as AVG_PARTICIPANTS,
    AVG(MEETING_QUALITY_SCORE) as AVG_QUALITY_SCORE
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY DATE_KEY;
```

#### 7.2 Incremental Loading Strategy

**Rationale**: Implement incremental loading patterns to optimize ETL performance and reduce processing time for large fact tables.

**SQL Example**:
```sql
-- Incremental loading with change data capture
MERGE INTO GOLD.GO_FACT_MEETING_ACTIVITY AS target
USING (
    SELECT 
        du.USER_KEY,
        dm.MEETING_KEY,
        dd.DATE_KEY,
        sm.MEETING_TOPIC,
        sm.START_TIME,
        sm.END_TIME,
        sm.DURATION_MINUTES,
        sm.UPDATE_TIMESTAMP
    FROM SILVER.SI_MEETINGS sm
    JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
    JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
    WHERE sm.UPDATE_TIMESTAMP > (
        SELECT COALESCE(MAX(UPDATE_DATE), '1900-01-01')
        FROM GOLD.GO_FACT_MEETING_ACTIVITY
    )
) AS source
ON target.USER_KEY = source.USER_KEY 
   AND target.MEETING_KEY = source.MEETING_KEY 
   AND target.DATE_KEY = source.DATE_KEY
WHEN MATCHED THEN
    UPDATE SET 
        MEETING_TOPIC = source.MEETING_TOPIC,
        DURATION_MINUTES = source.DURATION_MINUTES,
        UPDATE_DATE = CURRENT_DATE()
WHEN NOT MATCHED THEN
    INSERT (USER_KEY, MEETING_KEY, DATE_KEY, MEETING_TOPIC, START_TIME, END_TIME, DURATION_MINUTES, LOAD_DATE, UPDATE_DATE)
    VALUES (source.USER_KEY, source.MEETING_KEY, source.DATE_KEY, source.MEETING_TOPIC, source.START_TIME, source.END_TIME, source.DURATION_MINUTES, CURRENT_DATE(), CURRENT_DATE());
```

### 8. Business Rule Implementation

#### 8.1 KPI Calculation Rules

**Rationale**: Implement standardized KPI calculations across fact tables to ensure consistent business metrics and reporting accuracy.

**SQL Example**:
```sql
-- Daily Active Users (DAU) Calculation
CREATE OR REPLACE VIEW GOLD.VW_DAILY_ACTIVE_USERS AS
SELECT 
    DATE_KEY,
    COUNT(DISTINCT USER_KEY) as DAILY_ACTIVE_USERS,
    COUNT(DISTINCT CASE WHEN DURATION_MINUTES >= 5 THEN USER_KEY END) as ENGAGED_DAILY_USERS,
    AVG(DURATION_MINUTES) as AVG_SESSION_DURATION
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY DATE_KEY;

-- Feature Adoption Rate Calculation
CREATE OR REPLACE VIEW GOLD.VW_FEATURE_ADOPTION_RATES AS
SELECT 
    f.FEATURE_KEY,
    f.FEATURE_NAME,
    COUNT(DISTINCT fu.USER_KEY) as USERS_USING_FEATURE,
    (
        SELECT COUNT(DISTINCT USER_KEY) 
        FROM GOLD.GO_FACT_MEETING_ACTIVITY 
        WHERE DATE_KEY = fu.DATE_KEY
    ) as TOTAL_ACTIVE_USERS,
    (COUNT(DISTINCT fu.USER_KEY) * 100.0) / (
        SELECT COUNT(DISTINCT USER_KEY) 
        FROM GOLD.GO_FACT_MEETING_ACTIVITY 
        WHERE DATE_KEY = fu.DATE_KEY
    ) as ADOPTION_RATE_PERCENTAGE
FROM GOLD.GO_FACT_FEATURE_USAGE fu
JOIN GOLD.GO_DIM_FEATURE f ON fu.FEATURE_KEY = f.FEATURE_KEY
GROUP BY f.FEATURE_KEY, f.FEATURE_NAME, fu.DATE_KEY;
```

#### 8.2 Data Retention and Archival Rules

**Rationale**: Implement data retention policies to manage fact table growth while maintaining historical data for trend analysis and compliance requirements.

**SQL Example**:
```sql
-- Archive old fact data (older than 7 years)
CREATE TABLE GOLD.GO_FACT_MEETING_ACTIVITY_ARCHIVE 
LIKE GOLD.GO_FACT_MEETING_ACTIVITY;

-- Move old data to archive table
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY_ARCHIVE
SELECT * FROM GOLD.GO_FACT_MEETING_ACTIVITY
WHERE DATE_KEY < CURRENT_DATE() - INTERVAL '7 YEARS';

-- Delete archived data from main table
DELETE FROM GOLD.GO_FACT_MEETING_ACTIVITY
WHERE DATE_KEY < CURRENT_DATE() - INTERVAL '7 YEARS';

-- Create time travel policy for recent data
ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY 
SET DATA_RETENTION_TIME_IN_DAYS = 90;
```

### 9. Error Handling and Recovery Rules

#### 9.1 ETL Error Handling

**Rationale**: Implement comprehensive error handling to ensure data quality and provide detailed error tracking for troubleshooting and data governance.

**SQL Example**:
```sql
-- Error handling procedure for fact table loading
CREATE OR REPLACE PROCEDURE GOLD.SP_LOAD_FACT_WITH_ERROR_HANDLING()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    error_count INTEGER DEFAULT 0;
    success_count INTEGER DEFAULT 0;
    execution_id STRING DEFAULT UUID_STRING();
BEGIN
    -- Log execution start
    INSERT INTO GOLD.GO_PROCESS_AUDIT_LOG (
        AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP, 
        EXECUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM
    )
    VALUES (
        execution_id, 'FACT_TABLE_LOAD', CURRENT_TIMESTAMP(), 
        'RUNNING', CURRENT_DATE(), 'GOLD_ETL_PROCESS'
    );
    
    -- Attempt fact table load with error handling
    BEGIN
        INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (...)
        SELECT ... FROM SILVER.SI_MEETINGS ...;
        
        GET DIAGNOSTICS success_count = ROW_COUNT;
        
    EXCEPTION
        WHEN OTHER THEN
            SET error_count = 1;
            INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
                ERROR_ID, ERROR_TIMESTAMP, ERROR_TYPE, ERROR_MESSAGE,
                PROCESS_EXECUTION_ID, LOAD_DATE, SOURCE_SYSTEM
            )
            VALUES (
                UUID_STRING(), CURRENT_TIMESTAMP(), 'ETL_FAILURE', 
                SQLERRM, execution_id, CURRENT_DATE(), 'GOLD_ETL_PROCESS'
            );
    END;
    
    -- Update execution log
    UPDATE GOLD.GO_PROCESS_AUDIT_LOG 
    SET 
        EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(),
        EXECUTION_STATUS = CASE WHEN error_count > 0 THEN 'FAILED' ELSE 'SUCCESS' END,
        RECORDS_PROCESSED = success_count,
        ERROR_COUNT = error_count
    WHERE AUDIT_LOG_ID = execution_id;
    
    RETURN 'Process completed with ' || success_count || ' records processed and ' || error_count || ' errors';
END;
$$;
```

### 10. BI Integration and Optimization Rules

#### 10.1 Tableau-Specific Optimizations

**Rationale**: Optimize fact tables for Tableau integration with proper foreign key relationships, extract-friendly structures, and performance considerations.

**SQL Example**:
```sql
-- Create Tableau-optimized views with proper relationships
CREATE OR REPLACE VIEW GOLD.VW_TABLEAU_MEETING_ANALYSIS AS
SELECT 
    fma.MEETING_ACTIVITY_ID,
    fma.USER_KEY,
    fma.MEETING_KEY,
    fma.DATE_KEY,
    fma.FEATURE_KEY,
    -- Dimension attributes for Tableau
    du.USER_NAME,
    du.COMPANY,
    du.PLAN_TYPE,
    dd.DATE_VALUE,
    dd.YEAR,
    dd.MONTH_NAME,
    dd.DAY_NAME,
    dm.MEETING_TYPE,
    dm.DURATION_CATEGORY,
    df.FEATURE_NAME,
    df.FEATURE_CATEGORY,
    -- Fact measures
    fma.DURATION_MINUTES,
    fma.PARTICIPANT_COUNT,
    fma.MEETING_QUALITY_SCORE,
    fma.FEATURES_USED_COUNT
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
JOIN GOLD.GO_DIM_USER du ON fma.USER_KEY = du.USER_KEY
JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
JOIN GOLD.GO_DIM_MEETING dm ON fma.MEETING_KEY = dm.MEETING_KEY
LEFT JOIN GOLD.GO_DIM_FEATURE df ON fma.FEATURE_KEY = df.FEATURE_KEY
WHERE du.IS_CURRENT_RECORD = TRUE;
```

#### 10.2 Self-Service Analytics Enablement

**Rationale**: Create user-friendly views and calculated fields that enable business users to perform self-service analytics without requiring deep technical knowledge.

**SQL Example**:
```sql
-- Business-friendly view for self-service analytics
CREATE OR REPLACE VIEW GOLD.VW_BUSINESS_METRICS_DASHBOARD AS
SELECT 
    -- Time dimensions
    dd.DATE_VALUE as "Meeting Date",
    dd.YEAR as "Year",
    dd.MONTH_NAME as "Month",
    dd.DAY_NAME as "Day of Week",
    
    -- User dimensions
    du.COMPANY as "Company",
    du.PLAN_TYPE as "Subscription Plan",
    du.GEOGRAPHIC_REGION as "Region",
    
    -- Meeting metrics
    COUNT(*) as "Total Meetings",
    SUM(fma.DURATION_MINUTES) as "Total Meeting Minutes",
    AVG(fma.DURATION_MINUTES) as "Average Meeting Duration",
    AVG(fma.PARTICIPANT_COUNT) as "Average Participants",
    AVG(fma.MEETING_QUALITY_SCORE) as "Average Quality Score",
    
    -- Calculated KPIs
    COUNT(DISTINCT fma.USER_KEY) as "Active Hosts",
    SUM(fma.PARTICIPANT_COUNT) as "Total Participants",
    SUM(fma.FEATURES_USED_COUNT) as "Total Feature Usage",
    
    -- Business categories
    CASE 
        WHEN AVG(fma.DURATION_MINUTES) >= 60 THEN 'Long Meetings'
        WHEN AVG(fma.DURATION_MINUTES) >= 30 THEN 'Standard Meetings'
        ELSE 'Short Meetings'
    END as "Meeting Duration Category",
    
    CASE 
        WHEN AVG(fma.PARTICIPANT_COUNT) >= 10 THEN 'Large Groups'
        WHEN AVG(fma.PARTICIPANT_COUNT) >= 5 THEN 'Medium Groups'
        ELSE 'Small Groups'
    END as "Group Size Category"
    
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
JOIN GOLD.GO_DIM_USER du ON fma.USER_KEY = du.USER_KEY AND du.IS_CURRENT_RECORD = TRUE
JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
GROUP BY 
    dd.DATE_VALUE, dd.YEAR, dd.MONTH_NAME, dd.DAY_NAME,
    du.COMPANY, du.PLAN_TYPE, du.GEOGRAPHIC_REGION;
```

These comprehensive transformation rules ensure that Fact tables in the Gold layer are:

1. **Properly structured** with foreign key relationships for BI integration
2. **Business-ready** with calculated metrics and KPIs
3. **Quality-assured** through comprehensive validation and error handling
4. **Performance-optimized** with clustering and incremental loading strategies
5. **User-friendly** with business-oriented views and self-service capabilities
6. **Compliant** with data governance and retention policies
7. **Scalable** with proper aggregation and archival strategies
8. **Reliable** with comprehensive audit trails and error tracking

The transformation rules support the three main analytical domains:
- **Platform Usage & Adoption Analytics**
- **Service Reliability & Support Analytics** 
- **Revenue & License Management Analytics**

All transformations maintain referential integrity, implement business rules from the constraints document, and optimize for Snowflake's cloud-native architecture while enabling seamless integration with BI tools like Tableau.