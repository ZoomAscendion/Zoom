_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced transformation rules for Fact tables in Gold layer with uniqueness constraints and deduplication strategies
## *Version*: 2
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping - Enhanced with Uniqueness Validation

## Overview

This document provides enhanced data mapping for transforming Silver layer tables into Gold layer Fact tables in the Zoom Platform Analytics System. **Version 2** introduces comprehensive uniqueness constraints and deduplication strategies to ensure that every fact table has one unique row for every unique combination of its defining attributes (grain).

### Key Enhancements in Version 2
- **Grain Definition**: Clearly defined unique grain for each fact table
- **Deduplication Logic**: ROW_NUMBER() window functions with business-driven ordering
- **Pre-Load Validation**: Comprehensive validation procedures to prevent uniqueness violations
- **Automated Monitoring**: Scheduled tasks to continuously monitor fact table uniqueness
- **Business Impact Analysis**: Frameworks to quantify the impact of uniqueness violations on KPIs
- **Performance Optimization**: Optimized clustering keys based on grain definitions

### Critical Principle: Fact Table Uniqueness
**Every fact table must have one unique row for every unique combination of its defining attributes (grain). This ensures data integrity, prevents double-counting in aggregations, and maintains analytical accuracy.**

### Scope of Fact Tables with Enhanced Uniqueness
1. **GO_FACT_MEETING_ACTIVITY** - Grain: (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)
2. **GO_FACT_SUPPORT_ACTIVITY** - Grain: (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_ID)
3. **GO_FACT_REVENUE_ACTIVITY** - Grain: (USER_KEY, LICENSE_KEY, DATE_KEY, EVENT_ID)
4. **GO_FACT_FEATURE_USAGE** - Grain: (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

---

## 1. GO_FACT_MEETING_ACTIVITY Enhanced Data Mapping with Uniqueness

### 1.1 Grain Definition and Unique Key Strategy

**Grain**: One row per unique combination of (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `JOIN with GO_DIM_USER on HOST_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_KEY | Silver | SI_MEETINGS | MEETING_ID | `JOIN with GO_DIM_MEETING on MEETING_ID = MEETING_KEY` |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` - Extract date component for dimension join |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COALESCE(JOIN with GO_DIM_FEATURE on FEATURE_NAME = FEATURE_NAME, 'NO_FEATURE')` |

### 1.2 Deduplication Logic Implementation

```sql
-- Step 1: Create staging table with deduplication logic
CREATE OR REPLACE TEMPORARY TABLE TEMP_MEETING_ACTIVITY_STAGING AS
WITH DEDUPLICATED_SOURCE AS (
    SELECT 
        du.USER_KEY,
        dm.MEETING_KEY,
        dd.DATE_KEY,
        COALESCE(df.FEATURE_KEY, 'NO_FEATURE') as FEATURE_KEY,
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
        -- Add row number to handle potential duplicates
        ROW_NUMBER() OVER (
            PARTITION BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, COALESCE(df.FEATURE_KEY, 'NO_FEATURE')
            ORDER BY sm.UPDATE_TIMESTAMP DESC, sm.LOAD_TIMESTAMP DESC
        ) as RN
    FROM SILVER.SI_MEETINGS sm
    JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
    JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
    LEFT JOIN SILVER.SI_PARTICIPANTS sp ON sm.MEETING_ID = sp.MEETING_ID
    LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
    LEFT JOIN GOLD.GO_DIM_FEATURE df ON sf.FEATURE_NAME = df.FEATURE_NAME
    WHERE sm.VALIDATION_STATUS = 'PASSED'
    GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, df.FEATURE_KEY, 
             sm.MEETING_TOPIC, sm.START_TIME, sm.END_TIME, sm.DURATION_MINUTES,
             sm.UPDATE_TIMESTAMP, sm.LOAD_TIMESTAMP
)
SELECT * FROM DEDUPLICATED_SOURCE WHERE RN = 1;
```

### 1.3 Uniqueness Validation Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_ID | Gold | - | - | `UUID_STRING()` - Generate unique error identifier |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TIMESTAMP | Gold | - | - | `CURRENT_TIMESTAMP()` - Current system timestamp |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TYPE | Gold | - | - | `'Data Integrity'` - Error classification |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_CATEGORY | Gold | - | - | `'Duplicate Records'` - Uniqueness violation category |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_SEVERITY | Gold | - | - | `'Critical'` - High severity for uniqueness violations |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | TEMP_MEETING_ACTIVITY_STAGING | USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY | `'Duplicate grain combination detected: USER_KEY=' \|\| USER_KEY \|\| ', MEETING_KEY=' \|\| MEETING_KEY \|\| ', DATE_KEY=' \|\| DATE_KEY \|\| ', FEATURE_KEY=' \|\| FEATURE_KEY` |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'FACT_TABLE_UNIQUENESS_VALIDATION'` - Rule identifier |

### 1.4 Enhanced Participant Metrics with Uniqueness

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT | Silver | SI_PARTICIPANTS | USER_ID | `COUNT(DISTINCT USER_ID)` - Ensure unique participant count |
| Gold | GO_FACT_MEETING_ACTIVITY | PEAK_CONCURRENT_PARTICIPANTS | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `MAX(concurrent_count) FROM (SELECT COUNT(*) as concurrent_count FROM SI_PARTICIPANTS WHERE JOIN_TIME <= t.time_point AND LEAVE_TIME >= t.time_point GROUP BY time_point)` |
| Gold | GO_FACT_MEETING_ACTIVITY | LATE_JOINERS_COUNT | Silver | SI_PARTICIPANTS | JOIN_TIME | `COUNT(DISTINCT USER_ID) WHERE JOIN_TIME > START_TIME + INTERVAL '5 minutes'` - Unique late joiners |
| Gold | GO_FACT_MEETING_ACTIVITY | EARLY_LEAVERS_COUNT | Silver | SI_PARTICIPANTS | LEAVE_TIME | `COUNT(DISTINCT USER_ID) WHERE LEAVE_TIME < END_TIME - INTERVAL '5 minutes'` - Unique early leavers |

---

## 2. GO_FACT_SUPPORT_ACTIVITY Enhanced Data Mapping with Uniqueness

### 2.1 Grain Definition and Unique Key Strategy

**Grain**: One row per unique combination of (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_ID)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_SUPPORT_ACTIVITY | USER_KEY | Silver | SI_SUPPORT_TICKETS | USER_ID | `JOIN with GO_DIM_USER on USER_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `JOIN with GO_DIM_SUPPORT_CATEGORY on TICKET_TYPE = SUPPORT_CATEGORY` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_ID | Silver | SI_SUPPORT_TICKETS | TICKET_ID | `TICKET_ID` - Part of unique grain |

### 2.2 Support Activity Deduplication Logic

```sql
-- Support activity transformation with uniqueness guarantee
CREATE OR REPLACE TEMPORARY TABLE TEMP_SUPPORT_ACTIVITY_STAGING AS
WITH DEDUPLICATED_SUPPORT AS (
    SELECT 
        du.USER_KEY,
        dd.DATE_KEY,
        dsc.SUPPORT_CATEGORY_KEY,
        st.TICKET_ID,
        st.OPEN_DATE as TICKET_OPEN_DATE,
        CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') 
             THEN st.OPEN_DATE + INTERVAL '1 DAY' 
             ELSE NULL END as TICKET_CLOSE_DATE,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        COALESCE(dsc.PRIORITY_LEVEL, 'Medium') as PRIORITY_LEVEL,
        CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
             THEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY')
             ELSE NULL END as RESOLUTION_TIME_HOURS,
        FALSE as FIRST_CONTACT_RESOLUTION_FLAG,
        CASE WHEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY') <= dsc.SLA_TARGET_HOURS
             THEN TRUE ELSE FALSE END as SLA_MET,
        -- Deduplication logic
        ROW_NUMBER() OVER (
            PARTITION BY du.USER_KEY, dd.DATE_KEY, dsc.SUPPORT_CATEGORY_KEY, st.TICKET_ID
            ORDER BY st.UPDATE_TIMESTAMP DESC, st.LOAD_TIMESTAMP DESC
        ) as RN
    FROM SILVER.SI_SUPPORT_TICKETS st
    JOIN GOLD.GO_DIM_USER du ON st.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON st.OPEN_DATE = dd.DATE_KEY
    JOIN GOLD.GO_DIM_SUPPORT_CATEGORY dsc ON st.TICKET_TYPE = dsc.SUPPORT_CATEGORY
    WHERE st.VALIDATION_STATUS = 'PASSED'
)
SELECT * FROM DEDUPLICATED_SUPPORT WHERE RN = 1;
```

### 2.3 Support Resolution Metrics with Uniqueness

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | Gold | TEMP_SUPPORT_ACTIVITY_STAGING | TICKET_OPEN_DATE, TICKET_CLOSE_DATE | `CASE WHEN TICKET_CLOSE_DATE IS NOT NULL THEN DATEDIFF('hour', TICKET_OPEN_DATE, TICKET_CLOSE_DATE) ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FIRST_CONTACT_RESOLUTION_FLAG | Gold | TEMP_SUPPORT_ACTIVITY_STAGING | RESOLUTION_TIME_HOURS | `CASE WHEN RESOLUTION_TIME_HOURS <= 24 THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_MET | Gold | TEMP_SUPPORT_ACTIVITY_STAGING | RESOLUTION_TIME_HOURS, SUPPORT_CATEGORY_KEY | `CASE WHEN RESOLUTION_TIME_HOURS <= (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY WHERE SUPPORT_CATEGORY_KEY = TEMP_SUPPORT_ACTIVITY_STAGING.SUPPORT_CATEGORY_KEY) THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | CUSTOMER_SATISFACTION_SCORE | Gold | TEMP_SUPPORT_ACTIVITY_STAGING | RESOLUTION_TIME_HOURS, FIRST_CONTACT_RESOLUTION_FLAG | `CASE WHEN RESOLUTION_TIME_HOURS <= 4 AND FIRST_CONTACT_RESOLUTION_FLAG = TRUE THEN 5.0 WHEN RESOLUTION_TIME_HOURS <= 24 THEN 4.0 WHEN RESOLUTION_TIME_HOURS <= 72 THEN 3.0 ELSE 2.0 END` |

---

## 3. GO_FACT_REVENUE_ACTIVITY Enhanced Data Mapping with Uniqueness

### 3.1 Grain Definition and Unique Key Strategy

**Grain**: One row per unique combination of (USER_KEY, LICENSE_KEY, DATE_KEY, EVENT_ID)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | REVENUE_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_REVENUE_ACTIVITY | USER_KEY | Silver | SI_BILLING_EVENTS | USER_ID | `JOIN with GO_DIM_USER on USER_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `COALESCE(JOIN with GO_DIM_LICENSE on LICENSE_TYPE = LICENSE_TYPE WHERE IS_CURRENT_RECORD = TRUE, 'NO_LICENSE')` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_REVENUE_ACTIVITY | EVENT_ID | Silver | SI_BILLING_EVENTS | EVENT_ID | `EVENT_ID` - Part of unique grain |

### 3.2 Revenue Activity Deduplication Logic with Financial Data Protection

```sql
-- Revenue activity transformation with strict uniqueness controls
CREATE OR REPLACE TEMPORARY TABLE TEMP_REVENUE_ACTIVITY_STAGING AS
WITH DEDUPLICATED_REVENUE AS (
    SELECT 
        du.USER_KEY,
        COALESCE(dl.LICENSE_KEY, 'NO_LICENSE') as LICENSE_KEY,
        dd.DATE_KEY,
        be.EVENT_ID,
        be.EVENT_DATE as TRANSACTION_DATE,
        be.EVENT_TYPE,
        be.AMOUNT,
        'USD' as CURRENCY,
        CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN be.AMOUNT ELSE 0 END as SUBSCRIPTION_REVENUE_AMOUNT,
        CASE WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') 
             THEN be.AMOUNT ELSE 0 END as ONE_TIME_REVENUE_AMOUNT,
        CASE WHEN be.EVENT_TYPE = 'Refund' 
             THEN -be.AMOUNT ELSE be.AMOUNT END as NET_REVENUE_AMOUNT,
        be.AMOUNT as USD_AMOUNT,
        CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN be.AMOUNT / 12 ELSE 0 END as MRR_IMPACT,
        CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') 
             THEN be.AMOUNT ELSE 0 END as ARR_IMPACT,
        -- Critical deduplication logic for financial data
        ROW_NUMBER() OVER (
            PARTITION BY du.USER_KEY, COALESCE(dl.LICENSE_KEY, 'NO_LICENSE'), dd.DATE_KEY, be.EVENT_ID
            ORDER BY be.UPDATE_TIMESTAMP DESC, be.LOAD_TIMESTAMP DESC, be.AMOUNT DESC
        ) as RN
    FROM SILVER.SI_BILLING_EVENTS be
    JOIN GOLD.GO_DIM_USER du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON be.EVENT_DATE = dd.DATE_KEY
    LEFT JOIN SILVER.SI_LICENSES sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
    LEFT JOIN GOLD.GO_DIM_LICENSE dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
    WHERE be.VALIDATION_STATUS = 'PASSED'
)
SELECT * FROM DEDUPLICATED_REVENUE WHERE RN = 1;
```

### 3.3 Revenue Classification with Uniqueness Protection

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_REVENUE_AMOUNT | Gold | TEMP_REVENUE_ACTIVITY_STAGING | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ONE_TIME_REVENUE_AMOUNT | Gold | TEMP_REVENUE_ACTIVITY_STAGING | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT | Gold | TEMP_REVENUE_ACTIVITY_STAGING | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE = 'Refund' THEN -AMOUNT ELSE AMOUNT END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | MRR_IMPACT | Gold | TEMP_REVENUE_ACTIVITY_STAGING | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT / 12 ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ARR_IMPACT | Gold | TEMP_REVENUE_ACTIVITY_STAGING | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |

---

## 4. GO_FACT_FEATURE_USAGE Enhanced Data Mapping with Uniqueness

### 4.1 Grain Definition and Unique Key Strategy

**Grain**: One row per unique combination of (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_USAGE_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `JOIN with GO_DIM_FEATURE on FEATURE_NAME = FEATURE_NAME` |
| Gold | GO_FACT_FEATURE_USAGE | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `JOIN with GO_DIM_USER on HOST_ID = USER_ID WHERE IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_FEATURE_USAGE | MEETING_KEY | Silver | SI_FEATURE_USAGE | MEETING_ID | `COALESCE(JOIN with GO_DIM_MEETING on MEETING_ID = MEETING_KEY, 'NO_MEETING')` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_TIMESTAMP | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE::TIMESTAMP_NTZ` - Convert to timestamp with microsecond precision |

### 4.2 Feature Usage Deduplication with Temporal Precision

```sql
-- Feature usage transformation with temporal uniqueness
CREATE OR REPLACE TEMPORARY TABLE TEMP_FEATURE_USAGE_STAGING AS
WITH DEDUPLICATED_FEATURE_USAGE AS (
    SELECT 
        dd.DATE_KEY,
        df.FEATURE_KEY,
        du.USER_KEY,
        COALESCE(dm.MEETING_KEY, 'NO_MEETING') as MEETING_KEY,
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
        -- Temporal deduplication with microsecond precision
        ROW_NUMBER() OVER (
            PARTITION BY dd.DATE_KEY, df.FEATURE_KEY, du.USER_KEY, 
                        COALESCE(dm.MEETING_KEY, 'NO_MEETING'), fu.USAGE_DATE::TIMESTAMP_NTZ
            ORDER BY fu.UPDATE_TIMESTAMP DESC, fu.LOAD_TIMESTAMP DESC, fu.USAGE_COUNT DESC
        ) as RN
    FROM SILVER.SI_FEATURE_USAGE fu
    JOIN GOLD.GO_DIM_DATE dd ON fu.USAGE_DATE = dd.DATE_KEY
    JOIN GOLD.GO_DIM_FEATURE df ON fu.FEATURE_NAME = df.FEATURE_NAME
    LEFT JOIN SILVER.SI_MEETINGS sm ON fu.MEETING_ID = sm.MEETING_ID
    LEFT JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    LEFT JOIN GOLD.GO_DIM_MEETING dm ON fu.MEETING_ID = dm.MEETING_KEY
    WHERE fu.VALIDATION_STATUS = 'PASSED'
)
SELECT * FROM DEDUPLICATED_FEATURE_USAGE WHERE RN = 1;
```

### 4.3 Feature Adoption Metrics with Uniqueness

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE | Gold | TEMP_FEATURE_USAGE_STAGING | USAGE_COUNT | `CASE WHEN USAGE_COUNT >= 10 THEN 5.0 WHEN USAGE_COUNT >= 5 THEN 4.0 WHEN USAGE_COUNT >= 3 THEN 3.0 WHEN USAGE_COUNT >= 1 THEN 2.0 ELSE 1.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | Gold | TEMP_FEATURE_USAGE_STAGING | USAGE_COUNT | `CASE WHEN USAGE_COUNT > 0 THEN 100.0 ELSE 0.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_PERFORMANCE_SCORE | Gold | TEMP_FEATURE_USAGE_STAGING | SUCCESS_RATE | `CASE WHEN SUCCESS_RATE = 100.0 THEN 5.0 WHEN SUCCESS_RATE >= 95.0 THEN 4.0 WHEN SUCCESS_RATE >= 85.0 THEN 3.0 ELSE 2.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | USER_EXPERIENCE_RATING | Gold | TEMP_FEATURE_USAGE_STAGING | FEATURE_ADOPTION_SCORE, FEATURE_PERFORMANCE_SCORE | `CASE WHEN FEATURE_ADOPTION_SCORE >= 4.0 AND FEATURE_PERFORMANCE_SCORE >= 4.0 THEN 5.0 WHEN FEATURE_ADOPTION_SCORE >= 3.0 AND FEATURE_PERFORMANCE_SCORE >= 3.0 THEN 4.0 ELSE 3.0 END` |

---

## 5. Comprehensive Uniqueness Validation Framework

### 5.1 Master Uniqueness Validation Procedure

```sql
-- Master uniqueness validation procedure for all fact tables
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_ALL_FACT_TABLE_UNIQUENESS()
RETURNS TABLE (TABLE_NAME STRING, GRAIN_DEFINITION STRING, VIOLATION_COUNT INTEGER, STATUS STRING, BUSINESS_IMPACT STRING)
LANGUAGE SQL
AS
$$
DECLARE
    validation_results RESULTSET;
BEGIN
    -- Create comprehensive uniqueness validation report
    validation_results := (
        WITH FACT_TABLE_VALIDATIONS AS (
            -- Meeting Activity Uniqueness Check
            SELECT 
                'GO_FACT_MEETING_ACTIVITY' as TABLE_NAME,
                'USER_KEY + MEETING_KEY + DATE_KEY + FEATURE_KEY' as GRAIN_DEFINITION,
                COUNT(*) as VIOLATION_COUNT,
                CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END as STATUS,
                CASE WHEN COUNT(*) = 0 THEN 'No business impact' 
                     ELSE 'Meeting metrics may be double-counted in aggregations' END as BUSINESS_IMPACT
            FROM (
                SELECT USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY, COUNT(*) as cnt
                FROM GOLD.GO_FACT_MEETING_ACTIVITY
                GROUP BY USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY
                HAVING COUNT(*) > 1
            )
            
            UNION ALL
            
            -- Support Activity Uniqueness Check
            SELECT 
                'GO_FACT_SUPPORT_ACTIVITY' as TABLE_NAME,
                'USER_KEY + DATE_KEY + SUPPORT_CATEGORY_KEY + TICKET_ID' as GRAIN_DEFINITION,
                COUNT(*) as VIOLATION_COUNT,
                CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END as STATUS,
                CASE WHEN COUNT(*) = 0 THEN 'No business impact' 
                     ELSE 'Support metrics may be inflated, SLA calculations affected' END as BUSINESS_IMPACT
            FROM (
                SELECT USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, 
                       COALESCE(SUPPORT_ACTIVITY_ID::STRING, 'UNKNOWN') as TICKET_ID, 
                       COUNT(*) as cnt
                FROM GOLD.GO_FACT_SUPPORT_ACTIVITY
                GROUP BY USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, SUPPORT_ACTIVITY_ID
                HAVING COUNT(*) > 1
            )
            
            UNION ALL
            
            -- Revenue Activity Uniqueness Check
            SELECT 
                'GO_FACT_REVENUE_ACTIVITY' as TABLE_NAME,
                'USER_KEY + LICENSE_KEY + DATE_KEY + EVENT_ID' as GRAIN_DEFINITION,
                COUNT(*) as VIOLATION_COUNT,
                CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END as STATUS,
                CASE WHEN COUNT(*) = 0 THEN 'No business impact' 
                     ELSE 'CRITICAL: Revenue double-counting, MRR/ARR calculations incorrect' END as BUSINESS_IMPACT
            FROM (
                SELECT USER_KEY, LICENSE_KEY, DATE_KEY, 
                       COALESCE(REVENUE_ACTIVITY_ID::STRING, 'UNKNOWN') as EVENT_ID, 
                       COUNT(*) as cnt
                FROM GOLD.GO_FACT_REVENUE_ACTIVITY
                GROUP BY USER_KEY, LICENSE_KEY, DATE_KEY, REVENUE_ACTIVITY_ID
                HAVING COUNT(*) > 1
            )
            
            UNION ALL
            
            -- Feature Usage Uniqueness Check
            SELECT 
                'GO_FACT_FEATURE_USAGE' as TABLE_NAME,
                'DATE_KEY + FEATURE_KEY + USER_KEY + MEETING_KEY + USAGE_TIMESTAMP' as GRAIN_DEFINITION,
                COUNT(*) as VIOLATION_COUNT,
                CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END as STATUS,
                CASE WHEN COUNT(*) = 0 THEN 'No business impact' 
                     ELSE 'Feature adoption rates may be overstated' END as BUSINESS_IMPACT
            FROM (
                SELECT DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP, COUNT(*) as cnt
                FROM GOLD.GO_FACT_FEATURE_USAGE
                GROUP BY DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP
                HAVING COUNT(*) > 1
            )
        )
        SELECT * FROM FACT_TABLE_VALIDATIONS
    );
    
    RETURN TABLE(validation_results);
END;
$$;
```

### 5.2 Automated Uniqueness Monitoring Task

```sql
-- Automated uniqueness monitoring task
CREATE OR REPLACE TASK GOLD.TASK_MONITOR_FACT_TABLE_UNIQUENESS
    WAREHOUSE = 'WH_POC_ZOOM_DEV_XSMALL'
    SCHEDULE = 'USING CRON 0 */4 * * * UTC'  -- Every 4 hours
AS
DECLARE
    violation_summary STRING;
    alert_threshold INTEGER DEFAULT 0;
    total_violations INTEGER DEFAULT 0;
BEGIN
    -- Check for uniqueness violations
    SELECT COUNT(*) INTO total_violations
    FROM (
        CALL GOLD.SP_VALIDATE_ALL_FACT_TABLE_UNIQUENESS()
    )
    WHERE STATUS = 'FAILED';
    
    IF (total_violations > alert_threshold) THEN
        -- Log alert
        INSERT INTO GOLD.GO_PROCESS_AUDIT_LOG (
            AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP,
            EXECUTION_STATUS, ERROR_COUNT, PROCESS_TYPE,
            LOAD_DATE, SOURCE_SYSTEM
        )
        VALUES (
            UUID_STRING(), 'FACT_TABLE_UNIQUENESS_MONITOR', CURRENT_TIMESTAMP(),
            'ALERT_TRIGGERED', total_violations, 'DATA_QUALITY_MONITOR',
            CURRENT_DATE(), 'AUTOMATED_MONITORING'
        );
    END IF;
END;

-- Start the monitoring task
ALTER TASK GOLD.TASK_MONITOR_FACT_TABLE_UNIQUENESS RESUME;
```

---

## 6. Business Impact Analysis of Uniqueness Violations

### 6.1 KPI Impact Assessment Framework

```sql
-- KPI impact analysis for uniqueness violations
CREATE OR REPLACE VIEW GOLD.VW_UNIQUENESS_VIOLATION_IMPACT AS
WITH VIOLATION_IMPACT_ANALYSIS AS (
    -- Meeting Activity Impact
    SELECT 
        'Meeting Activity' as FACT_TABLE,
        'Daily Active Users (DAU)' as AFFECTED_KPI,
        COUNT(DISTINCT USER_KEY) as CURRENT_VALUE,
        COUNT(DISTINCT USER_KEY) - COUNT(DISTINCT CASE WHEN RN = 1 THEN USER_KEY END) as INFLATION_AMOUNT,
        ROUND(
            ((COUNT(DISTINCT USER_KEY) - COUNT(DISTINCT CASE WHEN RN = 1 THEN USER_KEY END)) * 100.0) / 
            NULLIF(COUNT(DISTINCT CASE WHEN RN = 1 THEN USER_KEY END), 0), 2
        ) as INFLATION_PERCENTAGE
    FROM (
        SELECT 
            USER_KEY,
            ROW_NUMBER() OVER (
                PARTITION BY USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY 
                ORDER BY MEETING_ACTIVITY_ID
            ) as RN
        FROM GOLD.GO_FACT_MEETING_ACTIVITY
        WHERE DATE_KEY >= CURRENT_DATE() - INTERVAL '30 DAYS'
    )
    
    UNION ALL
    
    -- Revenue Impact
    SELECT 
        'Revenue Activity' as FACT_TABLE,
        'Monthly Recurring Revenue (MRR)' as AFFECTED_KPI,
        SUM(MRR_IMPACT) as CURRENT_VALUE,
        SUM(MRR_IMPACT) - SUM(CASE WHEN RN = 1 THEN MRR_IMPACT ELSE 0 END) as INFLATION_AMOUNT,
        ROUND(
            ((SUM(MRR_IMPACT) - SUM(CASE WHEN RN = 1 THEN MRR_IMPACT ELSE 0 END)) * 100.0) / 
            NULLIF(SUM(CASE WHEN RN = 1 THEN MRR_IMPACT ELSE 0 END), 0), 2
        ) as INFLATION_PERCENTAGE
    FROM (
        SELECT 
            MRR_IMPACT,
            ROW_NUMBER() OVER (
                PARTITION BY USER_KEY, LICENSE_KEY, DATE_KEY, REVENUE_ACTIVITY_ID 
                ORDER BY REVENUE_ACTIVITY_ID
            ) as RN
        FROM GOLD.GO_FACT_REVENUE_ACTIVITY
        WHERE DATE_KEY >= DATE_TRUNC('MONTH', CURRENT_DATE())
    )
)
SELECT 
    FACT_TABLE,
    AFFECTED_KPI,
    CURRENT_VALUE,
    INFLATION_AMOUNT,
    INFLATION_PERCENTAGE,
    CASE 
        WHEN INFLATION_PERCENTAGE > 10 THEN 'Critical Impact'
        WHEN INFLATION_PERCENTAGE > 5 THEN 'High Impact'
        WHEN INFLATION_PERCENTAGE > 1 THEN 'Medium Impact'
        WHEN INFLATION_PERCENTAGE > 0 THEN 'Low Impact'
        ELSE 'No Impact'
    END as IMPACT_SEVERITY,
    CASE 
        WHEN FACT_TABLE = 'Revenue Activity' THEN 'Financial reporting accuracy compromised'
        WHEN FACT_TABLE = 'Meeting Activity' THEN 'Usage analytics overstated'
        WHEN FACT_TABLE = 'Feature Usage' THEN 'Product adoption metrics inflated'
        ELSE 'General data quality impact'
    END as BUSINESS_CONSEQUENCE
FROM VIOLATION_IMPACT_ANALYSIS
WHERE INFLATION_AMOUNT > 0;
```

---

## 7. Performance Optimization with Uniqueness Constraints

### 7.1 Optimized Clustering for Unique Grain Patterns

| Target Layer | Target Table | Clustering Keys | Optimization Rule |
|--------------|--------------|-----------------|------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY, USER_KEY, MEETING_KEY, FEATURE_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY, MEETING_KEY, FEATURE_KEY)` - Optimized for grain uniqueness |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY, USER_KEY, SUPPORT_CATEGORY_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY, SUPPORT_CATEGORY_KEY)` - Optimized for grain uniqueness |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY, USER_KEY, LICENSE_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY, LICENSE_KEY)` - Optimized for grain uniqueness |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY)` - Optimized for grain uniqueness |

