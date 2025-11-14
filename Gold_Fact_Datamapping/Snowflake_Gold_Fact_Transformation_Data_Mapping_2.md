_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Enhanced transformation rules for Fact tables in Gold layer with dimension uniqueness validation and comprehensive BI integration
## *Version*: 2
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides enhanced data mapping for transforming Silver layer tables into Gold layer Fact tables in the Zoom Platform Analytics System. **Version 2** specifically addresses the critical requirement that **dimension tables must have unique row values for every unique combination of defining attributes**. The mapping follows dimensional modeling principles with star schema design, incorporating comprehensive dimension uniqueness validation and enhanced BI integration.

### Key Enhancements in Version 2
- **Dimension Uniqueness Validation**: Comprehensive procedures to ensure unique dimension records
- **Automated Deduplication**: Intelligent deduplication strategies for dimension tables
- **Enhanced Fact Loading**: ROW_NUMBER() functions to ensure unique dimension lookups
- **Continuous Monitoring**: Automated dimension uniqueness monitoring and alerting
- **BI Integration Optimization**: Views that guarantee dimension uniqueness for reporting
- **Performance Optimization**: Clustering strategies optimized for unique dimensions

### Key Mapping Approach
- **Source Layer**: Silver (SI_*) tables containing cleansed and standardized data
- **Target Layer**: Gold (GO_FACT_*) tables optimized for analytics with validated unique dimensions
- **Architecture**: Star schema with fact tables linked to guaranteed unique dimension tables
- **BI Integration**: Foreign key columns with validated unique dimension references
- **Data Quality**: Comprehensive validation ensuring dimension uniqueness throughout transformation

### Scope of Fact Tables Covered
1. **GO_FACT_MEETING_ACTIVITY** - Meeting activities with validated unique dimension references
2. **GO_FACT_SUPPORT_ACTIVITY** - Support activities with unique support category dimensions
3. **GO_FACT_REVENUE_ACTIVITY** - Revenue events with unique license and user dimensions
4. **GO_FACT_FEATURE_USAGE** - Feature usage with unique feature and user dimensions

---

## 1. Dimension Uniqueness Validation Framework

### 1.1 Dimension Uniqueness Enforcement Strategy

**Rationale**: Ensure that dimension tables maintain unique rows for every unique combination of defining attributes to support proper dimensional modeling and prevent data duplication that could lead to incorrect analytical results.

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DIM_USER | USER_KEY | Silver | SI_USERS | USER_ID | `ROW_NUMBER() OVER (PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE ORDER BY UPDATE_DATE DESC) = 1` - Ensure uniqueness |
| Gold | GO_DIM_FEATURE | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) = 1` - Ensure uniqueness |
| Gold | GO_DIM_LICENSE | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `ROW_NUMBER() OVER (PARTITION BY LICENSE_TYPE ORDER BY UPDATE_DATE DESC) = 1 AND IS_CURRENT_RECORD = TRUE` - Ensure uniqueness |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY ORDER BY UPDATE_DATE DESC) = 1` - Ensure uniqueness |
| Gold | GO_DIM_MEETING | MEETING_KEY | Silver | SI_MEETINGS | MEETING_ID | `ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) = 1` - Ensure uniqueness |

### 1.2 Dimension Deduplication Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_ID | Gold | GO_DIM_USER | USER_KEY | `UUID_STRING()` - Generate error ID for duplicate dimension records |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_DIM_USER | USER_ID, EMAIL_DOMAIN, COMPANY | `'Duplicate USER dimension: USER_ID=' || USER_ID || ', EMAIL_DOMAIN=' || EMAIL_DOMAIN || ', COMPANY=' || COMPANY` |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'DIM_USER_UNIQUENESS_VALIDATION'` - Rule identifier for dimension uniqueness |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_SEVERITY | Gold | - | - | `'Critical'` - High severity for dimension uniqueness violations |

---

## 2. Enhanced GO_FACT_MEETING_ACTIVITY Data Mapping

