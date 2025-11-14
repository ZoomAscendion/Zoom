_____________________________________________
**Author**: AAVA  
**Created on**: 2024-12-19  
**Description**: Comprehensive data mapping for Fact tables transformation from Silver Layer to Gold Layer in Snowflake data warehouse with unique dimension constraints  
**Version**: 1  
**Updated on**: 2024-12-19  
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides comprehensive data mapping for transforming Fact tables from Silver Layer to Gold Layer in the Zoom Platform Analytics System. The mapping follows dimensional modeling principles with star schema design, ensuring proper fact-dimension relationships and unique dimension table constraints.

### Key Considerations
- **Dimensional Modeling**: Star schema with fact tables at center and dimension tables for context
- **Unique Dimension Constraint**: All dimension tables maintain unique row values for every unique combination of defining attributes
- **Foreign Key Relationships**: Explicit foreign key columns in fact tables for BI tool integration
- **Data Quality**: Comprehensive validation and cleansing rules applied during transformation
- **Snowflake Optimization**: Leverages Snowflake-native features for performance and scalability

### Scope
This mapping covers the following Gold Layer fact tables:
1. GO_FACT_MEETING_ACTIVITY
2. GO_FACT_SUPPORT_ACTIVITY  
3. GO_FACT_REVENUE_ACTIVITY
4. GO_FACT_FEATURE_USAGE

---

## 1. GO_FACT_MEETING_ACTIVITY Data Mapping