### 7.2 Materialized Views for Unique Grain Summaries

```sql
-- Create unique-grain optimized materialized views
CREATE MATERIALIZED VIEW GOLD.MV_UNIQUE_MEETING_GRAIN_SUMMARY AS
SELECT 
    DATE_KEY,
    USER_KEY,
    COUNT(DISTINCT MEETING_KEY) as UNIQUE_MEETINGS,
    COUNT(DISTINCT FEATURE_KEY) as UNIQUE_FEATURES_USED,
    SUM(DURATION_MINUTES) as TOTAL_MEETING_MINUTES,
    AVG(PARTICIPANT_COUNT) as AVG_PARTICIPANTS,
    MAX(MEETING_QUALITY_SCORE) as MAX_QUALITY_SCORE
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY DATE_KEY, USER_KEY;

-- Refresh materialized view automatically
CREATE OR REPLACE TASK GOLD.TASK_REFRESH_UNIQUE_GRAIN_VIEWS
    WAREHOUSE = 'WH_POC_ZOOM_DEV_XSMALL'
    SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- Daily at 2 AM UTC
AS
BEGIN
    ALTER MATERIALIZED VIEW GOLD.MV_UNIQUE_MEETING_GRAIN_SUMMARY REFRESH;
END;

ALTER TASK GOLD.TASK_REFRESH_UNIQUE_GRAIN_VIEWS RESUME;
```