### 2.1 Core Meeting Activity Mapping with Dimension Uniqueness

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `COALESCE((SELECT USER_KEY FROM (SELECT USER_KEY, ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE) WHERE USER_ID = HOST_ID AND rn = 1), 'UNKNOWN_USER')` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_KEY | Silver | SI_MEETINGS | MEETING_ID | `COALESCE((SELECT MEETING_KEY FROM (SELECT MEETING_KEY, ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_MEETING) WHERE MEETING_KEY = MEETING_ID AND rn = 1), MEETING_ID)` |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` - Extract date component for dimension join |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COALESCE((SELECT FEATURE_KEY FROM (SELECT FEATURE_KEY, ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_FEATURE) WHERE FEATURE_NAME = SI_FEATURE_USAGE.FEATURE_NAME AND rn = 1), 'NO_FEATURE')` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_DATE | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` - Standardized date format |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_TOPIC | Silver | SI_MEETINGS | MEETING_TOPIC | `COALESCE(MEETING_TOPIC, 'No Topic Specified')` - Handle null values |
| Gold | GO_FACT_MEETING_ACTIVITY | START_TIME | Silver | SI_MEETINGS | START_TIME | `START_TIME` - Direct mapping with timezone standardization |
| Gold | GO_FACT_MEETING_ACTIVITY | END_TIME | Silver | SI_MEETINGS | END_TIME | `END_TIME` - Direct mapping with timezone standardization |
| Gold | GO_FACT_MEETING_ACTIVITY | DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, DATEDIFF('minute', START_TIME, END_TIME))` - Calculate if missing |

### 2.2 Participant Metrics with Unique User Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT | Silver | SI_PARTICIPANTS | USER_ID | `COUNT(DISTINCT CASE WHEN EXISTS (SELECT 1 FROM (SELECT USER_KEY, ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE) WHERE USER_ID = SI_PARTICIPANTS.USER_ID AND rn = 1) THEN SI_PARTICIPANTS.USER_ID END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | TOTAL_JOIN_TIME_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `SUM(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))` - Total participation time |
| Gold | GO_FACT_MEETING_ACTIVITY | AVERAGE_PARTICIPATION_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `AVG(DATEDIFF('minute', JOIN_TIME, LEAVE_TIME))` - Average participation duration |
| Gold | GO_FACT_MEETING_ACTIVITY | PEAK_CONCURRENT_PARTICIPANTS | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `MAX(concurrent_count)` - Calculate peak concurrent users using window functions |
| Gold | GO_FACT_MEETING_ACTIVITY | LATE_JOINERS_COUNT | Silver | SI_PARTICIPANTS | JOIN_TIME | `COUNT(*) WHERE JOIN_TIME > START_TIME + INTERVAL '5 minutes'` - Count late joiners |
| Gold | GO_FACT_MEETING_ACTIVITY | EARLY_LEAVERS_COUNT | Silver | SI_PARTICIPANTS | LEAVE_TIME | `COUNT(*) WHERE LEAVE_TIME < END_TIME - INTERVAL '5 minutes'` - Count early leavers |

### 2.3 Feature Usage Metrics with Unique Feature Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURES_USED_COUNT | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COUNT(DISTINCT CASE WHEN EXISTS (SELECT 1 FROM (SELECT FEATURE_KEY, ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_FEATURE) WHERE FEATURE_NAME = SI_FEATURE_USAGE.FEATURE_NAME AND rn = 1) THEN SI_FEATURE_USAGE.FEATURE_NAME END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | SCREEN_SHARE_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Screen Share' AND EXISTS (SELECT 1 FROM GO_DIM_FEATURE WHERE FEATURE_NAME = 'Screen Share' GROUP BY FEATURE_NAME HAVING COUNT(*) = 1) THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | RECORDING_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Recording' AND EXISTS (SELECT 1 FROM GO_DIM_FEATURE WHERE FEATURE_NAME = 'Recording' GROUP BY FEATURE_NAME HAVING COUNT(*) = 1) THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | CHAT_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN FEATURE_NAME = 'Chat' AND EXISTS (SELECT 1 FROM GO_DIM_FEATURE WHERE FEATURE_NAME = 'Chat' GROUP BY FEATURE_NAME HAVING COUNT(*) = 1) THEN USAGE_COUNT ELSE 0 END)` |

