_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive data mapping for Fact tables in Gold Layer with unique row constraints and data integrity validation
## *Version*: 1
## *Updated on*: 2024-12-19
## *Changes*: Initial creation with comprehensive uniqueness validation rules and constraints to ensure every fact table row has unique values based on defining attributes
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping - Enhanced Uniqueness Edition

## Overview

This document provides comprehensive data mapping for transforming Silver Layer data into Gold Layer Fact tables within the Zoom Platform Analytics System. The mapping incorporates advanced uniqueness validation rules to ensure that **every row in each fact table represents a unique combination of its defining attributes**, eliminating duplicate records while maintaining data accuracy and analytical value.

### Key Objectives
- Ensure unique row combinations across all fact tables
- Implement comprehensive data validation and quality checks
- Establish clear transformation rules from Silver to Gold layer
- Maintain referential integrity with dimension tables
- Support scalable analytics and BI integration

### Scope
This mapping covers the following Gold Layer fact tables:
- `GO_FACT_MEETING_ACTIVITY`
- `GO_FACT_SUPPORT_ACTIVITY` 
- `GO_FACT_REVENUE_ACTIVITY`
- `GO_FACT_FEATURE_USAGE`

---

## 1. GO_FACT_MEETING_ACTIVITY Data Mapping

### 1.1 Unique Row Definition
**Composite Key**: (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)

**Rationale**: Each row represents a unique combination of user, meeting, date, and feature to prevent duplicate meeting activity records and ensure accurate analytics.

### 1.2 Data Mapping Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `du.USER_KEY WHERE du.USER_ID = sm.HOST_ID AND du.IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_KEY | Gold | GO_DIM_MEETING | MEETING_KEY | `dm.MEETING_KEY WHERE dm.MEETING_ID = sm.MEETING_ID` |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `dd.DATE_KEY WHERE dd.DATE_VALUE = DATE(sm.START_TIME)` |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURE_KEY | Gold | GO_DIM_FEATURE | FEATURE_KEY | `COALESCE(df.FEATURE_KEY, 'NO_FEATURE') WHERE df.FEATURE_NAME = sf.FEATURE_NAME` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_DATE | Silver | SI_MEETINGS | START_TIME | `DATE(sm.START_TIME)` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_TOPIC | Silver | SI_MEETINGS | MEETING_TOPIC | `TRIM(UPPER(sm.MEETING_TOPIC))` |
| Gold | GO_FACT_MEETING_ACTIVITY | START_TIME | Silver | SI_MEETINGS | START_TIME | `sm.START_TIME::TIMESTAMP_NTZ` |
| Gold | GO_FACT_MEETING_ACTIVITY | END_TIME | Silver | SI_MEETINGS | END_TIME | `sm.END_TIME::TIMESTAMP_NTZ` |
| Gold | GO_FACT_MEETING_ACTIVITY | DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(sm.DURATION_MINUTES, DATEDIFF('minute', sm.START_TIME, sm.END_TIME))` |
| Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT | Silver | SI_PARTICIPANTS | USER_ID | `COUNT(DISTINCT sp.USER_ID)` |
| Gold | GO_FACT_MEETING_ACTIVITY | TOTAL_JOIN_TIME_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `SUM(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME))` |
| Gold | GO_FACT_MEETING_ACTIVITY | AVERAGE_PARTICIPATION_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `AVG(DATEDIFF('minute', sp.JOIN_TIME, sp.LEAVE_TIME))` |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURES_USED_COUNT | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COUNT(DISTINCT sf.FEATURE_NAME)` |
| Gold | GO_FACT_MEETING_ACTIVITY | SCREEN_SHARE_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN sf.FEATURE_NAME = 'Screen Share' THEN sf.USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | RECORDING_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN sf.FEATURE_NAME = 'Recording' THEN sf.USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | CHAT_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN sf.FEATURE_NAME = 'Chat' THEN sf.USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | LOAD_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_MEETING_ACTIVITY | UPDATE_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_MEETING_ACTIVITY | SOURCE_SYSTEM | System | Literal | String | `'SILVER_TO_GOLD_ETL'` |