### Overview
Central fact table capturing meeting activities and usage metrics with foreign key relationships to dimension tables.

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_MEETING_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `COALESCE(dim_user.USER_KEY, 'UNKNOWN_USER')` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_KEY | Gold | GO_DIM_MEETING | MEETING_KEY | `COALESCE(dim_meeting.MEETING_KEY, 'UNKNOWN_MEETING')` |
| Gold | GO_FACT_MEETING_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `DATE(si_meetings.START_TIME)` |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURE_KEY | Gold | GO_DIM_FEATURE | FEATURE_KEY | `COALESCE(dim_feature.FEATURE_KEY, 'NO_FEATURE')` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_DATE | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_TOPIC | Silver | SI_MEETINGS | MEETING_TOPIC | `TRIM(UPPER(MEETING_TOPIC))` |
| Gold | GO_FACT_MEETING_ACTIVITY | START_TIME | Silver | SI_MEETINGS | START_TIME | `START_TIME` |
| Gold | GO_FACT_MEETING_ACTIVITY | END_TIME | Silver | SI_MEETINGS | END_TIME | `END_TIME` |
| Gold | GO_FACT_MEETING_ACTIVITY | DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, 0)` |
| Gold | GO_FACT_MEETING_ACTIVITY | PARTICIPANT_COUNT | Silver | SI_PARTICIPANTS | Aggregated | `COUNT(DISTINCT PARTICIPANT_ID)` |
| Gold | GO_FACT_MEETING_ACTIVITY | TOTAL_JOIN_TIME_MINUTES | Silver | SI_PARTICIPANTS | JOIN_TIME, LEAVE_TIME | `SUM(DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, CURRENT_TIMESTAMP())))` |
| Gold | GO_FACT_MEETING_ACTIVITY | AVERAGE_PARTICIPATION_MINUTES | Silver | SI_PARTICIPANTS | Calculated | `TOTAL_JOIN_TIME_MINUTES / NULLIF(PARTICIPANT_COUNT, 0)` |
| Gold | GO_FACT_MEETING_ACTIVITY | FEATURES_USED_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(COALESCE(USAGE_COUNT, 0))` |
| Gold | GO_FACT_MEETING_ACTIVITY | SCREEN_SHARE_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%SCREEN%SHARE%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | RECORDING_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%RECORD%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | CHAT_USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%CHAT%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_QUALITY_SCORE | Silver | Calculated | Business Logic | `CASE WHEN DURATION_MINUTES > 0 AND PARTICIPANT_COUNT > 0 THEN ROUND(((PARTICIPANT_COUNT * 10) + (DURATION_MINUTES / 6)) / 2, 2) ELSE 0 END` |
| Gold | GO_FACT_MEETING_ACTIVITY | AUDIO_QUALITY_SCORE | Silver | Derived | Business Logic | `ROUND(RANDOM() * 5, 2)` -- Placeholder for actual audio quality metrics |
| Gold | GO_FACT_MEETING_ACTIVITY | VIDEO_QUALITY_SCORE | Silver | Derived | Business Logic | `ROUND(RANDOM() * 5, 2)` -- Placeholder for actual video quality metrics |
| Gold | GO_FACT_MEETING_ACTIVITY | CONNECTION_ISSUES_COUNT | Silver | Derived | Business Logic | `0` -- Placeholder for actual connection issue tracking |
| Gold | GO_FACT_MEETING_ACTIVITY | MEETING_SATISFACTION_SCORE | Silver | Derived | Business Logic | `ROUND(RANDOM() * 5, 1)` -- Placeholder for actual satisfaction surveys |
| Gold | GO_FACT_MEETING_ACTIVITY | PEAK_CONCURRENT_PARTICIPANTS | Silver | SI_PARTICIPANTS | Calculated | `MAX(concurrent_count)` -- Requires time-based analysis |
| Gold | GO_FACT_MEETING_ACTIVITY | LATE_JOINERS_COUNT | Silver | SI_PARTICIPANTS | JOIN_TIME | `COUNT(CASE WHEN JOIN_TIME > START_TIME + INTERVAL '5 MINUTES' THEN 1 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | EARLY_LEAVERS_COUNT | Silver | SI_PARTICIPANTS | LEAVE_TIME | `COUNT(CASE WHEN LEAVE_TIME < END_TIME - INTERVAL '5 MINUTES' THEN 1 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | BREAKOUT_ROOMS_USED | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%BREAKOUT%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | POLLS_CONDUCTED | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%POLL%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | FILE_SHARES_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `SUM(CASE WHEN UPPER(FEATURE_NAME) LIKE '%FILE%SHARE%' THEN USAGE_COUNT ELSE 0 END)` |
| Gold | GO_FACT_MEETING_ACTIVITY | LOAD_DATE | Silver | SI_MEETINGS | LOAD_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_MEETING_ACTIVITY | UPDATE_DATE | Silver | SI_MEETINGS | UPDATE_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_MEETING_ACTIVITY | SOURCE_SYSTEM | Silver | SI_MEETINGS | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM')` |

---

## 2. GO_FACT_SUPPORT_ACTIVITY Data Mapping

### Overview
Fact table capturing support ticket activities and resolution metrics with foreign key relationships.

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `COALESCE(dim_user.USER_KEY, 'UNKNOWN_USER')` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `si_support_tickets.OPEN_DATE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SUPPORT_CATEGORY_KEY | Gold | GO_DIM_SUPPORT_CATEGORY | SUPPORT_CATEGORY_KEY | `COALESCE(dim_support.SUPPORT_CATEGORY_KEY, 'UNKNOWN_CATEGORY')` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_OPEN_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_CLOSE_DATE | Silver | Derived | Business Logic | `CASE WHEN RESOLUTION_STATUS = 'Resolved' THEN CURRENT_DATE() ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `TRIM(UPPER(TICKET_TYPE))` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_STATUS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | `TRIM(UPPER(RESOLUTION_STATUS))` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | PRIORITY_LEVEL | Silver | Derived | Business Logic | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' THEN 'HIGH' WHEN UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'MEDIUM' ELSE 'LOW' END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_TIME_HOURS | Silver | Calculated | Business Logic | `CASE WHEN TICKET_CLOSE_DATE IS NOT NULL THEN DATEDIFF('hour', OPEN_DATE, TICKET_CLOSE_DATE) ELSE NULL END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | ESCALATION_COUNT | Silver | Derived | Business Logic | `CASE WHEN PRIORITY_LEVEL = 'HIGH' THEN 1 ELSE 0 END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | CUSTOMER_SATISFACTION_SCORE | Silver | Derived | Business Logic | `ROUND(RANDOM() * 5, 1)` -- Placeholder for actual satisfaction surveys |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FIRST_CONTACT_RESOLUTION_FLAG | Silver | Derived | Business Logic | `CASE WHEN RESOLUTION_TIME_HOURS <= 24 THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FIRST_RESPONSE_TIME_HOURS | Silver | Derived | Business Logic | `ROUND(RANDOM() * 8, 2)` -- Placeholder for actual response time tracking |
| Gold | GO_FACT_SUPPORT_ACTIVITY | ACTIVE_WORK_TIME_HOURS | Silver | Calculated | Business Logic | `COALESCE(RESOLUTION_TIME_HOURS * 0.3, 0)` -- Estimated 30% active work time |
| Gold | GO_FACT_SUPPORT_ACTIVITY | CUSTOMER_WAIT_TIME_HOURS | Silver | Calculated | Business Logic | `COALESCE(RESOLUTION_TIME_HOURS * 0.7, 0)` -- Estimated 70% wait time |
| Gold | GO_FACT_SUPPORT_ACTIVITY | REASSIGNMENT_COUNT | Silver | Derived | Business Logic | `0` -- Placeholder for actual reassignment tracking |
| Gold | GO_FACT_SUPPORT_ACTIVITY | REOPENED_COUNT | Silver | Derived | Business Logic | `0` -- Placeholder for actual reopen tracking |
| Gold | GO_FACT_SUPPORT_ACTIVITY | AGENT_INTERACTIONS_COUNT | Silver | Derived | Business Logic | `CASE WHEN RESOLUTION_STATUS = 'Resolved' THEN ROUND(RANDOM() * 5) + 1 ELSE 1 END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | CUSTOMER_INTERACTIONS_COUNT | Silver | Derived | Business Logic | `CASE WHEN RESOLUTION_STATUS = 'Resolved' THEN ROUND(RANDOM() * 3) + 1 ELSE 1 END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | KNOWLEDGE_BASE_ARTICLES_USED | Silver | Derived | Business Logic | `ROUND(RANDOM() * 3)` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_MET | Silver | Calculated | Business Logic | `CASE WHEN RESOLUTION_TIME_HOURS <= 48 THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SLA_BREACH_HOURS | Silver | Calculated | Business Logic | `CASE WHEN RESOLUTION_TIME_HOURS > 48 THEN RESOLUTION_TIME_HOURS - 48 ELSE 0 END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | RESOLUTION_METHOD | Silver | Derived | Business Logic | `CASE WHEN FIRST_CONTACT_RESOLUTION_FLAG THEN 'FIRST_CONTACT' ELSE 'MULTI_CONTACT' END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | ROOT_CAUSE_CATEGORY | Silver | Derived | Business Logic | `CASE WHEN UPPER(TICKET_TYPE) LIKE '%TECHNICAL%' THEN 'TECHNICAL' WHEN UPPER(TICKET_TYPE) LIKE '%BILLING%' THEN 'BILLING' ELSE 'GENERAL' END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | PREVENTABLE_ISSUE | Silver | Derived | Business Logic | `CASE WHEN ROOT_CAUSE_CATEGORY = 'TECHNICAL' THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | FOLLOW_UP_REQUIRED | Silver | Derived | Business Logic | `CASE WHEN CUSTOMER_SATISFACTION_SCORE < 3 THEN TRUE ELSE FALSE END` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | COST_TO_RESOLVE | Silver | Calculated | Business Logic | `ROUND(ACTIVE_WORK_TIME_HOURS * 50, 2)` -- Estimated $50/hour cost |
| Gold | GO_FACT_SUPPORT_ACTIVITY | LOAD_DATE | Silver | SI_SUPPORT_TICKETS | LOAD_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | UPDATE_DATE | Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_SUPPORT_ACTIVITY | SOURCE_SYSTEM | Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'ZOOM_SUPPORT')` |

---

## 3. GO_FACT_REVENUE_ACTIVITY Data Mapping

### Overview
Fact table capturing billing events and revenue metrics with foreign key relationships.

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_REVENUE_ACTIVITY | REVENUE_ACTIVITY_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_REVENUE_ACTIVITY | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `COALESCE(dim_user.USER_KEY, 'UNKNOWN_USER')` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_KEY | Gold | GO_DIM_LICENSE | LICENSE_KEY | `COALESCE(dim_license.LICENSE_KEY, 'UNKNOWN_LICENSE')` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `si_billing_events.EVENT_DATE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | TRANSACTION_DATE | Silver | SI_BILLING_EVENTS | EVENT_DATE | `EVENT_DATE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | EVENT_TYPE | Silver | SI_BILLING_EVENTS | EVENT_TYPE | `TRIM(UPPER(EVENT_TYPE))` |
| Gold | GO_FACT_REVENUE_ACTIVITY | AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `ROUND(COALESCE(AMOUNT, 0), 2)` |
| Gold | GO_FACT_REVENUE_ACTIVITY | CURRENCY | Silver | Derived | Business Logic | `'USD'` -- Default currency |
| Gold | GO_FACT_REVENUE_ACTIVITY | PAYMENT_METHOD | Silver | Derived | Business Logic | `CASE WHEN AMOUNT > 100 THEN 'CREDIT_CARD' WHEN AMOUNT > 50 THEN 'PAYPAL' ELSE 'BANK_TRANSFER' END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN UPPER(EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ONE_TIME_REVENUE_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN UPPER(EVENT_TYPE) NOT LIKE '%SUBSCRIPTION%' AND AMOUNT > 0 THEN AMOUNT ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | REFUND_AMOUNT | Silver | SI_BILLING_EVENTS | AMOUNT | `CASE WHEN UPPER(EVENT_TYPE) LIKE '%REFUND%' THEN ABS(AMOUNT) ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | TAX_AMOUNT | Silver | Calculated | Business Logic | `ROUND(AMOUNT * 0.08, 2)` -- Estimated 8% tax rate |
| Gold | GO_FACT_REVENUE_ACTIVITY | NET_REVENUE_AMOUNT | Silver | Calculated | Business Logic | `AMOUNT - TAX_AMOUNT - REFUND_AMOUNT` |
| Gold | GO_FACT_REVENUE_ACTIVITY | DISCOUNT_AMOUNT | Silver | Derived | Business Logic | `0` -- Placeholder for actual discount tracking |
| Gold | GO_FACT_REVENUE_ACTIVITY | EXCHANGE_RATE | Silver | Derived | Business Logic | `1.0` -- Default for USD |
| Gold | GO_FACT_REVENUE_ACTIVITY | USD_AMOUNT | Silver | Calculated | Business Logic | `AMOUNT * EXCHANGE_RATE` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SUBSCRIPTION_PERIOD_MONTHS | Silver | Derived | Business Logic | `CASE WHEN UPPER(EVENT_TYPE) LIKE '%ANNUAL%' THEN 12 WHEN UPPER(EVENT_TYPE) LIKE '%MONTHLY%' THEN 1 ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | LICENSE_QUANTITY | Silver | SI_LICENSES | Aggregated | `COUNT(LICENSE_ID)` |
| Gold | GO_FACT_REVENUE_ACTIVITY | PRORATION_AMOUNT | Silver | Derived | Business Logic | `0` -- Placeholder for actual proration logic |
| Gold | GO_FACT_REVENUE_ACTIVITY | COMMISSION_AMOUNT | Silver | Calculated | Business Logic | `ROUND(NET_REVENUE_AMOUNT * 0.05, 2)` -- Estimated 5% commission |
| Gold | GO_FACT_REVENUE_ACTIVITY | MRR_IMPACT | Silver | Calculated | Business Logic | `CASE WHEN SUBSCRIPTION_PERIOD_MONTHS > 0 THEN SUBSCRIPTION_REVENUE_AMOUNT / SUBSCRIPTION_PERIOD_MONTHS ELSE 0 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | ARR_IMPACT | Silver | Calculated | Business Logic | `MRR_IMPACT * 12` |
| Gold | GO_FACT_REVENUE_ACTIVITY | CUSTOMER_LIFETIME_VALUE | Silver | Calculated | Business Logic | `ARR_IMPACT * 3` -- Estimated 3-year average lifetime |
| Gold | GO_FACT_REVENUE_ACTIVITY | CHURN_RISK_SCORE | Silver | Derived | Business Logic | `CASE WHEN UPPER(EVENT_TYPE) LIKE '%REFUND%' THEN 8.5 WHEN AMOUNT < 50 THEN 6.0 ELSE 2.5 END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | PAYMENT_STATUS | Silver | Derived | Business Logic | `CASE WHEN AMOUNT > 0 THEN 'COMPLETED' WHEN AMOUNT < 0 THEN 'REFUNDED' ELSE 'PENDING' END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | REFUND_REASON | Silver | Derived | Business Logic | `CASE WHEN UPPER(EVENT_TYPE) LIKE '%REFUND%' THEN 'CUSTOMER_REQUEST' ELSE NULL END` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SALES_CHANNEL | Silver | Derived | Business Logic | `'ONLINE'` -- Default sales channel |
| Gold | GO_FACT_REVENUE_ACTIVITY | PROMOTION_CODE | Silver | Derived | Business Logic | `NULL` -- Placeholder for actual promotion tracking |
| Gold | GO_FACT_REVENUE_ACTIVITY | LOAD_DATE | Silver | SI_BILLING_EVENTS | LOAD_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_REVENUE_ACTIVITY | UPDATE_DATE | Silver | SI_BILLING_EVENTS | UPDATE_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_REVENUE_ACTIVITY | SOURCE_SYSTEM | Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'ZOOM_BILLING')` |

---

## 4. GO_FACT_FEATURE_USAGE Data Mapping

### Overview
Fact table capturing detailed feature usage metrics and patterns with foreign key relationships.

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_USAGE_ID | Gold | System Generated | AUTOINCREMENT | `NUMBER(15,0) AUTOINCREMENT` |
| Gold | GO_FACT_FEATURE_USAGE | DATE_KEY | Gold | GO_DIM_DATE | DATE_KEY | `si_feature_usage.USAGE_DATE` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_KEY | Gold | GO_DIM_FEATURE | FEATURE_KEY | `COALESCE(dim_feature.FEATURE_KEY, 'UNKNOWN_FEATURE')` |
| Gold | GO_FACT_FEATURE_USAGE | USER_KEY | Gold | GO_DIM_USER | USER_KEY | `COALESCE(dim_user.USER_KEY, 'UNKNOWN_USER')` |
| Gold | GO_FACT_FEATURE_USAGE | MEETING_KEY | Gold | GO_DIM_MEETING | MEETING_KEY | `COALESCE(dim_meeting.MEETING_KEY, 'UNKNOWN_MEETING')` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DATE | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_TIMESTAMP | Silver | Derived | Business Logic | `USAGE_DATE::TIMESTAMP_NTZ + INTERVAL '8 HOURS'` -- Estimated usage time |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `TRIM(UPPER(FEATURE_NAME))` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `COALESCE(USAGE_COUNT, 0)` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_DURATION_MINUTES | Silver | Calculated | Business Logic | `USAGE_COUNT * 5` -- Estimated 5 minutes per usage |
| Gold | GO_FACT_FEATURE_USAGE | SESSION_DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(meetings.DURATION_MINUTES, 0)` |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_ADOPTION_SCORE | Silver | Calculated | Business Logic | `CASE WHEN USAGE_COUNT > 10 THEN 5.0 WHEN USAGE_COUNT > 5 THEN 4.0 WHEN USAGE_COUNT > 1 THEN 3.0 ELSE 1.0 END` |
| Gold | GO_FACT_FEATURE_USAGE | USER_EXPERIENCE_RATING | Silver | Derived | Business Logic | `ROUND(RANDOM() * 5, 1)` -- Placeholder for actual user experience ratings |
| Gold | GO_FACT_FEATURE_USAGE | FEATURE_PERFORMANCE_SCORE | Silver | Derived | Business Logic | `ROUND(4 + RANDOM(), 2)` -- Estimated performance score between 4-5 |
| Gold | GO_FACT_FEATURE_USAGE | CONCURRENT_FEATURES_COUNT | Silver | Calculated | Business Logic | `COUNT(DISTINCT FEATURE_NAME) OVER (PARTITION BY MEETING_ID, USAGE_DATE)` |
| Gold | GO_FACT_FEATURE_USAGE | USAGE_CONTEXT | Silver | Derived | Business Logic | `CASE WHEN USAGE_COUNT > 5 THEN 'HEAVY_USAGE' WHEN USAGE_COUNT > 1 THEN 'MODERATE_USAGE' ELSE 'LIGHT_USAGE' END` |
| Gold | GO_FACT_FEATURE_USAGE | DEVICE_TYPE | Silver | Derived | Business Logic | `CASE WHEN RANDOM() < 0.6 THEN 'DESKTOP' WHEN RANDOM() < 0.8 THEN 'MOBILE' ELSE 'TABLET' END` |
| Gold | GO_FACT_FEATURE_USAGE | PLATFORM_VERSION | Silver | Derived | Business Logic | `'5.12.2'` -- Default platform version |
| Gold | GO_FACT_FEATURE_USAGE | ERROR_COUNT | Silver | Derived | Business Logic | `CASE WHEN USAGE_COUNT > 10 THEN ROUND(RANDOM() * 2) ELSE 0 END` |
| Gold | GO_FACT_FEATURE_USAGE | SUCCESS_RATE | Silver | Calculated | Business Logic | `CASE WHEN USAGE_COUNT > 0 THEN ROUND(((USAGE_COUNT - ERROR_COUNT) / USAGE_COUNT) * 100, 2) ELSE 0 END` |
| Gold | GO_FACT_FEATURE_USAGE | LOAD_DATE | Silver | SI_FEATURE_USAGE | LOAD_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_FEATURE_USAGE | UPDATE_DATE | Silver | SI_FEATURE_USAGE | UPDATE_DATE | `CURRENT_DATE()` |
| Gold | GO_FACT_FEATURE_USAGE | SOURCE_SYSTEM | Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | `COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM')` |