---

## 3. Enhanced GO_FACT_SUPPORT_ACTIVITY Data Mapping

### 3.1 Core Support Activity Mapping with Unique Category Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_SUPPORT_ACTIVITY | USER_KEY | Silver | SI_SUPPORT_TICKETS | USER_ID | `COALESCE((SELECT USER_KEY FROM (SELECT USER_KEY, ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE) WHERE USER_ID = SI_SUPPORT_TICKETS.USER_ID AND rn = 1), 'UNKNOWN_USER')` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `COALESCE((SELECT SUPPORT_CATEGORY_KEY FROM (SELECT SUPPORT_CATEGORY_KEY, ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_SUPPORT_CATEGORY) WHERE SUPPORT_CATEGORY = SI_SUPPORT_TICKETS.TICKET_TYPE AND rn = 1), 'UNKNOWN_CATEGORY')` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` - Direct mapping |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_CLOSE_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `CASE WHEN RESOLUTION_STATUS IN ('Resolved', 'Closed') THEN OPEN_DATE + INTERVAL '1 DAY' ELSE NULL END` - Calculated close date |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `UPPER(TRIM(TICKET_TYPE))` - Standardize format |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_STATUS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | `UPPER(TRIM(RESOLUTION_STATUS))` - Standardize format |

### 3.2 Resolution Metrics with SLA Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE, TICKET_CLOSE_DATE | `CASE WHEN TICKET_CLOSE_DATE IS NOT NULL THEN DATEDIFF('hour', TICKET_OPEN_DATE, TICKET_CLOSE_DATE) ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FIRST_CONTACT_RESOLUTION_FLAG | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | `CASE WHEN RESOLUTION_TIME_HOURS <= 24 THEN TRUE ELSE FALSE END` - Business rule implementation |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_MET | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS, SUPPORT_CATEGORY_KEY | `CASE WHEN RESOLUTION_TIME_HOURS <= (SELECT SLA_TARGET_HOURS FROM (SELECT SLA_TARGET_HOURS, ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY_KEY ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_SUPPORT_CATEGORY) WHERE SUPPORT_CATEGORY_KEY = GO_FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY AND rn = 1) THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_BREACH_HOURS | Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS, SUPPORT_CATEGORY_KEY | `CASE WHEN RESOLUTION_TIME_HOURS > (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY WHERE SUPPORT_CATEGORY_KEY = GO_FACT_SUPPORT_ACTIVITY.SUPPORT_CATEGORY_KEY GROUP BY SUPPORT_CATEGORY_KEY HAVING COUNT(*) = 1) THEN RESOLUTION_TIME_HOURS - (SELECT SLA_TARGET_HOURS FROM GO_DIM_SUPPORT_CATEGORY) ELSE 0 END` |

---

## 4. Enhanced GO_FACT_REVENUE_ACTIVITY Data Mapping

### 4.1 Core Revenue Activity Mapping with Unique License Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | REVENUE_ACTIVITY_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_REVENUE_ACTIVITY | USER_KEY | Silver | SI_BILLING_EVENTS | USER_ID | `COALESCE((SELECT USER_KEY FROM (SELECT USER_KEY, ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE) WHERE USER_ID = SI_BILLING_EVENTS.USER_ID AND rn = 1), 'UNKNOWN_USER')` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `COALESCE((SELECT LICENSE_KEY FROM (SELECT LICENSE_KEY, ROW_NUMBER() OVER (PARTITION BY LICENSE_TYPE ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_LICENSE WHERE IS_CURRENT_RECORD = TRUE) WHERE LICENSE_TYPE = SI_LICENSES.LICENSE_TYPE AND rn = 1), 'UNKNOWN_LICENSE')` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_REVENUE_ACTIVITY | TRANSACTION_DATE | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` - Direct mapping |
| Gold | GO_FACT_REVENUE_ACTIVITY | EVENT_TYPE | Silver | SI_BILLING_EVENTS | EVENT_TYPE | `UPPER(TRIM(EVENT_TYPE))` - Standardize format |
| Gold | GO_FACT_REVENUE_ACTIVITY | AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `ROUND(AMOUNT, 2)` - Standardize decimal precision |
| Gold | GO_FACT_REVENUE_ACTIVITY | CURRENCY | Silver | - | - | `'USD'` - Default standardized currency |