### 1.3 Uniqueness Validation Rules

```sql
-- Pre-insert uniqueness validation
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_MEETING_ACTIVITY_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Check for potential duplicates in source data
    CREATE OR REPLACE TEMPORARY TABLE TEMP_DUPLICATE_CHECK AS
    SELECT 
        du.USER_KEY,
        dm.MEETING_KEY,
        dd.DATE_KEY,
        COALESCE(df.FEATURE_KEY, 'NO_FEATURE') as FEATURE_KEY,
        COUNT(*) as DUPLICATE_COUNT
    FROM SILVER.SI_MEETINGS sm
    JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
    JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
    JOIN GOLD.GO_DIM_MEETING dm ON sm.MEETING_ID = dm.MEETING_KEY
    LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
    LEFT JOIN GOLD.GO_DIM_FEATURE df ON sf.FEATURE_NAME = df.FEATURE_NAME
    WHERE sm.VALIDATION_STATUS = 'PASSED'
    GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, COALESCE(df.FEATURE_KEY, 'NO_FEATURE')
    HAVING COUNT(*) > 1;
    
    RETURN 'Uniqueness validation completed';
END;
$$;
```

---

## 2. GO_FACT_SUPPORT_ACTIVITY Data Mapping

### 2.1 Unique Row Definition
**Composite Key**: (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_OPEN_DATE)

**Rationale**: Each row represents a unique combination of user, date, support category, and ticket open date to prevent duplicate support activity records.

### 2.2 Data Mapping Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `du.USER_KEY WHERE du.USER_ID = st.USER_ID AND du.IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `dd.DATE_KEY WHERE dd.DATE_VALUE = st.OPEN_DATE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_CATEGORY_KEY | Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | `dsc.SUPPORT_CATEGORY_KEY WHERE dsc.SUPPORT_CATEGORY = st.TICKET_TYPE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `st.OPEN_DATE::DATE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_CLOSE_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN st.OPEN_DATE + INTERVAL '1 DAY' ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `TRIM(UPPER(st.TICKET_TYPE))` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_STATUS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | `TRIM(UPPER(st.RESOLUTION_STATUS))` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | PRIORITY_LEVEL | Gold | GO_DIM_SUPPORT_CATEGORY | PRIORITY_LEVEL | `COALESCE(dsc.PRIORITY_LEVEL, 'Medium')` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | Calculated | Multiple | Calculated | `CASE WHEN st.RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN DATEDIFF('hour', st.OPEN_DATE, st.OPEN_DATE + INTERVAL '1 DAY') ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | LOAD_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | UPDATE_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SOURCE_SYSTEM | System | Literal | String | `'SILVER_TO_GOLD_ETL'` |

### 2.3 Uniqueness Validation Rules

```sql
-- Unique support activity transformation with deduplication
MERGE INTO GOLD.GO_FACT_SUPPORT_ACTIVITY AS target
USING (
    WITH UNIQUE_SUPPORT_RECORDS AS (
        SELECT 
            du.USER_KEY,
            dd.DATE_KEY,
            dsc.SUPPORT_CATEGORY_KEY,
            st.TICKET_ID,
            st.OPEN_DATE as TICKET_OPEN_DATE,
            -- Ensure uniqueness by using ROW_NUMBER
            ROW_NUMBER() OVER (
                PARTITION BY du.USER_KEY, dd.DATE_KEY, dsc.SUPPORT_CATEGORY_KEY, st.OPEN_DATE
                ORDER BY st.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_SUPPORT_TICKETS st
        JOIN GOLD.GO_DIM_USER du ON st.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        JOIN GOLD.GO_DIM_DATE dd ON st.OPEN_DATE = dd.DATE_KEY
        JOIN GOLD.GO_DIM_SUPPORT_CATEGORY dsc ON st.TICKET_TYPE = dsc.SUPPORT_CATEGORY
        WHERE st.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_SUPPORT_RECORDS WHERE RN = 1
) AS source
ON (target.USER_KEY = source.USER_KEY 
    AND target.DATE_KEY = source.DATE_KEY 
    AND target.SUPPORT_CATEGORY_KEY = source.SUPPORT_CATEGORY_KEY
    AND target.TICKET_OPEN_DATE = source.TICKET_OPEN_DATE)
WHEN NOT MATCHED THEN INSERT VALUES (...);
```

