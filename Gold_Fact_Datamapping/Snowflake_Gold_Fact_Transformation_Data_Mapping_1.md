_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive transformation rules for Fact tables in Gold layer supporting dimensional modeling and BI integration
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides comprehensive data mapping for transforming Silver layer tables into Gold layer Fact tables in the Zoom Platform Analytics System. The mapping follows dimensional modeling principles with star schema design, incorporating foreign key relationships for seamless BI tool integration, particularly with Tableau.

### Key Mapping Approach
- **Source Layer**: Silver (SI_*) tables containing cleansed and standardized data
- **Target Layer**: Gold (GO_FACT_*) tables optimized for analytics and reporting
- **Architecture**: Star schema with fact tables linked to dimension tables via surrogate keys
- **BI Integration**: Foreign key columns enable automatic relationship detection in BI tools
- **Data Quality**: Comprehensive validation and error handling throughout transformation process

### Scope of Fact Tables Covered
1. **GO_FACT_MEETING_ACTIVITY** - Meeting activities and usage metrics
2. **GO_FACT_SUPPORT_ACTIVITY** - Support ticket activities and resolution metrics
3. **GO_FACT_REVENUE_ACTIVITY** - Revenue events and billing metrics
4. **GO_FACT_FEATURE_USAGE** - Feature usage patterns and adoption metrics

---

## 1. GO_FACT_MEETING_ACTIVITY Data Mapping

### 1.1 Core Meeting Activity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `JOIN with GO_DIM_USER on HOST_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_KEY | Silver | SI_MEETINGS | MEETING_ID | `JOIN with GO_DIM_MEETING on MEETING_ID = MEETING_KEY` |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` - Extract date component for dimension join |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `JOIN with GO_DIM_FEATURE on FEATURE_NAME = FEATURE_NAME` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_DATE | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` - Standardized date format |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_TOPIC | Silver | SI_MEETINGS | MEETING_TOPIC | `COALESCE(MEETING_TOPIC, 'No Topic Specified')` - Handle null values |
| Gold | GO_FACT_MEETING_ACTIVITY | START_TIME | Silver | SI_MEETINGS | START_TIME | `START_TIME` - Direct mapping with timezone standardization |
| Gold | GO_FACT_MEETING_ACTIVITY | END_TIME | Silver | SI_MEETINGS | END_TIME | `END_TIME` - Direct mapping with timezone standardization |
| Gold | GO_FACT_MEETING_ACTIVITY | DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, DATEDIFF('minute', START_TIME, END_TIME))` - Calculate if missing |

### 1.2 Participant Metrics Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT | Silver | SI_PARTICIPANTS | USER_ID | `COUNT(DISTINCT USER_ID)` - Count unique participants per meeting |
| Gold | GO_FACT_MEETING_ACTIVITY | TOTAL_JOIN_TIME_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `SUM(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))` - Total participation time |
| Gold | GO_FACT_MEETING_ACTIVITY | AVERAGE_PARTICIPATION_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `AVG(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))` - Average participation duration |
| Gold | GO_FACT_MEETING_ACTIVITY | PEAK_CONCURRENT_PARTICIPANTS | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `MAX(concurrent_count)` - Calculate peak concurrent users using window functions |
| Gold | GO_FACT_MEETING_ACTIVITY | LATE_JOINERS_COUNT | Silver | SI_PARTICIPANTS | JOIN_TIME | `COUNT(*) WHERE JOIN_TIME > START_TIME + INTERVAL '5 minutes'` - Count late joiners |
| Gold | GO_FACT_MEETING_ACTIVITY | EARLY_LEAVERS_COUNT | Silver | SI_PARTICIPANTS | LEAVE_TIME | `COUNT(*) WHERE LEAVE_TIME < END_TIME - INTERVAL '5 minutes'` - Count early leavers |

### 1.3 Feature Usage Metrics Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURES_USED_COUNT | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COUNT(DISTINCT FEATURE_NAME)` - Count unique features used |
| Gold | GO_FACT_MEETING_ACTIVITY | SCREEN_SHARE_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Screen Share' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | RECORDING_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Recording' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | CHAT_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Chat' THEN USAGE_COUNT ELSE 0 END)` |