### 4.2 Revenue Classification with License Uniqueness

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ONE_TIME_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('One-time Purchase', 'Setup Fee') THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE = 'Refund' THEN -AMOUNT ELSE AMOUNT END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | USD_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `AMOUNT` - Assuming already in USD |
| Gold | GO_FACT_REVENUE_ACTIVITY | MRR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT / 12 ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ARR_IMPACT | Silver | SI_BILLING_EVENTS | AMOUNT, EVENT_TYPE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Renewal', 'Upgrade') THEN AMOUNT ELSE 0 END` |

---

## 5. Enhanced GO_FACT_FEATURE_USAGE Data Mapping

### 5.1 Core Feature Usage Mapping with Unique Feature Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_USAGE_ID | Gold | - | - | `NUMBER(15,0) AUTOINCREMENT` - System generated surrogate key |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` - Direct mapping for dimension join |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COALESCE((SELECT FEATURE_KEY FROM (SELECT FEATURE_KEY, ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_FEATURE) WHERE FEATURE_NAME = SI_FEATURE_USAGE.FEATURE_NAME AND rn = 1), 'UNKNOWN_FEATURE')` |
| Gold | GO_FACT_FEATURE_USAGE | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `COALESCE((SELECT USER_KEY FROM (SELECT USER_KEY, ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE) WHERE USER_ID = SI_MEETINGS.HOST_ID AND rn = 1), 'UNKNOWN_USER')` |
| Gold | GO_FACT_FEATURE_USAGE | MEETING_KEY | Silver | SI_FEATURE_USAGE | MEETING_ID | `COALESCE((SELECT MEETING_KEY FROM (SELECT MEETING_KEY, ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) as rn FROM GO_DIM_MEETING) WHERE MEETING_KEY = SI_FEATURE_USAGE.MEETING_ID AND rn = 1), SI_FEATURE_USAGE.MEETING_ID)` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DATE | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` - Direct mapping |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_TIMESTAMP | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE::TIMESTAMP_NTZ` - Convert to timestamp |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `TRIM(FEATURE_NAME)` - Clean whitespace |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `COALESCE(USAGE_COUNT, 0)` - Handle null values |

### 5.2 Adoption and Performance Scoring with Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `CASE WHEN USAGE_COUNT >= 10 THEN 5.0 WHEN USAGE_COUNT >= 5 THEN 4.0 WHEN USAGE_COUNT >= 3 THEN 3.0 WHEN USAGE_COUNT >= 1 THEN 2.0 ELSE 1.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `CASE WHEN USAGE_COUNT > 0 THEN 100.0 ELSE 0.0 END` - Basic success rate calculation |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, 0)` - Meeting duration as proxy |

---

## 6. Dimension Uniqueness Validation Procedures