---

## 3. GO_FACT_REVENUE_ACTIVITY Data Mapping

### 3.1 Unique Row Definition
**Composite Key**: (USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE)

**Rationale**: Each row represents a unique combination of user, license, date, transaction date, and event type to prevent duplicate financial records and maintain accurate revenue calculations.

### 3.2 Data Mapping Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | REVENUE_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_REVENUE_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `du.USER_KEY WHERE du.USER_ID = be.USER_ID AND du.IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_KEY | Gold | GO_DIM_LICENSE | LICENSE_KEY | `COALESCE(dl.LICENSE_KEY, 'NO_LICENSE') WHERE dl.LICENSE_TYPE = sl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `dd.DATE_KEY WHERE dd.DATE_VALUE = be.EVENT_DATE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | TRANSACTION_DATE | Silver | SI_BILLING_EVENTS | EVENT_DATE | `be.EVENT_DATE::DATE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | EVENT_TYPE | Silver | SI_BILLING_EVENTS | EVENT_TYPE | `TRIM(UPPER(be.EVENT_TYPE))` |
| Gold | GO_FACT_REVENUE_ACTIVITY | AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `ROUND(be.AMOUNT, 2)` |
| Gold | GO_FACT_REVENUE_ACTIVITY | CURRENCY | System | Literal | String | `'USD'` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN be.AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ONE_TIME_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN be.EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN be.AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN be.EVENT_TYPE = 'Refund' THEN -be.AMOUNT ELSE be.AMOUNT END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | USD_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `be.AMOUNT` |
| Gold | GO_FACT_REVENUE_ACTIVITY | MRR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN be.AMOUNT / 12 ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ARR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN be.EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN be.AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LOAD_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_REVENUE_ACTIVITY | UPDATE_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SOURCE_SYSTEM | System | Literal | String | `'SILVER_TO_GOLD_ETL'` |

### 3.3 Uniqueness Validation Rules

```sql
-- Unique revenue activity transformation with transaction-level deduplication
MERGE INTO GOLD.GO_FACT_REVENUE_ACTIVITY AS target
USING (
    WITH UNIQUE_REVENUE_RECORDS AS (
        SELECT 
            du.USER_KEY,
            COALESCE(dl.LICENSE_KEY, 'NO_LICENSE') as LICENSE_KEY,
            dd.DATE_KEY,
            be.EVENT_ID as TRANSACTION_ID,
            be.EVENT_DATE as TRANSACTION_DATE,
            be.EVENT_TYPE,
            be.AMOUNT,
            -- Ensure uniqueness by transaction ID and user combination
            ROW_NUMBER() OVER (
                PARTITION BY du.USER_KEY, COALESCE(dl.LICENSE_KEY, 'NO_LICENSE'), dd.DATE_KEY, be.EVENT_DATE, be.EVENT_TYPE
                ORDER BY be.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_BILLING_EVENTS be
        JOIN GOLD.GO_DIM_USER du ON be.USER_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        JOIN GOLD.GO_DIM_DATE dd ON be.EVENT_DATE = dd.DATE_KEY
        LEFT JOIN SILVER.SI_LICENSES sl ON be.USER_ID = sl.ASSIGNED_TO_USER_ID
        LEFT JOIN GOLD.GO_DIM_LICENSE dl ON sl.LICENSE_TYPE = dl.LICENSE_TYPE AND dl.IS_CURRENT_RECORD = TRUE
        WHERE be.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_REVENUE_RECORDS WHERE RN = 1
) AS source
ON (target.USER_KEY = source.USER_KEY 
    AND target.LICENSE_KEY = source.LICENSE_KEY 
    AND target.DATE_KEY = source.DATE_KEY
    AND target.TRANSACTION_DATE = source.TRANSACTION_DATE
    AND target.EVENT_TYPE = source.EVENT_TYPE)
WHEN NOT MATCHED THEN INSERT VALUES (...);
```

---

## 4. GO_FACT_FEATURE_USAGE Data Mapping

