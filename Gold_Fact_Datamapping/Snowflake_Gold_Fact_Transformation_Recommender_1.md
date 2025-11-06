_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive transformation rules for Zoom Platform Analytics System Gold layer fact tables
## *Version*: 1
## *Updated on*:   
_____________________________________________

# Snowflake Gold Fact Transformation Recommender

## Transformation Rules for Fact Tables

### 1. GO_FACT_MEETING_ACTIVITY Transformation Rules

#### 1.1 Data Aggregation and Enrichment

**Rationale:** Transform Silver layer meeting and participant data into analytical fact table with pre-calculated metrics for meeting activity analysis. This enables efficient reporting on platform usage patterns, meeting effectiveness, and user engagement metrics.

**SQL Example:**
```sql
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (
    MEETING_DATE,
    HOST_USER_KEY,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    PARTICIPANT_COUNT,
    TOTAL_ATTENDANCE_MINUTES,
    AVERAGE_ATTENDANCE_MINUTES,
    FEATURE_USAGE_COUNT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    DATE(m.START_TIME) as MEETING_DATE,
    m.HOST_ID as HOST_USER_KEY,
    COALESCE(m.MEETING_TOPIC, 'Untitled Meeting') as MEETING_TOPIC,
    m.START_TIME,
    m.END_TIME,
    GREATEST(m.DURATION_MINUTES, 0) as DURATION_MINUTES,
    COUNT(DISTINCT p.PARTICIPANT_ID) as PARTICIPANT_COUNT,
    SUM(COALESCE(p.ATTENDANCE_DURATION, 0)) as TOTAL_ATTENDANCE_MINUTES,
    CASE 
        WHEN COUNT(p.PARTICIPANT_ID) > 0 
        THEN AVG(p.ATTENDANCE_DURATION)
        ELSE 0 
    END as AVERAGE_ATTENDANCE_MINUTES,
    COUNT(DISTINCT f.USAGE_ID) as FEATURE_USAGE_COUNT,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    m.SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS m
LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE f ON m.MEETING_ID = f.MEETING_ID
WHERE m.DURATION_MINUTES >= 1  -- Exclude test meetings
  AND m.START_TIME IS NOT NULL
  AND m.END_TIME IS NOT NULL
GROUP BY m.MEETING_ID, m.HOST_ID, m.MEETING_TOPIC, m.START_TIME, 
         m.END_TIME, m.DURATION_MINUTES, m.SOURCE_SYSTEM;
```

#### 1.2 Data Quality Validation Rules

**Rationale:** Ensure data integrity and consistency by applying validation rules during transformation. Invalid records are logged to error table for investigation and resolution.

**SQL Example:**
```sql
-- Validation: Check for negative duration or invalid timestamps
INSERT INTO GOLD.GO_ERROR_DATA (
    ERROR_KEY,
    PIPELINE_RUN_TIMESTAMP,
    SOURCE_TABLE,
    SOURCE_RECORD_KEY,
    ERROR_TYPE,
    ERROR_DESCRIPTION,
    ERROR_SEVERITY,
    ERROR_TIMESTAMP,
    RESOLUTION_STATUS,
    LOAD_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('MEETING_', MEETING_ID, '_', CURRENT_TIMESTAMP()) as ERROR_KEY,
    CURRENT_TIMESTAMP() as PIPELINE_RUN_TIMESTAMP,
    'SI_MEETINGS' as SOURCE_TABLE,
    MEETING_ID as SOURCE_RECORD_KEY,
    'DATA_VALIDATION' as ERROR_TYPE,
    CASE 
        WHEN DURATION_MINUTES < 0 THEN 'Negative meeting duration'
        WHEN START_TIME > END_TIME THEN 'Start time after end time'
        WHEN HOST_ID IS NULL THEN 'Missing host information'
        ELSE 'Unknown validation error'
    END as ERROR_DESCRIPTION,
    'HIGH' as ERROR_SEVERITY,
    CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
    'PENDING' as RESOLUTION_STATUS,
    CURRENT_DATE as LOAD_DATE,
    SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS
WHERE DURATION_MINUTES < 0 
   OR START_TIME > END_TIME 
   OR HOST_ID IS NULL;
```

### 2. GO_FACT_SUPPORT_ACTIVITY Transformation Rules

#### 2.1 Support Metrics Calculation