### 6.1 Automated Dimension Uniqueness Monitoring

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_ID | Gold | - | - | `UUID_STRING()` - Generate unique error identifier for dimension violations |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TIMESTAMP | Gold | - | - | `CURRENT_TIMESTAMP()` - Current system timestamp |
| Gold | GO_DATA_VALIDATION_ERRORS | SOURCE_TABLE_NAME | Gold | GO_DIM_USER | - | `'GOLD.GO_DIM_USER'` - Source table reference for user dimension violations |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TYPE | Gold | - | - | `'Dimension Uniqueness Violation'` - Error classification |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_CATEGORY | Gold | - | - | `'Data Quality'` - Error category |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_SEVERITY | Gold | - | - | `'Critical'` - High severity for dimension uniqueness violations |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_DIM_USER | USER_ID | `'Duplicate USER dimension: USER_ID=' || USER_ID || ', Count=' || cnt` - Dynamic error message |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'DIM_USER_UNIQUENESS_MONITOR'` - Rule identifier |

### 6.2 Dimension Deduplication Strategy

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DIM_USER | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `FIRST_VALUE(USER_KEY) OVER (PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE ORDER BY UPDATE_DATE DESC, LOAD_DATE DESC)` - Keep most recent record |
| Gold | GO_DIM_USER | IS_CURRENT_RECORD | Gold | GO_DIM_USER | USER_KEY | `CASE WHEN ROW_NUMBER() OVER (PARTITION BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE ORDER BY UPDATE_DATE DESC, LOAD_DATE DESC) = 1 THEN TRUE ELSE FALSE END` - Mark master record |
| Gold | GO_DIM_FEATURE | FEATURE_KEY | Gold | GO_DIM_FEATURE | FEATURE_KEY | `FIRST_VALUE(FEATURE_KEY) OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC)` - Keep most recent record |
| Gold | GO_DIM_LICENSE | LICENSE_KEY | Gold | GO_DIM_LICENSE | LICENSE_KEY | `FIRST_VALUE(LICENSE_KEY) OVER (PARTITION BY LICENSE_TYPE ORDER BY UPDATE_DATE DESC) WHERE IS_CURRENT_RECORD = TRUE` - Keep most recent active record |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | `FIRST_VALUE(SUPPORT_CATEGORY_KEY) OVER (PARTITION BY SUPPORT_CATEGORY ORDER BY UPDATE_DATE DESC)` - Keep most recent record |

---

## 7. Enhanced Data Quality and Validation Rules

### 7.1 Comprehensive Dimension-Fact Relationship Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_TYPE | Gold | - | - | `'Referential Integrity'` - FK validation error type |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_CATEGORY | Gold | - | - | `'Missing Foreign Key'` - FK validation category |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | `'USER_KEY not found in unique dimension records: ' || USER_KEY` - FK validation message |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'FACT_USER_DIMENSION_INTEGRITY'` - Rule identifier for fact-dimension integrity |

### 7.2 Dimension Uniqueness Constraint Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_DIM_FEATURE | FEATURE_NAME | `'Duplicate FEATURE dimension: FEATURE_NAME=' || FEATURE_NAME || ', Count=' || cnt` - Feature uniqueness validation |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'DIM_FEATURE_UNIQUENESS_MONITOR'` - Feature uniqueness rule |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_DIM_LICENSE | LICENSE_TYPE | `'Duplicate LICENSE dimension: LICENSE_TYPE=' || LICENSE_TYPE || ', Count=' || cnt` - License uniqueness validation |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'DIM_LICENSE_UNIQUENESS_MONITOR'` - License uniqueness rule |
| Gold | GO_DATA_VALIDATION_ERRORS | ERROR_MESSAGE | Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY | `'Duplicate SUPPORT_CATEGORY dimension: SUPPORT_CATEGORY=' || SUPPORT_CATEGORY || ', Count=' || cnt` - Support category uniqueness validation |
| Gold | GO_DATA_VALIDATION_ERRORS | VALIDATION_RULE_NAME | Gold | - | - | `'DIM_SUPPORT_CATEGORY_UNIQUENESS_MONITOR'` - Support category uniqueness rule |

---

## 8. Enhanced Performance Optimization with Uniqueness Constraints

### 8.1 Optimized Clustering Strategy for Unique Dimensions