### 1.4 Quality Score Calculations

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_QUALITY_SCORE | Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT, AVERAGE_PARTICIPATION_MINUTES, DURATION_MINUTES | `CASE WHEN PARTICIPANT_COUNT >= 5 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.8) THEN 5.0 WHEN PARTICIPANT_COUNT >= 3 AND AVERAGE_PARTICIPATION_MINUTES >= (DURATION_MINUTES * 0.6) THEN 4.0 ELSE 3.0 END` |
| Gold | GO_FACT_MEETING_ACTIVITY | AUDIO_QUALITY_SCORE | Gold | GO_FACT_MEETING_ACTIVITY | CONNECTION_ISSUES_COUNT | `CASE WHEN CONNECTION_ISSUES_COUNT = 0 THEN 5.0 WHEN CONNECTION_ISSUES_COUNT <= 2 THEN 4.0 ELSE 2.0 END` |
| Gold | GO_FACT_MEETING_ACTIVITY | VIDEO_QUALITY_SCORE | Gold | GO_FACT_MEETING_ACTIVITY | CONNECTION_ISSUES_COUNT | `CASE WHEN CONNECTION_ISSUES_COUNT = 0 THEN 5.0 WHEN CONNECTION_ISSUES_COUNT <= 2 THEN 4.0 ELSE 2.0 END` |

---

## 2. GO_FACT_SUPPORT_ACTIVITY Data Mapping

### 2.1 Core Support Activity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_SUPPORT_ACTIVITY | USER_KEY | Silver | SI_SUPPORT_TICKETS | USER_ID | `JOIN with GO_DIM_USER on USER_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `JOIN with GO_DIM_SUPPORT_CATEGORY on TICKET_TYPE = SUPPORT_CATEGORY` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` - Direct mapping |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_CLOSE_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `CASE WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN OPEN_DATE + INTERVAL '1 DAY' ELSE NULL END` - Calculated close date |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `UPPER(TRIM(TICKET_TYPE))` - Standardize format |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_STATUS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | `UPPER(TRIM(RESOLUTION_STATUS))` - Standardize format |

### 2.2 Resolution Metrics Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE, TICKET_CLOSE_DATE | `CASE WHEN TICKET_CLOSE_DATE IS NOT NULL THEN DATEDIFF('hour', TICKET_OPEN_DATE, TICKET_CLOSE_DATE) ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FIRST_CONTACT_RESOLUTION_FLAG | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | `CASE WHEN RESOLUTION_TIME_HOURS <= 24 THEN TRUE ELSE FALSE END` - Business rule implementation |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_MET | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS, SUPPORT_CATEGORY_KEY | `CASE WHEN RESOLUTION_TIME_HOURS <= (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY WHERE SUPPORT_CATEGORY_KEY = GO_FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY) THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_BREACH_HOURS | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS, SUPPORT_CATEGORY_KEY | `CASE WHEN RESOLUTION_TIME_HOURS > (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY) THEN RESOLUTION_TIME_HOURS - (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY) ELSE 0 END` |

### 2.3 Customer Satisfaction Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | CUSTOMER_SATISFACTION_SCORE | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS, FIRST_CONTACT_RESOLUTION_FLAG | `CASE WHEN RESOLUTION_TIME_HOURS <= 4 AND FIRST_CONTACT_RESOLUTION_FLAG = TRUE THEN 5.0 WHEN RESOLUTION_TIME_HOURS <= 24 THEN 4.0 WHEN RESOLUTION_TIME_HOURS <= 72 THEN 3.0 ELSE 2.0 END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | PREVENTABLE_ISSUE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `CASE WHEN TICKET_TYPE IN ('Password Reset', 'Account Lockout', 'Basic Setup') THEN TRUE ELSE FALSE END` |

---

## 3. GO_FACT_REVENUE_ACTIVITY Data Mapping

### 3.1 Core Revenue Activity Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | REVENUE_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_REVENUE_ACTIVITY | USER_KEY | Silver | SI_BILLING_EVENTS | USER_ID | `JOIN with GO_DIM_USER on USER_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `JOIN with GO_DIM_LICENSE on LICENSE_TYPE = LICENSE_TYPE WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_REVENUE_ACTIVITY | TRANSACTION_DATE | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` - Direct mapping |
| Gold | GO_FACT_REVENUE_ACTIVITY | EVENT_TYPE | Silver | SI_BILLING_EVENTS | EVENT_TYPE | `UPPER(TRIM(EVENT_TYPE))` - Standardize format |
| Gold | GO_FACT_REVENUE_ACTIVITY | AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `ROUND(AMOUNT, 2)` - Standardize decimal precision |
| Gold | GO_FACT_REVENUE_ACTIVITY | CURRENCY | Silver | - | - | `'USD'` - Default standardized currency |