**Rationale:** Transform support ticket data into analytical fact table with calculated metrics for support performance analysis. Include derived fields for resolution efficiency and escalation tracking.

**SQL Example:**
```sql
INSERT INTO GOLD.GO_FACT_SUPPORT_ACTIVITY (
    TICKET_DATE,
    USER_KEY,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    RESOLUTION_TIME_HOURS,
    PRIORITY_LEVEL,
    FIRST_CONTACT_RESOLUTION_FLAG,
    ESCALATION_FLAG,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    st.OPEN_DATE as TICKET_DATE,
    st.USER_ID as USER_KEY,
    UPPER(TRIM(st.TICKET_TYPE)) as TICKET_TYPE,
    UPPER(TRIM(st.RESOLUTION_STATUS)) as RESOLUTION_STATUS,
    st.OPEN_DATE,
    COALESCE(st.RESOLUTION_TIME_HOURS, 0) as RESOLUTION_TIME_HOURS,
    CASE 
        WHEN u.PLAN_TYPE IN ('ENTERPRISE', 'BUSINESS') THEN 'HIGH'
        WHEN u.PLAN_TYPE = 'PRO' THEN 'MEDIUM'
        ELSE 'STANDARD'
    END as PRIORITY_LEVEL,
    CASE 
        WHEN st.RESOLUTION_TIME_HOURS <= 24 AND st.RESOLUTION_STATUS = 'RESOLVED' 
        THEN TRUE 
        ELSE FALSE 
    END as FIRST_CONTACT_RESOLUTION_FLAG,
    CASE 
        WHEN st.RESOLUTION_TIME_HOURS > 72 
        THEN TRUE 
        ELSE FALSE 
    END as ESCALATION_FLAG,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    st.SOURCE_SYSTEM
FROM SILVER.SI_SUPPORT_TICKETS st
JOIN SILVER.SI_USERS u ON st.USER_ID = u.USER_ID
WHERE st.TICKET_TYPE IS NOT NULL
  AND st.OPEN_DATE IS NOT NULL;
```

#### 2.2 Support Performance Enrichment

**Rationale:** Enrich support data with business context and performance indicators to enable comprehensive support analytics and SLA monitoring.

**SQL Example:**
```sql
-- Update fact table with calculated performance metrics
UPDATE GOLD.GO_FACT_SUPPORT_ACTIVITY 
SET 
    FIRST_CONTACT_RESOLUTION_FLAG = CASE 
        WHEN RESOLUTION_TIME_HOURS <= 4 AND RESOLUTION_STATUS = 'RESOLVED' 
        THEN TRUE 
        ELSE FALSE 
    END,
    ESCALATION_FLAG = CASE 
        WHEN RESOLUTION_TIME_HOURS > 48 OR PRIORITY_LEVEL = 'HIGH' 
        THEN TRUE 
        ELSE FALSE 
    END,
    UPDATE_DATE = CURRENT_DATE
WHERE LOAD_DATE = CURRENT_DATE;
```

### 3. GO_FACT_REVENUE_ACTIVITY Transformation Rules

#### 3.1 Revenue Classification and Enrichment

**Rationale:** Transform billing events into analytical fact table with revenue classification, churn risk scoring, and financial metrics for comprehensive revenue analysis.