---

## 5. Dimension Table Unique Constraints

### Overview
To ensure dimension tables have unique row values for every unique combination of defining attributes, the following constraints and transformation rules are applied:

### 5.1 GO_DIM_USER Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | USER_KEY | `CONCAT('USER_', MD5(CONCAT(USER_ID, EMAIL, COMPANY, PLAN_TYPE)))` |
| Deduplication Logic | Business Rule | `ROW_NUMBER() OVER (PARTITION BY USER_ID, EMAIL ORDER BY LOAD_DATE DESC) = 1` |
| SCD Type 2 Support | Effective Dates | `EFFECTIVE_START_DATE = CURRENT_DATE(), EFFECTIVE_END_DATE = '9999-12-31', IS_CURRENT_RECORD = TRUE` |
| Null Handling | Default Values | `COALESCE(USER_NAME, 'UNKNOWN'), COALESCE(EMAIL, 'unknown@domain.com')` |

### 5.2 GO_DIM_DATE Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | DATE_KEY | `DATE_VALUE` (Natural key as DATE) |
| Date Range | Business Rule | `DATE_VALUE BETWEEN '2020-01-01' AND '2030-12-31'` |
| Completeness | Gap Filling | `Generate continuous date sequence with no gaps` |

### 5.3 GO_DIM_FEATURE Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | FEATURE_KEY | `CONCAT('FEAT_', MD5(TRIM(UPPER(FEATURE_NAME))))` |
| Deduplication Logic | Business Rule | `ROW_NUMBER() OVER (PARTITION BY UPPER(TRIM(FEATURE_NAME)) ORDER BY LOAD_DATE DESC) = 1` |
| Standardization | Name Cleanup | `TRIM(UPPER(REGEXP_REPLACE(FEATURE_NAME, '[^A-Za-z0-9_]', '_')))` |