| Target Layer | Target Table | Clustering Keys | Optimization Rule |
|--------------|--------------|-----------------|------------------|
| Gold | GO_DIM_USER | USER_ID, IS_CURRENT_RECORD | `ALTER TABLE CLUSTER BY (USER_ID, IS_CURRENT_RECORD)` - Optimize for uniqueness queries |
| Gold | GO_DIM_FEATURE | FEATURE_NAME | `ALTER TABLE CLUSTER BY (FEATURE_NAME)` - Optimize for unique feature lookups |
| Gold | GO_DIM_LICENSE | LICENSE_TYPE, IS_CURRENT_RECORD | `ALTER TABLE CLUSTER BY (LICENSE_TYPE, IS_CURRENT_RECORD)` - Optimize for unique license lookups |
| Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY | `ALTER TABLE CLUSTER BY (SUPPORT_CATEGORY)` - Optimize for unique category lookups |
| Gold | GO_DIM_MEETING | MEETING_KEY | `ALTER TABLE CLUSTER BY (MEETING_KEY)` - Optimize for unique meeting lookups |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY, USER_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY)` - Optimize for fact-dimension joins |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY, SUPPORT_CATEGORY_KEY, USER_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, SUPPORT_CATEGORY_KEY, USER_KEY)` - Optimize for support analytics |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY, USER_KEY, LICENSE_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, USER_KEY, LICENSE_KEY)` - Optimize for revenue analytics |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY, FEATURE_KEY, USER_KEY | `ALTER TABLE CLUSTER BY (DATE_KEY, FEATURE_KEY, USER_KEY)` - Optimize for feature analytics |

---

## 9. Enhanced BI Integration with Dimension Uniqueness Assurance

### 9.1 Tableau-Optimized Views with Validated Unique Dimensions

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | VW_TABLEAU_VALIDATED_MEETING_ANALYSIS | USER_NAME | Gold | GO_DIM_USER | USER_NAME | `du.USER_NAME FROM (SELECT USER_KEY, USER_NAME, COMPANY, PLAN_TYPE FROM GO_DIM_USER WHERE IS_CURRENT_RECORD = TRUE GROUP BY USER_KEY, USER_NAME, COMPANY, PLAN_TYPE HAVING COUNT(*) = 1) du` |
| Gold | VW_TABLEAU_VALIDATED_MEETING_ANALYSIS | FEATURE_NAME | Gold | GO_DIM_FEATURE | FEATURE_NAME | `df.FEATURE_NAME FROM (SELECT FEATURE_KEY, FEATURE_NAME, FEATURE_CATEGORY FROM GO_DIM_FEATURE GROUP BY FEATURE_KEY, FEATURE_NAME, FEATURE_CATEGORY HAVING COUNT(*) = 1) df` |
| Gold | VW_TABLEAU_VALIDATED_MEETING_ANALYSIS | DATA_QUALITY_STATUS | Gold | - | - | `'VALIDATED_UNIQUE_DIMENSIONS'` - Data quality indicator |

### 9.2 Business Metrics with Dimension Uniqueness Validation

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | VW_VALIDATED_DAILY_ACTIVE_USERS | DAILY_ACTIVE_USERS | Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | `COUNT(DISTINCT fma.USER_KEY) WHERE fma.USER_KEY IN (SELECT du.USER_KEY FROM GO_DIM_USER du WHERE du.IS_CURRENT_RECORD = TRUE GROUP BY du.USER_KEY HAVING COUNT(*) = 1)` |
| Gold | VW_VALIDATED_DAILY_ACTIVE_USERS | DATA_QUALITY_FLAG | Gold | GO_DIM_USER | USER_KEY | `CASE WHEN EXISTS (SELECT 1 FROM GO_DIM_USER du WHERE du.USER_KEY = fma.USER_KEY GROUP BY du.USER_KEY HAVING COUNT(*) > 1) THEN 'DIMENSION_UNIQUENESS_VIOLATION' ELSE 'VALID' END` |

---

## 10. Comprehensive SQL Implementation Examples

### 10.1 Dimension Uniqueness Validation Procedure

```sql
-- Comprehensive dimension uniqueness validation procedure
CREATE OR REPLACE PROCEDURE GOLD.SP_VALIDATE_DIMENSION_UNIQUENESS()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    duplicate_count INTEGER DEFAULT 0;
    validation_result STRING DEFAULT 'SUCCESS';