**SQL Example:**
```sql
INSERT INTO GOLD.GO_FACT_REVENUE_ACTIVITY (
    EVENT_DATE,
    USER_KEY,
    EVENT_TYPE,
    AMOUNT,
    CURRENCY_CODE,
    PAYMENT_METHOD,
    RECURRING_REVENUE_FLAG,
    CHURN_RISK_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
)
SELECT 
    be.EVENT_DATE,
    be.USER_ID as USER_KEY,
    UPPER(TRIM(be.EVENT_TYPE)) as EVENT_TYPE,
    ABS(be.AMOUNT) as AMOUNT,
    COALESCE(be.CURRENCY_CODE, 'USD') as CURRENCY_CODE,
    COALESCE(payment_method.method, 'UNKNOWN') as PAYMENT_METHOD,
    CASE 
        WHEN be.EVENT_TYPE IN ('SUBSCRIPTION', 'RENEWAL', 'UPGRADE') 
        THEN TRUE 
        ELSE FALSE 
    END as RECURRING_REVENUE_FLAG,
    CASE 
        WHEN usage_stats.meeting_count = 0 THEN 0.95
        WHEN usage_stats.meeting_count < 5 THEN 0.75
        WHEN usage_stats.meeting_count < 15 THEN 0.50
        WHEN usage_stats.meeting_count < 30 THEN 0.25
        ELSE 0.10
    END as CHURN_RISK_SCORE,
    CURRENT_DATE as LOAD_DATE,
    CURRENT_DATE as UPDATE_DATE,
    be.SOURCE_SYSTEM
FROM SILVER.SI_BILLING_EVENTS be
JOIN SILVER.SI_USERS u ON be.USER_ID = u.USER_ID
LEFT JOIN (
    SELECT 
        HOST_ID,
        COUNT(*) as meeting_count
    FROM SILVER.SI_MEETINGS 
    WHERE START_TIME >= DATEADD('month', -1, CURRENT_DATE)
    GROUP BY HOST_ID
) usage_stats ON be.USER_ID = usage_stats.HOST_ID
LEFT JOIN (
    SELECT 
        USER_ID,
        'CREDIT_CARD' as method
    FROM SILVER.SI_BILLING_EVENTS 
    WHERE EVENT_TYPE = 'PAYMENT'
    GROUP BY USER_ID
) payment_method ON be.USER_ID = payment_method.USER_ID
WHERE be.AMOUNT IS NOT NULL
  AND be.EVENT_DATE IS NOT NULL;
```

#### 3.2 Monthly Recurring Revenue (MRR) Calculation

**Rationale:** Calculate standardized MRR metrics for consistent revenue reporting and forecasting. Normalize different billing cycles to monthly equivalents.

**SQL Example:**
```sql
-- Create MRR calculation view for revenue fact table
CREATE OR REPLACE VIEW GOLD.VW_MRR_CALCULATION AS
SELECT 
    USER_KEY,
    EVENT_DATE,
    CASE 
        WHEN EVENT_TYPE = 'SUBSCRIPTION' AND RECURRING_REVENUE_FLAG = TRUE 
        THEN AMOUNT
        WHEN EVENT_TYPE = 'UPGRADE' 
        THEN AMOUNT - LAG(AMOUNT) OVER (PARTITION BY USER_KEY ORDER BY EVENT_DATE)
        WHEN EVENT_TYPE = 'DOWNGRADE' 
        THEN AMOUNT - LAG(AMOUNT) OVER (PARTITION BY USER_KEY ORDER BY EVENT_DATE)
        ELSE 0
    END as MRR_IMPACT,
    AMOUNT,
    EVENT_TYPE
FROM GOLD.GO_FACT_REVENUE_ACTIVITY
WHERE RECURRING_REVENUE_FLAG = TRUE
  AND EVENT_DATE >= DATEADD('year', -2, CURRENT_DATE);
```

### 4. Cross-Fact Table Integration Rules

#### 4.1 User Activity Correlation

**Rationale:** Enable cross-fact analysis by maintaining consistent user keys and temporal alignment across all fact tables for comprehensive user journey analytics.

**SQL Example:**
```sql
-- Create unified user activity summary
CREATE OR REPLACE VIEW GOLD.VW_USER_ACTIVITY_SUMMARY AS
SELECT 
    COALESCE(m.HOST_USER_KEY, s.USER_KEY, r.USER_KEY) as USER_KEY,
    COALESCE(m.MEETING_DATE, s.TICKET_DATE, r.EVENT_DATE) as ACTIVITY_DATE,
    COUNT(DISTINCT m.MEETING_ACTIVITY_ID) as MEETING_COUNT,
    SUM(m.DURATION_MINUTES) as TOTAL_MEETING_MINUTES,
    COUNT(DISTINCT s.SUPPORT_ACTIVITY_ID) as SUPPORT_TICKET_COUNT,
    SUM(CASE WHEN r.RECURRING_REVENUE_FLAG = TRUE THEN r.AMOUNT ELSE 0 END) as RECURRING_REVENUE,
    AVG(r.CHURN_RISK_SCORE) as AVG_CHURN_RISK
FROM GOLD.GO_FACT_MEETING_ACTIVITY m
FULL OUTER JOIN GOLD.GO_FACT_SUPPORT_ACTIVITY s 
    ON m.HOST_USER_KEY = s.USER_KEY 
    AND m.MEETING_DATE = s.TICKET_DATE
FULL OUTER JOIN GOLD.GO_FACT_REVENUE_ACTIVITY r 
    ON COALESCE(m.HOST_USER_KEY, s.USER_KEY) = r.USER_KEY 
    AND COALESCE(m.MEETING_DATE, s.TICKET_DATE) = r.EVENT_DATE
GROUP BY 
    COALESCE(m.HOST_USER_KEY, s.USER_KEY, r.USER_KEY),
    COALESCE(m.MEETING_DATE, s.TICKET_DATE, r.EVENT_DATE);
```