### 3.2 Revenue Classification Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ONE_TIME_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE = 'Refund' THEN -AMOUNT ELSE AMOUNT END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | USD_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `AMOUNT` - Assuming already in USD |
| Gold | GO_FACT_REVENUE_ACTIVITY | MRR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT / 12 ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ARR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |

### 3.3 Customer Lifetime Value Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | CUSTOMER_LIFETIME_VALUE | Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT, USER_KEY | `SUM(NET_REVENUE_AMOUNT) OVER (PARTITION BY USER_KEY ORDER BY TRANSACTION_DATE ROWS UNBOUNDED PRECEDING)` - Running total |
| Gold | GO_FACT_REVENUE_ACTIVITY | CHURN_RISK_SCORE | Silver | SI_BILLING_EVENTS | EVENT_TYPE, NET_REVENUE_AMOUNT | `CASE WHEN EVENT_TYPE = 'Downgrade' THEN 4.0 WHEN EVENT_TYPE = 'Refund' THEN 3.5 WHEN NET_REVENUE_AMOUNT < 0 THEN 2.5 ELSE 1.0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | PAYMENT_STATUS | Silver | SI_BILLING_EVENTS | EVENT_TYPE, NET_REVENUE_AMOUNT | `CASE WHEN EVENT_TYPE = 'Refund' THEN 'Refunded' WHEN NET_REVENUE_AMOUNT > 0 THEN 'Successful' ELSE 'Failed' END` |

---

## 4. GO_FACT_FEATURE_USAGE Data Mapping

### 4.1 Core Feature Usage Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_USAGE_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `JOIN with GO_DIM_FEATURE on FEATURE_NAME = FEATURE_NAME` |
| Gold | GO_FACT_FEATURE_USAGE | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `JOIN with GO_DIM_USER on HOST_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_FEATURE_USAGE | MEETING_KEY | Silver | SI_FEATURE_USAGE | MEETING_ID | `JOIN with GO_DIM_MEETING on MEETING_ID = MEETING_KEY` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DATE | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` - Direct mapping |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_TIMESTAMP | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE::TIMESTAMP_NTZ` - Convert to timestamp |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `TRIM(FEATURE_NAME)` - Clean whitespace |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `COALESCE(USAGE_COUNT, 0)` - Handle null values |

### 4.2 Usage Duration and Context Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, 0)` - Meeting duration as proxy |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_CONTEXT | Gold | GO_FACT_FEATURE_USAGE | USAGE_DURATION_MINUTES | `CASE WHEN USAGE_DURATION_MINUTES >= 60 THEN 'Extended Session' WHEN USAGE_DURATION_MINUTES >= 30 THEN 'Standard Session' WHEN USAGE_DURATION_MINUTES >= 15 THEN 'Short Session' ELSE 'Quick Access' END` |

### 4.3 Adoption and Performance Scoring

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `CASE WHEN USAGE_COUNT >= 10 THEN 5.0 WHEN USAGE_COUNT >= 5 THEN 4.0 WHEN USAGE_COUNT >= 3 THEN 3.0 WHEN USAGE_COUNT >= 1 THEN 2.0 ELSE 1.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `CASE WHEN USAGE_COUNT > 0 THEN 100.0 ELSE 0.0 END` - Basic success rate calculation |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_PERFORMANCE_SCORE | Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | `CASE WHEN SUCCESS_RATE = 100.0 THEN 5.0 WHEN SUCCESS_RATE >= 95.0 THEN 4.0 WHEN SUCCESS_RATE >= 85.0 THEN 3.0 ELSE 2.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | USER_EXPERIENCE_RATING | Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE, FEATURE_PERFORMANCE_SCORE | `CASE WHEN FEATURE_ADOPTION_SCORE >= 4.0 AND FEATURE_PERFORMANCE_SCORE >= 4.0 THEN 5.0 WHEN FEATURE_ADOPTION_SCORE >= 3.0 AND FEATURE_PERFORMANCE_SCORE >= 3.0 THEN 4.0 ELSE 3.0 END` |

---

## 5. Data Quality and Validation Rules