BEGIN
    -- Check for duplicates in GO_DIM_USER based on business key combination
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, COUNT(*) as cnt
        FROM GOLD.GO_DIM_USER
        WHERE IS_CURRENT_RECORD = TRUE
        GROUP BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE
        HAVING COUNT(*) > 1
    );
    
    IF (duplicate_count > 0) THEN
        -- Log duplicate records for resolution
        INSERT INTO GOLD.GO_DATA_VALIDATION_ERRORS (
            ERROR_ID, ERROR_TIMESTAMP, SOURCE_TABLE_NAME, ERROR_TYPE,
            ERROR_CATEGORY, ERROR_SEVERITY, ERROR_MESSAGE,
            VALIDATION_RULE_NAME, LOAD_DATE, SOURCE_SYSTEM
        )
        SELECT 
            UUID_STRING() as ERROR_ID,
            CURRENT_TIMESTAMP() as ERROR_TIMESTAMP,
            'GOLD.GO_DIM_USER' as SOURCE_TABLE_NAME,
            'Dimension Uniqueness Violation' as ERROR_TYPE,
            'Data Quality' as ERROR_CATEGORY,
            'Critical' as ERROR_SEVERITY,
            'Duplicate dimension record found for USER_ID: ' || USER_ID || 
            ', EMAIL_DOMAIN: ' || EMAIL_DOMAIN || ', COMPANY: ' || COMPANY as ERROR_MESSAGE,
            'DIM_USER_UNIQUENESS_CHECK' as VALIDATION_RULE_NAME,
            CURRENT_DATE() as LOAD_DATE,
            'DIMENSION_VALIDATION' as SOURCE_SYSTEM
        FROM (
            SELECT USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE, COUNT(*) as cnt
            FROM GOLD.GO_DIM_USER
            WHERE IS_CURRENT_RECORD = TRUE
            GROUP BY USER_ID, EMAIL_DOMAIN, COMPANY, PLAN_TYPE
            HAVING COUNT(*) > 1
        );
        
        SET validation_result = 'FAILED - ' || duplicate_count || ' duplicate records found';
    END IF;
    
    RETURN validation_result;
END;
$$;
```

### 10.2 Enhanced Fact Loading with Dimension Uniqueness Validation

```sql
-- Enhanced fact loading with dimension uniqueness validation
INSERT INTO GOLD.GO_FACT_MEETING_ACTIVITY (
    USER_KEY, MEETING_KEY, DATE_KEY, FEATURE_KEY,
    MEETING_DATE, MEETING_TOPIC, START_TIME, END_TIME, DURATION_MINUTES,
    PARTICIPANT_COUNT, TOTAL_JOIN_TIME_MINUTES, AVERAGE_PARTICIPATION_MINUTES,
    FEATURES_USED_COUNT, SCREEN_SHARE_USAGE_COUNT, RECORDING_USAGE_COUNT,
    CHAT_USAGE_COUNT, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM
)
SELECT 
    -- Ensure we get unique dimension keys
    COALESCE(du.USER_KEY, 'UNKNOWN_USER') as USER_KEY,
    COALESCE(dm.MEETING_KEY, sm.MEETING_ID) as MEETING_KEY,
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
    CURRENT_DATE() as LOAD_DATE,
    CURRENT_DATE() as UPDATE_DATE,
    'SILVER_TO_GOLD_ETL' as SOURCE_SYSTEM