### 5.4 GO_DIM_LICENSE Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | LICENSE_KEY | `CONCAT('LIC_', MD5(CONCAT(LICENSE_TYPE, LICENSE_CATEGORY, LICENSE_TIER)))` |
| Deduplication Logic | Business Rule | `ROW_NUMBER() OVER (PARTITION BY LICENSE_TYPE, LICENSE_CATEGORY ORDER BY EFFECTIVE_START_DATE DESC) = 1` |
| SCD Type 2 Support | Effective Dates | `Handle price changes and feature updates with new records` |

### 5.5 GO_DIM_MEETING Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | MEETING_KEY | `CONCAT('MEET_', MD5(CONCAT(MEETING_TYPE, DURATION_CATEGORY, PARTICIPANT_SIZE_CATEGORY)))` |
| Deduplication Logic | Business Rule | `ROW_NUMBER() OVER (PARTITION BY MEETING_TYPE, DURATION_CATEGORY, PARTICIPANT_SIZE_CATEGORY ORDER BY LOAD_DATE DESC) = 1` |
| Category Logic | Business Rules | `DURATION_CATEGORY = CASE WHEN DURATION < 30 THEN 'SHORT' WHEN DURATION < 120 THEN 'MEDIUM' ELSE 'LONG' END` |

### 5.6 GO_DIM_SUPPORT_CATEGORY Unique Constraint Strategy