### 5. Data Quality and Audit Rules

#### 5.1 Comprehensive Error Tracking

**Rationale:** Implement comprehensive error tracking across all fact table transformations to ensure data quality and enable proactive issue resolution.

**SQL Example:**
```sql
-- Standardized error logging procedure
CREATE OR REPLACE PROCEDURE GOLD.LOG_TRANSFORMATION_ERROR(
    p_source_table STRING,
    p_source_key STRING,
    p_error_type STRING,
    p_error_description STRING,
    p_severity STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO GOLD.GO_ERROR_DATA (
        ERROR_KEY,
        PIPELINE_RUN_TIMESTAMP,
        SOURCE_TABLE,
        SOURCE_RECORD_KEY,
        ERROR_TYPE,
        ERROR_DESCRIPTION,
        ERROR_SEVERITY,
        ERROR_TIMESTAMP,
        RESOLUTION_STATUS,
        LOAD_DATE,
        SOURCE_SYSTEM
    )
    VALUES (
        CONCAT(p_source_table, '_', p_source_key, '_', CURRENT_TIMESTAMP()),
        CURRENT_TIMESTAMP(),
        p_source_table,
        p_source_key,
        p_error_type,
        p_error_description,
        p_severity,
        CURRENT_TIMESTAMP(),
        'PENDING',
        CURRENT_DATE,
        'GOLD_TRANSFORMATION'
    );
    
    RETURN 'Error logged successfully';
END;
$$;
```

#### 5.2 Pipeline Audit and Monitoring

**Rationale:** Maintain comprehensive audit trail for all fact table transformations to support operational monitoring, performance optimization, and compliance requirements.

**SQL Example:**
```sql
-- Audit logging for fact table transformations
INSERT INTO GOLD.GO_PROCESS_AUDIT (
    AUDIT_KEY,
    PIPELINE_NAME,
    PIPELINE_RUN_TIMESTAMP,
    SOURCE_TABLE,
    TARGET_TABLE,
    EXECUTION_START_TIME,
    EXECUTION_END_TIME,
    EXECUTION_DURATION_SECONDS,
    RECORDS_READ,
    RECORDS_PROCESSED,
    RECORDS_INSERTED,
    RECORDS_UPDATED,
    RECORDS_REJECTED,
    EXECUTION_STATUS,
    PROCESSED_BY,
    DATA_FRESHNESS_TIMESTAMP,
    LOAD_DATE,
    SOURCE_SYSTEM
)
SELECT 
    CONCAT('FACT_TRANSFORM_', CURRENT_TIMESTAMP()) as AUDIT_KEY,
    'GOLD_FACT_TRANSFORMATION' as PIPELINE_NAME,
    CURRENT_TIMESTAMP() as PIPELINE_RUN_TIMESTAMP,
    'SILVER.SI_MEETINGS' as SOURCE_TABLE,
    'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE,
    :execution_start as EXECUTION_START_TIME,
    CURRENT_TIMESTAMP() as EXECUTION_END_TIME,
    DATEDIFF('second', :execution_start, CURRENT_TIMESTAMP()) as EXECUTION_DURATION_SECONDS,
    :records_read as RECORDS_READ,
    :records_processed as RECORDS_PROCESSED,
    :records_inserted as RECORDS_INSERTED,
    :records_updated as RECORDS_UPDATED,
    :records_rejected as RECORDS_REJECTED,
    'SUCCESS' as EXECUTION_STATUS,
    CURRENT_USER() as PROCESSED_BY,
    MAX(UPDATE_TIMESTAMP) as DATA_FRESHNESS_TIMESTAMP,
    CURRENT_DATE as LOAD_DATE,
    'GOLD_LAYER' as SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS;
```

### 6. Performance Optimization Rules

#### 6.1 Incremental Processing Strategy

**Rationale:** Implement incremental processing to optimize performance and reduce processing time for large datasets while maintaining data consistency.