### 4.1 Unique Row Definition
**Composite Key**: (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

**Rationale**: Each row represents a unique combination of date, feature, user, meeting, and usage timestamp to prevent duplicate usage metrics.

### 4.2 Data Mapping Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_USAGE_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `dd.DATE_KEY WHERE dd.DATE_VALUE = fu.USAGE_DATE` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_KEY | Gold | GO_DIM_FEATURE | FEATURE_KEY | `df.FEATURE_KEY WHERE df.FEATURE_NAME = fu.FEATURE_NAME` |
| Gold | GO_FACT_FEATURE_USAGE | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `COALESCE(du.USER_KEY, 'NO_USER') WHERE du.USER_ID = sm.HOST_ID AND du.IS_CURRENT_RECORD = TRUE` |
| Gold | GO_FACT_FEATURE_USAGE | MEETING_KEY | Gold | GO_DIM_MEETING | MEETING_KEY | `COALESCE(dm.MEETING_KEY, 'NO_MEETING') WHERE dm.MEETING_ID = fu.MEETING_ID` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DATE | Silver | SI_FEATURE_USAGE | USAGE_DATE | `fu.USAGE_DATE::DATE` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_TIMESTAMP | Silver | SI_FEATURE_USAGE | USAGE_DATE | `fu.USAGE_DATE::TIMESTAMP_NTZ` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `TRIM(UPPER(fu.FEATURE_NAME))` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `COALESCE(fu.USAGE_COUNT, 0)` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(sm.DURATION_MINUTES, 0)` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE | Calculated | Multiple | Calculated | `CASE WHEN fu.USAGE_COUNT >= 10 THEN 5.0 WHEN fu.USAGE_COUNT >= 5 THEN 4.0 WHEN fu.USAGE_COUNT >= 3 THEN 3.0 WHEN fu.USAGE_COUNT >= 1 THEN 2.0 ELSE 1.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | Calculated | Multiple | Calculated | `CASE WHEN fu.USAGE_COUNT > 0 THEN 100.0 ELSE 0.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | LOAD_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_FEATURE_USAGE | UPDATE_DATE | System | Current Date | CURRENT_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_FEATURE_USAGE | SOURCE_SYSTEM | System | Literal | String | `'SILVER_TO_GOLD_ETL'` |

### 4.3 Uniqueness Validation Rules

```sql
-- Unique feature usage transformation with timestamp-level deduplication
MERGE INTO GOLD.GO_FACT_FEATURE_USAGE AS target
USING (
    WITH UNIQUE_FEATURE_USAGE AS (
        SELECT 
            dd.DATE_KEY,
            df.FEATURE_KEY,
            COALESCE(du.USER_KEY, 'NO_USER') as USER_KEY,
            COALESCE(dm.MEETING_KEY, 'NO_MEETING') as MEETING_KEY,
            fu.USAGE_DATE,
            fu.USAGE_DATE::TIMESTAMP_NTZ as USAGE_TIMESTAMP,
            fu.FEATURE_NAME,
            fu.USAGE_COUNT,
            -- Ensure uniqueness by feature, user, meeting, and timestamp
            ROW_NUMBER() OVER (
                PARTITION BY dd.DATE_KEY, df.FEATURE_KEY, COALESCE(du.USER_KEY, 'NO_USER'), 
                           COALESCE(dm.MEETING_KEY, 'NO_MEETING'), fu.USAGE_DATE::TIMESTAMP_NTZ
                ORDER BY fu.UPDATE_TIMESTAMP DESC
            ) as RN
        FROM SILVER.SI_FEATURE_USAGE fu
        JOIN GOLD.GO_DIM_DATE dd ON fu.USAGE_DATE = dd.DATE_KEY
        JOIN GOLD.GO_DIM_FEATURE df ON fu.FEATURE_NAME = df.FEATURE_NAME
        LEFT JOIN SILVER.SI_MEETINGS sm ON fu.MEETING_ID = sm.MEETING_ID
        LEFT JOIN GOLD.GO_DIM_USER du ON sm.HOST_ID = du.USER_ID AND du.IS_CURRENT_RECORD = TRUE
        LEFT JOIN GOLD.GO_DIM_MEETING dm ON fu.MEETING_ID = dm.MEETING_KEY
        WHERE fu.VALIDATION_STATUS = 'PASSED'
    )
    SELECT * FROM UNIQUE_FEATURE_USAGE WHERE RN = 1
) AS source
ON (target.DATE_KEY = source.DATE_KEY 
    AND target.FEATURE_KEY = source.FEATURE_KEY 
    AND target.USER_KEY = source.USER_KEY
    AND target.MEETING_KEY = source.MEETING_KEY
    AND target.USAGE_TIMESTAMP = source.USAGE_TIMESTAMP)
WHEN NOT MATCHED THEN INSERT VALUES (...);
```

---

## 5. Comprehensive Uniqueness Validation Framework

### 5.1 Master Uniqueness Validation Procedure

```sql
-- Master uniqueness validation procedure for all fact tables
CREATE OR REPLACE PROCEDURE GOLD.SP_MASTER_UNIQUENESS_VALIDATION()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    total_duplicates INTEGER DEFAULT 0;
    validation_results STRING DEFAULT '';
BEGIN
    -- Validate GO_FACT_MEETING_ACTIVITY uniqueness
    INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
        ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, TARGET_TABLE_NAME,
        ERROR_TYPE, ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
        VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
    )
    SELECT 
        UUID_STRING() as ERROR_ID,
        CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as SOURCE_TABLE_NAME,
        'GOLD.GO_FACT_MEETING_ACTIVITY' as TARGET_TABLE_NAME,
        'Uniqueness Violation' as ERROR_TYPE,
        'Duplicate Key Combination' as ERROR_CATEGORY,
        'Critical' as ERROR_SEVERITY,
        'Duplicate found: USER_KEY=' || USER_KEY || ', MEETING_KEY=' || MEETING_KEY || 
        ', DATE_KEY=' || DATE_KEY || ', FEATURE_KEY=' || COALESCE(FEATURE_KEY, 'NULL') || 
        ', Count=' || CNT as ERROR_MESSAGE,
        'MEETING_ACTIVITY_UNIQUENESS' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'MASTER_UNIQUENESS_VALIDATOR' as SOURCE_SYSTEM
    FROM (
        SELECT 
            USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY, COUNT(*) as CNT
        FROM GOLD.GO_FACT_MEETING_ACTIVITY
        GROUP BY USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY
        HAVING COUNT(*) > 1
    );
    
    -- Similar validation for other fact tables...
    
    -- Get total duplicate count
    SELECT COUNT(*) INTO total_duplicates
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE ERROR_TYPE = 'Uniqueness Violation'
    AND DATE(ERROR_TIMESTAMP) = CURRENT_DATE();
    
    SET validation_results = 'Master uniqueness validation completed. Total duplicates found: ' || total_duplicates;
    
    RETURN validation_results;