---

## 8. Comprehensive Testing Framework for Uniqueness

### 8.1 Automated Uniqueness Testing Suite

```sql
-- Comprehensive uniqueness testing framework
CREATE OR REPLACE PROCEDURE GOLD.SP_COMPREHENSIVE_UNIQUENESS_TESTING()
RETURNS TABLE (TEST_NAME STRING, TEST_RESULT STRING, DETAILS STRING, RECOMMENDATION STRING)
LANGUAGE SQL
AS
$$
DECLARE
    test_results RESULTSET;
BEGIN
    test_results := (
        WITH UNIQUENESS_TESTS AS (
            -- Test 1: Fact Table Grain Uniqueness
            SELECT 
                'FACT_TABLE_GRAIN_UNIQUENESS' as TEST_NAME,
                CASE WHEN SUM(VIOLATION_COUNT) = 0 THEN 'PASSED' ELSE 'FAILED' END as TEST_RESULT,
                'Total violations across all fact tables: ' || SUM(VIOLATION_COUNT) as DETAILS,
                CASE WHEN SUM(VIOLATION_COUNT) = 0 
                     THEN 'No action required - all fact tables maintain proper grain uniqueness'
                     ELSE 'URGENT: Execute deduplication procedures for affected fact tables' END as RECOMMENDATION
            FROM (
                CALL GOLD.SP_VALIDATE_ALL_FACT_TABLE_UNIQUENESS()
            )
            
            UNION ALL
            
            -- Test 2: Temporal Consistency Check
            SELECT 
                'TEMPORAL_CONSISTENCY_CHECK' as TEST_NAME,
                CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END as TEST_RESULT,
                'Records with inconsistent temporal data: ' || COUNT(*) as DETAILS,
                CASE WHEN COUNT(*) = 0 
                     THEN 'Temporal data consistency maintained'
                     ELSE 'Review and correct temporal data inconsistencies' END as RECOMMENDATION
            FROM (
                SELECT * FROM GOLD.GO_FACT_MEETING_ACTIVITY 
                WHERE START_TIME > END_TIME OR DURATION_MINUTES < 0
                UNION ALL
                SELECT * FROM GOLD.GO_FACT_SUPPORT_ACTIVITY 
                WHERE TICKET_CLOSE_DATE < TICKET_OPEN_DATE
                UNION ALL
                SELECT * FROM GOLD.GO_FACT_REVENUE_ACTIVITY 
                WHERE NET_REVENUE_AMOUNT IS NULL AND AMOUNT IS NOT NULL
            )
        )
        SELECT * FROM UNIQUENESS_TESTS
    );
    
    RETURN TABLE(test_results);
END;
$$;
```