### 5.1 Data Quality Validation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_ID | Gold | - | - | `UUID_STRING()` - Generate unique error identifier |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TIMESTAMP | Gold | - | - | `CURRENT_TIMESTAMP()` - Current system timestamp |
| Gold | GO_DATA_VALIDATION_ERRORS | SOURCE_TABLE_NAME | Silver | - | - | `'SILVER.SI_MEETINGS'` - Source table reference |
| Gold | GO_DATA_VALIDATION_ERRORS | TARGET_TABLE_NAME | Gold | - | - | `'GOLD.GO_FACT_MEETING_ACTIVITY'` - Target table reference |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TYPE | Gold | - | - | `'Data Integrity'` - Error classification |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_FACT_MEETING_ACTIVITY | DURATION_MINUTES | `'Meeting duration exceeds 24 hours: ' || DURATION_MINUTES || ' minutes'` - Dynamic error message |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'MEETING_DURATION_VALIDATION'` - Rule identifier |

### 5.2 Foreign Key Validation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TYPE | Gold | - | - | `'Referential Integrity'` - FK validation error type |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_CATEGORY | Gold | - | - | `'Missing Foreign Key'` - FK validation category |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_SEVERITY | Gold | - | - | `'Critical'` - High severity for FK violations |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | `'USER_KEY not found in dimension table: ' || USER_KEY` - FK validation message |

---

## 6. Metadata and Audit Mapping

### 6.1 Standard Metadata Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | ALL_FACT_TABLES | LOAD_DATE | Gold | - | - | `CURRENT_DATE()` - System load date |
| Gold | ALL_FACT_TABLES | UPDATE_DATE | Gold | - | - | `CURRENT_DATE()` - System update date |
| Gold | ALL_FACT_TABLES | SOURCE_SYSTEM | Gold | - | - | `'SILVER_TO_GOLD_ETL'` - Source system identifier |

### 6.2 Process Audit Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_PROCESS_AUDIT_LOG | AUDIT_LOG_ID | Gold | - | - | `UUID_STRING()` - Unique execution identifier |
| Gold | GO_PROCESS_AUDIT_LOG | PROCESS_NAME | Gold | - | - | `'FACT_TABLE_LOAD'` - Process name |
| Gold | GO_PROCESS_AUDIT_LOG | EXECUTION_START_TIMESTAMP | Gold | - | - | `CURRENT_TIMESTAMP()` - Process start time |
| Gold | GO_PROCESS_AUDIT_LOG | EXECUTION_STATUS | Gold | - | - | `'RUNNING'` - Initial status, updated on completion |
| Gold | GO_PROCESS_AUDIT_LOG | RECORDS_PROCESSED | Gold | - | - | `ROW_COUNT` - Number of records processed |

---

## 7. Business Rules Implementation

### 7.1 KPI Calculation Rules

#### Daily Active Users (DAU)
```sql
CREATE OR REPLACE VIEW GOLD.VW_DAILY_ACTIVE_USERS AS
SELECT 
    DATE_KEY,
    COUNT(DISTINCT USER_KEY) as DAILY_ACTIVE_USERS,
    COUNT(DISTINCT CASE WHEN DURATION_MINUTES >= 5 THEN USER_KEY END) as ENGAGED_DAILY_USERS
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY DATE_KEY;
```

#### Feature Adoption Rate
```sql
CREATE OR REPLACE VIEW GOLD.VW_FEATURE_ADOPTION_RATES AS
SELECT 
    f.FEATURE_KEY,
    f.FEATURE_NAME,
    COUNT(DISTINCT fu.USER_KEY) as USERS_USING_FEATURE,
    (COUNT(DISTINCT fu.USER_KEY) * 100.0) / 
    (SELECT COUNT(DISTINCT USER_KEY) FROM GOLD.GO_FACT_MEETING_ACTIVITY WHERE DATE_KEY = fu.DATE_KEY) as ADOPTION_RATE_PERCENTAGE