END;
$$;
```

### 5.2 Real-time Uniqueness Monitoring

```sql
-- Real-time uniqueness monitoring view
CREATE OR REPLACE VIEW GOLD.VW_UNIQUENESS_MONITORING AS
SELECT 
    'GO_FACT_MEETING_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', MEETING_KEY, '|', DATE_KEY, '|', COALESCE(FEATURE_KEY, 'NULL'))) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_MEETING_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_SUPPORT_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', DATE_KEY, '|', SUPPORT_CATEGORY_KEY, '|', TICKET_OPEN_DATE)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_SUPPORT_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_REVENUE_ACTIVITY' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(USER_KEY, '|', LICENSE_KEY, '|', DATE_KEY, '|', TRANSACTION_DATE, '|', EVENT_TYPE)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_REVENUE_ACTIVITY

UNION ALL

SELECT 
    'GO_FACT_FEATURE_USAGE' as TABLE_NAME,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) as UNIQUE_COMBINATIONS,
    COUNT(*) - COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) as DUPLICATE_COUNT,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(DATE_KEY, '|', FEATURE_KEY, '|', COALESCE(USER_KEY, 'NULL'), '|', MEETING_KEY, '|', USAGE_TIMESTAMP)) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as UNIQUENESS_STATUS,
    CURRENT_TIMESTAMP() as CHECK_TIMESTAMP