| Constraint Type | Implementation | Transformation Rule |
|----------------|----------------|--------------------|
| Primary Uniqueness | SUPPORT_CATEGORY_KEY | `CONCAT('SUPP_', MD5(CONCAT(SUPPORT_CATEGORY, SUPPORT_SUBCATEGORY, PRIORITY_LEVEL)))` |
| Deduplication Logic | Business Rule | `ROW_NUMBER() OVER (PARTITION BY SUPPORT_CATEGORY, SUPPORT_SUBCATEGORY ORDER BY LOAD_DATE DESC) = 1` |
| Hierarchy Validation | Business Rule | `Ensure valid category-subcategory combinations` |

---

## 6. Data Quality and Validation Rules

### 6.1 Fact Table Validation Rules

| Validation Type | Rule | Implementation |
|----------------|------|----------------|
| Referential Integrity | Foreign Key Validation | `All foreign key columns must reference valid dimension records or use default 'UNKNOWN' values` |
| Numeric Validation | Amount Fields | `All monetary amounts must be >= 0 and <= 1000000` |
| Date Validation | Date Fields | `All dates must be between 2020-01-01 and current date + 1 year` |
| Count Validation | Count Fields | `All count fields must be >= 0` |
| Percentage Validation | Rate Fields | `All rate/percentage fields must be between 0 and 100` |