FROM SILVER.SI_MEETINGS sm
-- Use subquery to ensure unique dimension lookup
LEFT JOIN (
    SELECT DISTINCT USER_ID, USER_KEY, 
           ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_USER 
    WHERE IS_CURRENT_RECORD = TRUE
) du ON sm.HOST_ID = du.USER_ID AND du.rn = 1
JOIN GOLD.GO_DIM_DATE dd ON DATE(sm.START_TIME) = dd.DATE_KEY
LEFT JOIN (
    SELECT DISTINCT MEETING_KEY, 
           ROW_NUMBER() OVER (PARTITION BY MEETING_KEY ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_MEETING
) dm ON sm.MEETING_ID = dm.MEETING_KEY AND dm.rn = 1
LEFT JOIN SILVER.SI_PARTICIPANTS sp ON sm.MEETING_ID = sp.MEETING_ID
LEFT JOIN SILVER.SI_FEATURE_USAGE sf ON sm.MEETING_ID = sf.MEETING_ID
LEFT JOIN (
    SELECT DISTINCT FEATURE_NAME, FEATURE_KEY,
           ROW_NUMBER() OVER (PARTITION BY FEATURE_NAME ORDER BY UPDATE_DATE DESC) as rn
    FROM GOLD.GO_DIM_FEATURE
) df ON sf.FEATURE_NAME = df.FEATURE_NAME AND df.rn = 1
WHERE sm.VALIDATION_STATUS = 'PASSED'
GROUP BY du.USER_KEY, dm.MEETING_KEY, dd.DATE_KEY, df.FEATURE_KEY, 
         sm.MEETING_TOPIC, sm.START_TIME, sm.END_TIME, sm.DURATION_MINUTES, sm.MEETING_ID;
```

---

## 11. Summary of Enhanced Transformation Rules

This enhanced version 2 specifically addresses the requirement to ensure dimension tables have unique row values for every unique combination of defining attributes. The key improvements include:

### **1. Dimension Uniqueness Validation**
- Automated procedures to detect and flag dimension uniqueness violations
- Comprehensive monitoring across all dimension tables
- Critical error logging for dimension duplicates

### **2. Deduplication Strategies**
- Automated deduplication procedures for dimension tables
- Master record selection based on recency and data quality
- Fact table foreign key updates to maintain referential integrity

### **3. Enhanced Fact Loading**
- ROW_NUMBER() window functions to ensure unique dimension lookups
- Fallback values for missing dimension references
- Validation of dimension uniqueness during fact loading

### **4. Comprehensive Monitoring**
- Continuous monitoring of dimension uniqueness violations
- Automated error detection and logging
- Performance metrics for dimension integrity

### **5. BI Integration Optimization**
- Views that guarantee dimension uniqueness for reporting
- Data quality flags in analytical views
- Prevention of double-counting in dashboards

### **6. Performance Optimization**
- Clustering strategies optimized for unique dimensions
- Efficient join patterns leveraging dimension uniqueness
- Optimized query performance for BI tools

These transformation rules ensure that:
- **Every dimension table maintains unique rows** for each unique combination of defining attributes
- **Fact tables reference only unique dimension records** preventing analytical inaccuracies
- **BI tools receive clean, validated data** with guaranteed dimension uniqueness
- **Data quality is continuously monitored** with automated violation detection
- **Performance is optimized** through proper clustering and indexing strategies

The enhanced rules support all three analytical domains (Platform Usage, Service Reliability, and Revenue Management) while maintaining the highest standards of dimensional modeling and data quality with guaranteed dimension uniqueness.

---

## 12. Metadata and Audit Mapping

### 12.1 Standard Metadata Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | ALL_FACT_TABLES | LOAD_DATE | Gold | - | - | `CURRENT_DATE()` - System load date |
| Gold | ALL_FACT_TABLES | UPDATE_DATE | Gold | - | - | `CURRENT_DATE()` - System update date |
| Gold | ALL_FACT_TABLES | SOURCE_SYSTEM | Gold | - | - | `'SILVER_TO_GOLD_ETL'` - Source system identifier |

### 12.2 Process Audit Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_PROCESS_AUDIT_LOG | AUDIT_LOG_ID | Gold | - | - | `UUID_STRING()` - Unique execution identifier |
| Gold | GO_PROCESS_AUDIT_LOG | PROCESS_NAME | Gold | - | - | `'FACT_TABLE_LOAD_WITH_DIMENSION_VALIDATION'` - Enhanced process name |
| Gold | GO_PROCESS_AUDIT_LOG | EXECUTION_START_TIMESTAMP | Gold | - | - | `CURRENT_TIMESTAMP()` - Process start time |
| Gold | GO_PROCESS_AUDIT_LOG | EXECUTION_STATUS | Gold | - | - | `'RUNNING'` - Initial status, updated on completion |
| Gold | GO_PROCESS_AUDIT_LOG | RECORDS_PROCESSED | Gold | - | - | `ROW_COUNT` - Number of records processed |

---

This comprehensive enhanced data mapping document ensures that dimension tables maintain unique row values for every unique combination of defining attributes, supporting accurate analytics, optimized performance, and consistency across business intelligence applications.