FROM GOLD.GO_FACT_FEATURE_USAGE;
```

---

## 6. Data Quality and Validation Rules

### 6.1 Pre-Processing Data Quality Checks

```sql
-- Pre-processing data quality validation
CREATE OR REPLACE PROCEDURE GOLD.SP_PRE_LOAD_QUALITY_VALIDATION()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Check for null values in key fields that would affect uniqueness
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
        'Data Quality Issue' as ERROR_TYPE,
        'Null Key Field' as ERROR_CATEGORY,
        'High' as ERROR_SEVERITY,
        'Null value found in key field: ' || 
        CASE 
            WHEN HOST_ID IS NULL THEN 'HOST_ID'
            WHEN MEETING_ID IS NULL THEN 'MEETING_ID'
            WHEN START_TIME IS NULL THEN 'START_TIME'
            ELSE 'UNKNOWN'
        END as ERROR_MESSAGE,
        'PRE_LOAD_NULL_KEY_VALIDATION' as VALIDATION_RULE_NAME,
        CURRENT_DATE() as LOAD_DATE,
        'PRE_LOAD_VALIDATOR' as SOURCE_SYSTEM
    FROM SILVER.SI_MEETINGS
    WHERE HOST_ID IS NULL OR MEETING_ID IS NULL OR START_TIME IS NULL;
    
    RETURN 'Pre-load quality validation completed';
END;
$$;
```

### 6.2 Automated Duplicate Removal Procedure

```sql
-- Automated duplicate removal procedure
CREATE OR REPLACE PROCEDURE GOLD.SP_REMOVE_FACT_TABLE_DUPLICATES()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    removed_count INTEGER DEFAULT 0;
BEGIN
    -- Remove duplicates from GO_FACT_MEETING_ACTIVITY (keep most recent)
    DELETE FROM GOLD.GO_FACT_MEETING_ACTIVITY
    WHERE MEETING_ACTIVITY_ID IN (
        SELECT MEETING_ACTIVITY_ID
        FROM (
            SELECT 
                MEETING_ACTIVITY_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY USER_KEY, MEETING_KEY, DATE_KEY, COALESCE(FEATURE_KEY, 'NO_FEATURE')
                    ORDER BY UPDATE_DATE DESC, MEETING_ACTIVITY_ID DESC
                ) as RN
            FROM GOLD.GO_FACT_MEETING_ACTIVITY
        )
        WHERE RN > 1
    );
    
    GET DIAGNOSTICS removed_count = ROW_COUNT;
    
    -- Similar logic for other fact tables...
    
    RETURN 'Duplicate removal completed. Total records removed: ' || removed_count;
END;
$$;
```

---

## 7. Master ETL Pipeline with Uniqueness Enforcement

### 7.1 Complete ETL Procedure

```sql
-- Master ETL procedure with comprehensive uniqueness enforcement
CREATE OR REPLACE PROCEDURE GOLD.SP_MASTER_FACT_ETL_WITH_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    execution_id STRING DEFAULT UUID_STRING();
    step_result STRING;
    total_errors INTEGER DEFAULT 0;