**SQL Example:**
```sql
-- Incremental load strategy for fact tables
MERGE INTO GOLD.GO_FACT_MEETING_ACTIVITY AS target
USING (
    SELECT 
        DATE(m.START_TIME) as MEETING_DATE,
        m.HOST_ID as HOST_USER_KEY,
        m.MEETING_TOPIC,
        m.START_TIME,
        m.END_TIME,
        m.DURATION_MINUTES,
        COUNT(DISTINCT p.PARTICIPANT_ID) as PARTICIPANT_COUNT,
        SUM(COALESCE(p.ATTENDANCE_DURATION, 0)) as TOTAL_ATTENDANCE_MINUTES,
        AVG(p.ATTENDANCE_DURATION) as AVERAGE_ATTENDANCE_MINUTES,
        COUNT(DISTINCT f.USAGE_ID) as FEATURE_USAGE_COUNT,
        CURRENT_DATE as LOAD_DATE,
        CURRENT_DATE as UPDATE_DATE,
        m.SOURCE_SYSTEM,
        m.MEETING_ID
    FROM SILVER.SI_MEETINGS m
    LEFT JOIN SILVER.SI_PARTICIPANTS p ON m.MEETING_ID = p.MEETING_ID
    LEFT JOIN SILVER.SI_FEATURE_USAGE f ON m.MEETING_ID = f.MEETING_ID
    WHERE m.UPDATE_TIMESTAMP >= :last_processed_timestamp
    GROUP BY m.MEETING_ID, m.HOST_ID, m.MEETING_TOPIC, m.START_TIME, 
             m.END_TIME, m.DURATION_MINUTES, m.SOURCE_SYSTEM
) AS source
ON target.HOST_USER_KEY = source.HOST_USER_KEY 
   AND target.START_TIME = source.START_TIME
WHEN MATCHED THEN 
    UPDATE SET 
        PARTICIPANT_COUNT = source.PARTICIPANT_COUNT,
        TOTAL_ATTENDANCE_MINUTES = source.TOTAL_ATTENDANCE_MINUTES,
        AVERAGE_ATTENDANCE_MINUTES = source.AVERAGE_ATTENDANCE_MINUTES,
        FEATURE_USAGE_COUNT = source.FEATURE_USAGE_COUNT,
        UPDATE_DATE = CURRENT_DATE
WHEN NOT MATCHED THEN 
    INSERT (
        MEETING_DATE, HOST_USER_KEY, MEETING_TOPIC, START_TIME, END_TIME,
        DURATION_MINUTES, PARTICIPANT_COUNT, TOTAL_ATTENDANCE_MINUTES,
        AVERAGE_ATTENDANCE_MINUTES, FEATURE_USAGE_COUNT, LOAD_DATE,
        UPDATE_DATE, SOURCE_SYSTEM
    )
    VALUES (
        source.MEETING_DATE, source.HOST_USER_KEY, source.MEETING_TOPIC,
        source.START_TIME, source.END_TIME, source.DURATION_MINUTES,
        source.PARTICIPANT_COUNT, source.TOTAL_ATTENDANCE_MINUTES,
        source.AVERAGE_ATTENDANCE_MINUTES, source.FEATURE_USAGE_COUNT,
        source.LOAD_DATE, source.UPDATE_DATE, source.SOURCE_SYSTEM
    );
```

#### 6.2 Clustering and Partitioning Strategy

**Rationale:** Optimize query performance through strategic clustering and partitioning based on common query patterns and date-based access patterns.

**SQL Example:**
```sql
-- Apply clustering keys for optimal query performance
ALTER TABLE GOLD.GO_FACT_MEETING_ACTIVITY 
CLUSTER BY (MEETING_DATE, HOST_USER_KEY);

ALTER TABLE GOLD.GO_FACT_SUPPORT_ACTIVITY 
CLUSTER BY (TICKET_DATE, USER_KEY, PRIORITY_LEVEL);

ALTER TABLE GOLD.GO_FACT_REVENUE_ACTIVITY 
CLUSTER BY (EVENT_DATE, USER_KEY, RECURRING_REVENUE_FLAG);

-- Create materialized views for common aggregations
CREATE MATERIALIZED VIEW GOLD.MV_DAILY_MEETING_SUMMARY AS
SELECT 
    MEETING_DATE,
    COUNT(*) as TOTAL_MEETINGS,
    COUNT(DISTINCT HOST_USER_KEY) as UNIQUE_HOSTS,
    SUM(DURATION_MINUTES) as TOTAL_DURATION,
    AVG(DURATION_MINUTES) as AVG_DURATION,
    SUM(PARTICIPANT_COUNT) as TOTAL_PARTICIPANTS,
    AVG(PARTICIPANT_COUNT) as AVG_PARTICIPANTS
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY MEETING_DATE;
```