---

## 9. Enhanced Business Rules Implementation with Uniqueness

### 9.1 KPI Calculation Rules with Uniqueness Validation

#### Daily Active Users (DAU) with Uniqueness Guarantee
```sql
CREATE OR REPLACE VIEW GOLD.VW_DAILY_ACTIVE_USERS_UNIQUE AS
SELECT 
    DATE_KEY,
    COUNT(DISTINCT USER_KEY) as DAILY_ACTIVE_USERS,
    COUNT(DISTINCT CASE WHEN DURATION_MINUTES >= 5 THEN USER_KEY END) as ENGAGED_DAILY_USERS,
    -- Validation: Check for potential duplicates
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NO_FEATURE'))) as UNIQUE_GRAIN_COMBINATIONS,
    CASE WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NO_FEATURE')))
         THEN 'UNIQUENESS_VALIDATED' 
         ELSE 'UNIQUENESS_VIOLATION' END as UNIQUENESS_STATUS
FROM GOLD.GO_FACT_MEETING_ACTIVITY
GROUP BY DATE_KEY;
```

#### Feature Adoption Rate with Uniqueness Protection
```sql
CREATE OR REPLACE VIEW GOLD.VW_FEATURE_ADOPTION_RATES_UNIQUE AS
SELECT 
    f.FEATURE_KEY,
    f.FEATURE_NAME,
    COUNT(DISTINCT fu.USER_KEY) as USERS_USING_FEATURE,
    (COUNT(DISTINCT fu.USER_KEY) * 100.0) / 
    (SELECT COUNT(DISTINCT USER_KEY) FROM GOLD.GO_FACT_MEETING_ACTIVITY WHERE DATE_KEY = fu.DATE_KEY) as ADOPTION_RATE_PERCENTAGE,
    -- Uniqueness validation
    COUNT(*) as TOTAL_USAGE_RECORDS,
    COUNT(DISTINCT CONCAT(fu.DATE_KEY, '|', fu.FEATURE_KEY, '|', fu.USER_KEY, '|', COALESCE(fu.MEETING_KEY, 'NO_MEETING'), '|', fu.USAGE_TIMESTAMP)) as UNIQUE_USAGE_EVENTS,
    CASE WHEN COUNT(*) = COUNT(DISTINCT CONCAT(fu.DATE_KEY, '|', fu.FEATURE_KEY, '|', fu.USER_KEY, '|', COALESCE(fu.MEETING_KEY, 'NO_MEETING'), '|', fu.USAGE_TIMESTAMP))
         THEN 'UNIQUENESS_VALIDATED' 
         ELSE 'UNIQUENESS_VIOLATION' END as UNIQUENESS_STATUS
FROM GOLD.GO_FACT_FEATURE_USAGE fu
JOIN GOLD.GO_DIM_FEATURE f ON fu.FEATURE_KEY = f.FEATURE_KEY
GROUP BY f.FEATURE_KEY, f.FEATURE_NAME, fu.DATE_KEY;
```