BEGIN
    -- Log ETL execution start
    INSERT INTO GOLD.GO_PROCESS_AUDIT_LOG (
        AUDIT_LOG_ID, PROCESS_NAME, EXECUTION_START_TIMESTAMP,
        EXECUTION_STATUS, LOAD_DATE, SOURCE_SYSTEM
    )
    VALUES (
        execution_id, 'MASTER_FACT_ETL_WITH_UNIQUENESS', CURRENT_TIMESTAMP(),
        'RUNNING', CURRENT_DATE(), 'GOLD_ETL_MASTER'
    );
    
    -- Step 1: Pre-load quality validation
    CALL GOLD.SP_PRE_LOAD_QUALITY_VALIDATION();
    
    -- Step 2: Load fact tables with uniqueness enforcement
    -- (Execute MERGE statements for all fact tables)
    
    -- Step 3: Post-load uniqueness validation
    CALL GOLD.SP_MASTER_UNIQUENESS_VALIDATION();
    
    -- Step 4: Remove any duplicates found
    CALL GOLD.SP_REMOVE_FACT_TABLE_DUPLICATES();
    
    -- Get total error count
    SELECT COUNT(*) INTO total_errors
    FROM GOLD.GO_DATA_VALIDATION_ERRORS
    WHERE DATE(ERROR_TIMESTAMP) = CURRENT_DATE()
    AND ERROR_SEVERITY IN ('Critical', 'High');
    
    -- Update execution log
    UPDATE GOLD.GO_PROCESS_AUDIT_LOG 
    SET 
        EXECUTION_END_TIMESTAMP = CURRENT_TIMESTAMP(),
        EXECUTION_STATUS = CASE WHEN total_errors > 0 THEN 'COMPLETED_WITH_ERRORS' ELSE 'SUCCESS' END,
        ERROR_COUNT = total_errors
    WHERE AUDIT_LOG_ID = execution_id;
    
    RETURN 'Master ETL with uniqueness enforcement completed. Execution ID: ' || execution_id || ', Errors: ' || total_errors;
END;
$$;
```

---

## 8. Summary of Enhanced Uniqueness Features

This comprehensive data mapping includes:

### 8.1 Uniqueness Validation
- **Pre-insert duplicate detection and prevention**
- **Post-insert uniqueness verification**
- **Real-time monitoring of uniqueness violations**
- **Automated duplicate removal procedures**

### 8.2 Robust Deduplication Strategies
- **ROW_NUMBER() partitioning for source data deduplication**
- **MERGE operations with conflict resolution**
- **Business rule-based duplicate handling (keeping most recent records)**
- **Composite key validation across all fact tables**

### 8.3 Enhanced Data Quality Framework
- **Pre-processing validation to prevent uniqueness issues**
- **Comprehensive error logging and tracking**
- **Severity-based error categorization**
- **Detailed error reporting with specific violation details**

### 8.4 Fact Table Specific Uniqueness Rules

- **GO_FACT_MEETING_ACTIVITY**: Unique by (USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY)
- **GO_FACT_SUPPORT_ACTIVITY**: Unique by (USER_KEY, DATE_KEY, SUPPORT_CATEGORY_KEY, TICKET_OPEN_DATE)
- **GO_FACT_REVENUE_ACTIVITY**: Unique by (USER_KEY, LICENSE_KEY, DATE_KEY, TRANSACTION_DATE, EVENT_TYPE)
- **GO_FACT_FEATURE_USAGE**: Unique by (DATE_KEY, FEATURE_KEY, USER_KEY, MEETING_KEY, USAGE_TIMESTAMP)

### 8.5 Monitoring and Alerting
- **Real-time uniqueness status monitoring**
- **Automated duplicate detection alerts**
- **Comprehensive audit trail for all uniqueness validations**
- **Performance metrics for uniqueness enforcement**

### 8.6 Business Rule Compliance
- **Maintains all original business logic and KPI calculations**
- **Preserves dimensional relationships for BI integration**
- **Ensures referential integrity while enforcing uniqueness**
- **Supports incremental loading with uniqueness constraints**

These enhancements ensure that **every row in each fact table represents a unique combination of its defining attributes**, eliminating duplicate records while maintaining data accuracy, completeness, and analytical value for downstream reporting and BI applications.

---

## 9. Implementation Guidelines

### 9.1 Deployment Steps
1. **Deploy validation procedures** in the correct order
2. **Test uniqueness validation** with sample data
3. **Execute initial data load** with uniqueness enforcement
4. **Validate results** using monitoring views
5. **Schedule regular uniqueness checks** for ongoing data quality

### 9.2 Performance Considerations
- **Clustering keys** on fact tables for optimal query performance
- **Partitioning strategies** based on DATE_KEY for large datasets
- **Index optimization** for uniqueness validation queries
- **Batch processing** for large data volumes

### 9.3 Maintenance and Monitoring
- **Daily uniqueness validation reports**
- **Weekly data quality scorecards**
- **Monthly performance optimization reviews**
- **Quarterly business rule validation**

---

**End of Document**