### 7. Business Rule Implementation

#### 7.1 KPI Calculation Rules

**Rationale:** Implement standardized KPI calculations aligned with business requirements to ensure consistent metrics across all reporting and analytics.

**SQL Example:**
```sql
-- Daily Active Users (DAU) calculation
CREATE OR REPLACE VIEW GOLD.VW_DAILY_ACTIVE_USERS AS
SELECT 
    MEETING_DATE as ACTIVITY_DATE,
    COUNT(DISTINCT HOST_USER_KEY) as DAU_COUNT,
    'MEETING_HOST' as ACTIVITY_TYPE
FROM GOLD.GO_FACT_MEETING_ACTIVITY
WHERE MEETING_DATE >= DATEADD('year', -1, CURRENT_DATE)
GROUP BY MEETING_DATE

UNION ALL

SELECT 
    EVENT_DATE as ACTIVITY_DATE,
    COUNT(DISTINCT USER_KEY) as DAU_COUNT,
    'REVENUE_EVENT' as ACTIVITY_TYPE
FROM GOLD.GO_FACT_REVENUE_ACTIVITY
WHERE EVENT_DATE >= DATEADD('year', -1, CURRENT_DATE)
GROUP BY EVENT_DATE;

-- Average Resolution Time calculation
CREATE OR REPLACE VIEW GOLD.VW_SUPPORT_METRICS AS
SELECT 
    DATE_TRUNC('month', TICKET_DATE) as MONTH,
    TICKET_TYPE,
    PRIORITY_LEVEL,
    COUNT(*) as TOTAL_TICKETS,
    AVG(RESOLUTION_TIME_HOURS) as AVG_RESOLUTION_TIME,
    COUNT(CASE WHEN FIRST_CONTACT_RESOLUTION_FLAG = TRUE THEN 1 END) * 100.0 / COUNT(*) as FCR_RATE,
    COUNT(CASE WHEN ESCALATION_FLAG = TRUE THEN 1 END) * 100.0 / COUNT(*) as ESCALATION_RATE
FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
WHERE TICKET_DATE >= DATEADD('year', -1, CURRENT_DATE)
GROUP BY DATE_TRUNC('month', TICKET_DATE), TICKET_TYPE, PRIORITY_LEVEL;
```

### 8. Data Lineage and Traceability

#### 8.1 Source System Tracking

**Rationale:** Maintain complete data lineage from source systems through Silver to Gold layer to support data governance, troubleshooting, and compliance requirements.

**SQL Example:**
```sql
-- Data lineage tracking view
CREATE OR REPLACE VIEW GOLD.VW_DATA_LINEAGE AS
SELECT 
    'GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE,
    'SI_MEETINGS' as SOURCE_TABLE,
    COUNT(*) as RECORD_COUNT,
    MIN(LOAD_DATE) as EARLIEST_LOAD,
    MAX(UPDATE_DATE) as LATEST_UPDATE,
    COUNT(DISTINCT SOURCE_SYSTEM) as SOURCE_SYSTEM_COUNT,
    LISTAGG(DISTINCT SOURCE_SYSTEM, ', ') as SOURCE_SYSTEMS
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY 1, 2

UNION ALL

SELECT 
    'GO_FACT_SUPPORT_ACTIVITY' as TARGET_TABLE,
    'SI_SUPPORT_TICKETS' as SOURCE_TABLE,
    COUNT(*) as RECORD_COUNT,
    MIN(LOAD_DATE) as EARLIEST_LOAD,
    MAX(UPDATE_DATE) as LATEST_UPDATE,
    COUNT(DISTINCT SOURCE_SYSTEM) as SOURCE_SYSTEM_COUNT,
    LISTAGG(DISTINCT SOURCE_SYSTEM, ', ') as SOURCE_SYSTEMS
FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
GROUP BY 1, 2

UNION ALL

SELECT 
    'GO_FACT_REVENUE_ACTIVITY' as TARGET_TABLE,
    'SI_BILLING_EVENTS' as SOURCE_TABLE,
    COUNT(*) as RECORD_COUNT,
    MIN(LOAD_DATE) as EARLIEST_LOAD,
    MAX(UPDATE_DATE) as LATEST_UPDATE,
    COUNT(DISTINCT SOURCE_SYSTEM) as SOURCE_SYSTEM_COUNT,
    LISTAGG(DISTINCT SOURCE_SYSTEM, ', ') as SOURCE_SYSTEMS
FROM GOLD.GO_FACT_REVENUE_ACTIVITY
GROUP BY 1, 2;
```