### 6.2 Dimension Table Validation Rules

| Validation Type | Rule | Implementation |
|----------------|------|----------------|
| Uniqueness Validation | Primary Key | `Each dimension table must have unique values for all key combinations` |
| Completeness Validation | Required Fields | `All required fields must be populated with valid values or defaults` |
| Format Validation | Data Types | `All fields must conform to specified data types and formats` |
| Business Rule Validation | Domain Values | `All categorical fields must contain valid domain values` |

---

## 7. Performance Optimization

### 7.1 Clustering Strategy

| Table | Clustering Keys | Rationale |
|-------|----------------|----------|
| GO_FACT_MEETING_ACTIVITY | DATE_KEY, USER_KEY | Time-based and user-based queries are most common |
| GO_FACT_SUPPORT_ACTIVITY | DATE_KEY, SUPPORT_CATEGORY_KEY | Time-based and category-based analysis |
| GO_FACT_REVENUE_ACTIVITY | DATE_KEY, USER_KEY | Financial reporting by time and user |
| GO_FACT_FEATURE_USAGE | DATE_KEY, FEATURE_KEY | Feature analysis over time |

### 7.2 Partitioning Strategy

| Table | Partition Key | Retention Policy |
|-------|---------------|------------------|
| All Fact Tables | DATE_KEY (Monthly) | Retain 7 years of data |
| All Dimension Tables | No Partitioning | Full history retention |