FROM GOLD.GO_FACT_FEATURE_USAGE fu
JOIN GOLD.GO_DIM_FEATURE f ON fu.FEATURE_KEY = f.FEATURE_KEY
GROUP BY f.FEATURE_KEY, f.FEATURE_NAME, fu.DATE_KEY;
```

### 7.2 Data Retention Rules

| Target Layer | Target Table | Retention Rule | Transformation Logic |
|--------------|--------------|----------------|---------------------|
| Gold | GO_FACT_MEETING_ACTIVITY_ARCHIVE | Archive after 7 years | `INSERT INTO ARCHIVE SELECT * FROM MAIN WHERE DATE_KEY < CURRENT_DATE() - INTERVAL '7 YEARS'` |
| Gold | GO_FACT_MEETING_ACTIVITY | Delete archived data | `DELETE FROM MAIN WHERE DATE_KEY < CURRENT_DATE() - INTERVAL '7 YEARS'` |
| Gold | ALL_FACT_TABLES | Time travel retention | `ALTER TABLE SET DATA_RETENTION_TIME_IN_DAYS = 90` |

---

## 8. Performance Optimization Rules

### 8.1 Clustering Strategy

| Target Layer | Target Table | Clustering Keys | Optimization Rule |
|--------------|--------------|-----------------|------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY, USER_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY)` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY, SUPPORT_CATEGORY_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY)` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY, USER_KEY, LICENSE_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY, LICENSE_KEY)` |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY, FEATURE_KEY, USER_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, FEATURE_KEY, USER_KEY)` |

### 8.2 Incremental Loading Strategy

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

---

## 9. BI Integration Optimization

### 9.1 Tableau-Specific Views

```sql
-- Business-friendly view for Tableau integration
CREATE OR REPLACE VIEW GOLD.VW_TABLEAU_MEETING_ANALYSIS AS
SELECT 
    fma.MEETING_ACTIVITY_ID,
    fma.USER_KEY,
    fma.MEETING_KEY,
    fma.DATE_KEY,
    -- Dimension attributes for Tableau
    du.USER_NAME,
    du.COMPANY,
    du.PLAN_TYPE,
    dd.DATE_VALUE,
    dd.YEAR,
    dd.MONTH_NAME,
    dm.MEETING_TYPE,
    -- Fact measures
    fma.DURATION_MINUTES,
    fma.PARTICIPANT_COUNT,
    fma.MEETING_QUALITY_SCORE
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
JOIN GOLD.GO_DIM_USER du ON fma.USER_KEY = du.USER_KEY
JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
JOIN GOLD.GO_DIM_MEETING dm ON fma.MEETING_KEY = dm.MEETING_KEY
WHERE du.IS_CURRENT_RECORD = TRUE;
```

### 9.2 Self-Service Analytics Views

```sql
-- Business metrics dashboard view
CREATE OR REPLACE VIEW GOLD.VW_BUSINESS_METRICS_DASHBOARD AS
SELECT 
    dd.DATE_VALUE as "Meeting Date",
    du.COMPANY as "Company",
    du.PLAN_TYPE as "Subscription Plan",
    COUNT(*) as "Total Meetings",
    AVG(fma.DURATION_MINUTES) as "Average Meeting Duration",
    AVG(fma.PARTICIPANT_COUNT) as "Average Participants",
    AVG(fma.MEETING_QUALITY_SCORE) as "Average Quality Score"
FROM GOLD.GO_FACT_MEETING_ACTIVITY fma
JOIN GOLD.GO_DIM_USER du ON fma.USER_KEY = du.USER_KEY AND du.IS_CURRENT_RECORD = TRUE
JOIN GOLD.GO_DIM_DATE dd ON fma.DATE_KEY = dd.DATE_KEY
GROUP BY dd.DATE_VALUE, du.COMPANY, du.PLAN_TYPE;
```

---

## 10. Summary

This comprehensive data mapping document ensures that:

1. **Fact tables are properly structured** with foreign key relationships for BI integration
2. **Business-ready metrics** are calculated with appropriate transformations
3. **Data quality is maintained** through comprehensive validation and error handling
4. **Performance is optimized** with clustering and incremental loading strategies
5. **BI tools can seamlessly integrate** with clear dimensional relationships
6. **Business rules are implemented** consistently across all fact tables
7. **Audit trails are maintained** for data governance and compliance
8. **Scalability is ensured** through proper aggregation and archival strategies

The transformation rules support the three main analytical domains:
- **Platform Usage & Adoption Analytics** via GO_FACT_MEETING_ACTIVITY and GO_FACT_FEATURE_USAGE
- **Service Reliability & Support Analytics** via GO_FACT_SUPPORT_ACTIVITY
- **Revenue & License Management Analytics** via GO_FACT_REVENUE_ACTIVITY

All transformations maintain referential integrity, implement business rules from the constraints document, and optimize for Snowflake's cloud-native architecture while enabling seamless integration with BI tools like Tableau.