### 9. Security and Compliance Rules

#### 9.1 Data Masking and Privacy Protection

**Rationale:** Implement data masking and privacy protection measures for sensitive information while maintaining analytical value of the data.

**SQL Example:**
```sql
-- Create secure views with data masking
CREATE OR REPLACE SECURE VIEW GOLD.VW_FACT_MEETING_ACTIVITY_MASKED AS
SELECT 
    MEETING_ACTIVITY_ID,
    MEETING_DATE,
    SHA2(HOST_USER_KEY) as HOST_USER_KEY_HASH,  -- Hash sensitive user keys
    CASE 
        WHEN CURRENT_ROLE() IN ('ADMIN', 'DATA_ANALYST') 
        THEN MEETING_TOPIC 
        ELSE 'MASKED' 
    END as MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    PARTICIPANT_COUNT,
    TOTAL_ATTENDANCE_MINUTES,
    AVERAGE_ATTENDANCE_MINUTES,
    FEATURE_USAGE_COUNT,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM GOLD.GO_FACT_MEETING_ACTIVITY;
```

### 10. Monitoring and Alerting Rules

#### 10.1 Data Quality Monitoring

**Rationale:** Implement automated monitoring and alerting for data quality issues, processing failures, and business rule violations to ensure reliable analytics.

**SQL Example:**
```sql
-- Data quality monitoring procedure
CREATE OR REPLACE PROCEDURE GOLD.MONITOR_FACT_TABLE_QUALITY()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    meeting_count INTEGER;
    support_count INTEGER;
    revenue_count INTEGER;
    error_count INTEGER;
BEGIN
    -- Check for expected daily record counts
    SELECT COUNT(*) INTO meeting_count 
    FROM GOLD.GO_FACT_MEETING_ACTIVITY 
    WHERE MEETING_DATE = CURRENT_DATE;
    
    SELECT COUNT(*) INTO support_count 
    FROM GOLD.GO_FACT_SUPPORT_ACTIVITY 
    WHERE TICKET_DATE = CURRENT_DATE;
    
    SELECT COUNT(*) INTO revenue_count 
    FROM GOLD.GO_FACT_REVENUE_ACTIVITY 
    WHERE EVENT_DATE = CURRENT_DATE;
    
    SELECT COUNT(*) INTO error_count 
    FROM GOLD.GO_ERROR_DATA 
    WHERE LOAD_DATE = CURRENT_DATE AND RESOLUTION_STATUS = 'PENDING';
    
    -- Alert if counts are below expected thresholds or errors exist
    IF (meeting_count < 10 OR support_count < 5 OR revenue_count < 1 OR error_count > 0) THEN
        INSERT INTO GOLD.GO_PROCESS_AUDIT (
            AUDIT_KEY, PIPELINE_NAME, PIPELINE_RUN_TIMESTAMP,
            EXECUTION_STATUS, ERROR_MESSAGE, LOAD_DATE, SOURCE_SYSTEM
        )
        VALUES (
            CONCAT('QUALITY_ALERT_', CURRENT_TIMESTAMP()),
            'DATA_QUALITY_MONITOR',
            CURRENT_TIMESTAMP(),
            'WARNING',
            CONCAT('Quality issues detected - Meetings: ', meeting_count, 
                   ', Support: ', support_count, ', Revenue: ', revenue_count, 
                   ', Errors: ', error_count),
            CURRENT_DATE,
            'MONITORING_SYSTEM'
        );
    END IF;
    
    RETURN 'Quality monitoring completed';
END;
$$;
```

These comprehensive transformation rules ensure that the Gold layer fact tables are populated with high-quality, consistent, and analytically-ready data that supports all business reporting requirements while maintaining data integrity, security, and performance optimization.