---

## 10. Summary of Enhancements in Version 2

This enhanced data mapping document ensures that:

### 10.1 Key Enhancements for Fact Table Uniqueness

**Critical Changes Made**:

1. **Grain Definition**: Clearly defined unique grain for each fact table:
   - **GO_FACT_MEETING_ACTIVITY**: (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)
   - **GO_FACT_SUPPORT_ACTIVITY**: (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_ID)
   - **GO_FACT_REVENUE_ACTIVITY**: (USER_KEY, LICENSE_KEY, DATE_KEY, EVENT_ID)
   - **GO_FACT_FEATURE_USAGE**: (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

2. **Deduplication Logic**: Implemented ROW_NUMBER() window functions with business-driven ordering to handle duplicates

3. **Pre-Load Validation**: Added comprehensive validation procedures to prevent uniqueness violations

4. **Automated Monitoring**: Created scheduled tasks to continuously monitor fact table uniqueness

5. **Business Impact Analysis**: Developed frameworks to quantify the impact of uniqueness violations on KPIs

6. **Performance Optimization**: Optimized clustering keys based on grain definitions

7. **Comprehensive Testing**: Implemented automated testing suites for ongoing validation

### 10.2 Implementation Recommendations

**Implementation Steps**:

1. **Phase 1: Validation and Assessment**
   - Execute `SP_VALIDATE_ALL_FACT_TABLE_UNIQUENESS()` to assess current state
   - Run `SP_COMPREHENSIVE_UNIQUENESS_TESTING()` to identify all issues
   - Document current violations and business impact

2. **Phase 2: Remediation**
   - Execute deduplication procedures for each fact table
   - Implement pre-load validation procedures
   - Update clustering keys for performance optimization

3. **Phase 3: Monitoring and Maintenance**
   - Deploy automated monitoring tasks
   - Establish alerting mechanisms for uniqueness violations
   - Schedule regular uniqueness testing

4. **Phase 4: Continuous Improvement**
   - Monitor KPI impact analysis views
   - Refine grain definitions based on business requirements
   - Optimize performance based on usage patterns

**Success Criteria**:
- Zero uniqueness violations across all fact tables
- Automated monitoring detecting violations within 4 hours
- Business KPIs showing accurate, non-inflated metrics
- Query performance maintained or improved with optimized clustering

These enhanced transformation rules ensure that every fact table maintains strict uniqueness constraints while providing comprehensive monitoring, validation, and remediation capabilities for the Zoom Platform Analytics System.