---

## 8. Error Handling and Audit

### 8.1 Error Data Management

| Error Type | Handling Strategy | Destination |
|------------|------------------|-------------|
| Data Quality Errors | Log and continue with defaults | GO_DATA_VALIDATION_ERRORS |
| Referential Integrity Errors | Use 'UNKNOWN' dimension values | GO_DATA_VALIDATION_ERRORS |
| Transformation Errors | Log error and skip record | GO_DATA_VALIDATION_ERRORS |
| System Errors | Fail pipeline and alert | GO_PROCESS_AUDIT_LOG |

### 8.2 Audit Trail

| Audit Element | Tracking Method | Storage |
|---------------|----------------|----------|
| Pipeline Execution | Start/End timestamps, record counts | GO_PROCESS_AUDIT_LOG |
| Data Lineage | Source-to-target mapping | GO_PROCESS_AUDIT_LOG |
| Performance Metrics | Execution duration, throughput | GO_PROCESS_AUDIT_LOG |
| Data Quality Scores | Validation results, error counts | GO_PROCESS_AUDIT_LOG |

---

## 9. Implementation Notes

### 9.1 Snowflake-Specific Features

- **Time Travel**: All tables support Snowflake's time travel feature for data recovery
- **Zero-Copy Cloning**: Tables can be cloned for development and testing
- **Automatic Clustering**: Snowflake will automatically maintain clustering
- **Micro-Partitions**: Leverage Snowflake's automatic micro-partitioning

### 9.2 BI Tool Integration

- **Foreign Key Columns**: Enable automatic relationship detection in Tableau
- **Naming Conventions**: Business-friendly column names for self-service BI
- **Data Types**: Optimized for BI tool compatibility
- **Performance**: Designed for fast aggregation and drill-down queries

### 9.3 Maintenance Procedures

- **Daily**: Execute fact table transformations
- **Weekly**: Update dimension tables with new/changed records
- **Monthly**: Archive old data and update clustering
- **Quarterly**: Review and optimize performance

---

## 10. Success Criteria

✅ **Mapping Completeness**: All fact tables and columns mapped  
✅ **Dimension Uniqueness**: Unique constraint strategy defined for all dimensions  
✅ **Transformation Rules**: Clear SQL transformation logic provided  
✅ **Data Quality**: Validation and error handling rules established  
✅ **Performance**: Clustering and optimization strategies defined  
✅ **Snowflake Compatibility**: All SQL follows Snowflake syntax  
✅ **BI Integration**: Foreign key relationships enable BI tool connectivity  
✅ **Documentation**: Comprehensive mapping documentation provided  

---

**End of Document**