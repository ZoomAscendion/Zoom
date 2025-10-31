_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive data mapping for Fact tables in the Gold Layer of Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides comprehensive data mapping for transforming Silver layer tables into Gold layer Fact tables in the Zoom Platform Analytics System. The mapping follows Medallion architecture principles and implements dimensional modeling best practices for analytics and reporting.

### Key Considerations
- **Data Quality**: All transformations include data quality validations with minimum score threshold of 0.8
- **Business Rules**: Comprehensive business logic applied for metric calculations and data enrichment
- **Performance**: Optimized transformations with proper clustering and incremental loading strategies
- **Auditability**: Complete lineage tracking and metadata preservation throughout the transformation process

### Scope
This mapping covers four primary fact tables in the Gold layer:
1. **Go_Fact_Meeting_Activity** - Meeting activities and usage metrics
2. **Go_Fact_Support_Metrics** - Support ticket metrics and resolution tracking
3. **Go_Fact_Revenue_Events** - Billing events and revenue metrics
4. **Go_Fact_Feature_Usage** - Detailed feature usage analytics

---

## 1. Go_Fact_Meeting_Activity Data Mapping

### Source to Target Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Fact_Meeting_Activity | FACT_MEETING_ACTIVITY_ID | Silver | SI_MEETINGS | MEETING_ID | `CONCAT('FACT_MEET_', MEETING_ID, '_', TO_CHAR(START_TIME, 'YYYYMMDD'))` |
| Gold | Go_Fact_Meeting_Activity | DATE_KEY | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` |
| Gold | Go_Fact_Meeting_Activity | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `HOST_ID` |
| Gold | Go_Fact_Meeting_Activity | MEETING_TYPE_KEY | Silver | SI_MEETINGS | MEETING_TYPE | `UPPER(REPLACE(MEETING_TYPE, ' ', '_'))` |
| Gold | Go_Fact_Meeting_Activity | MEETING_DATE | Silver | SI_MEETINGS | START_TIME | `DATE(START_TIME)` |
| Gold | Go_Fact_Meeting_Activity | MEETING_DURATION_MINUTES | Silver | SI_MEETINGS | DURATION_MINUTES | `COALESCE(DURATION_MINUTES, 0)` |
| Gold | Go_Fact_Meeting_Activity | PARTICIPANT_COUNT | Silver | SI_MEETINGS | PARTICIPANT_COUNT | `COALESCE(PARTICIPANT_COUNT, 0)` |
| Gold | Go_Fact_Meeting_Activity | MEETING_TYPE | Silver | SI_MEETINGS | MEETING_TYPE | `MEETING_TYPE` |
| Gold | Go_Fact_Meeting_Activity | RECORDING_ENABLED_FLAG | Silver | SI_MEETINGS | RECORDING_STATUS | `CASE WHEN RECORDING_STATUS = 'Yes' THEN TRUE ELSE FALSE END` |
| Gold | Go_Fact_Meeting_Activity | FEATURE_USAGE_COUNT | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `COALESCE(COUNT(DISTINCT FEATURE_NAME), 0)` |
| Gold | Go_Fact_Meeting_Activity | TOTAL_ATTENDANCE_MINUTES | Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | `COALESCE(SUM(ATTENDANCE_DURATION), 0)` |
| Gold | Go_Fact_Meeting_Activity | HOST_PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `u.PLAN_TYPE` |
| Gold | Go_Fact_Meeting_Activity | MEETING_STATUS | Silver | SI_MEETINGS | MEETING_STATUS | `MEETING_STATUS` |
| Gold | Go_Fact_Meeting_Activity | LOAD_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Meeting_Activity | UPDATE_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Meeting_Activity | SOURCE_SYSTEM | System | System | System | `'SILVER_LAYER'` |

### Business Transformation Rules

**Data Quality Filter:**
```sql
WHERE m.DATA_QUALITY_SCORE >= 0.8
  AND m.MEETING_STATUS = 'Completed'
  AND m.DURATION_MINUTES > 0
```

**Calculated Metrics:**
- **Engagement Rate**: `(TOTAL_ATTENDANCE / (DURATION_MINUTES * PARTICIPANT_COUNT)) * 100`
- **Efficiency Score**: Based on duration and participant count ranges
- **Feature Adoption Level**: Categorized by feature usage count

---

## 2. Go_Fact_Support_Metrics Data Mapping

### Source to Target Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Fact_Support_Metrics | FACT_SUPPORT_METRICS_ID | Silver | SI_SUPPORT_TICKETS | TICKET_ID | `CONCAT('FACT_SUPP_', TICKET_ID, '_', TO_CHAR(OPEN_DATE, 'YYYYMMDD'))` |
| Gold | Go_Fact_Support_Metrics | DATE_KEY | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` |
| Gold | Go_Fact_Support_Metrics | USER_KEY | Silver | SI_SUPPORT_TICKETS | USER_ID | `USER_ID` |
| Gold | Go_Fact_Support_Metrics | SUPPORT_CATEGORY_KEY | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE, PRIORITY_LEVEL | `CONCAT(TICKET_TYPE, '_', PRIORITY_LEVEL)` |
| Gold | Go_Fact_Support_Metrics | TICKET_DATE | Silver | SI_SUPPORT_TICKETS | OPEN_DATE | `OPEN_DATE` |
| Gold | Go_Fact_Support_Metrics | RESOLUTION_TIME_HOURS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | `COALESCE(RESOLUTION_TIME_HOURS, 0)` |
| Gold | Go_Fact_Support_Metrics | TICKET_TYPE | Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | `TICKET_TYPE` |
| Gold | Go_Fact_Support_Metrics | PRIORITY_LEVEL | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | `PRIORITY_LEVEL` |
| Gold | Go_Fact_Support_Metrics | RESOLUTION_STATUS | Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | `RESOLUTION_STATUS` |
| Gold | Go_Fact_Support_Metrics | FIRST_CONTACT_RESOLUTION_FLAG | Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | `CASE WHEN RESOLUTION_TIME_HOURS <= 4 THEN TRUE ELSE FALSE END` |
| Gold | Go_Fact_Support_Metrics | ESCALATION_FLAG | Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL, RESOLUTION_TIME_HOURS | `CASE WHEN (PRIORITY_LEVEL = 'Critical' AND RESOLUTION_TIME_HOURS > 4) OR (PRIORITY_LEVEL = 'High' AND RESOLUTION_TIME_HOURS > 24) OR (PRIORITY_LEVEL = 'Medium' AND RESOLUTION_TIME_HOURS > 72) OR (PRIORITY_LEVEL = 'Low' AND RESOLUTION_TIME_HOURS > 168) THEN TRUE ELSE FALSE END` |
| Gold | Go_Fact_Support_Metrics | CUSTOMER_PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `u.PLAN_TYPE` |
| Gold | Go_Fact_Support_Metrics | SATISFACTION_SCORE | Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | `CASE WHEN RESOLUTION_TIME_HOURS <= 2 THEN 5 WHEN RESOLUTION_TIME_HOURS <= 8 THEN 4 WHEN RESOLUTION_TIME_HOURS <= 24 THEN 3 WHEN RESOLUTION_TIME_HOURS <= 72 THEN 2 ELSE 1 END` |
| Gold | Go_Fact_Support_Metrics | LOAD_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Support_Metrics | UPDATE_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Support_Metrics | SOURCE_SYSTEM | System | System | System | `'SILVER_LAYER'` |

### Business Transformation Rules

**SLA Compliance Logic:**
- **Critical**: 4 hours SLA
- **High**: 24 hours SLA
- **Medium**: 72 hours SLA
- **Low**: 168 hours SLA

**Data Quality Filter:**
```sql
WHERE st.DATA_QUALITY_SCORE >= 0.8
  AND st.RESOLUTION_STATUS IN ('Resolved', 'Closed')
```

---

## 3. Go_Fact_Revenue_Events Data Mapping

### Source to Target Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Fact_Revenue_Events | FACT_REVENUE_EVENTS_ID | Silver | SI_BILLING_EVENTS | EVENT_ID | `CONCAT('FACT_REV_', EVENT_ID, '_', TO_CHAR(TRANSACTION_DATE, 'YYYYMMDD'))` |
| Gold | Go_Fact_Revenue_Events | DATE_KEY | Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | `TRANSACTION_DATE` |
| Gold | Go_Fact_Revenue_Events | USER_KEY | Silver | SI_BILLING_EVENTS | USER_ID | `USER_ID` |
| Gold | Go_Fact_Revenue_Events | LICENSE_KEY | Silver | SI_LICENSES | LICENSE_TYPE | `COALESCE(l.LICENSE_TYPE, 'UNKNOWN')` |
| Gold | Go_Fact_Revenue_Events | TRANSACTION_DATE | Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | `TRANSACTION_DATE` |
| Gold | Go_Fact_Revenue_Events | TRANSACTION_AMOUNT_USD | Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT, CURRENCY_CODE | `CASE WHEN CURRENCY_CODE = 'USD' THEN TRANSACTION_AMOUNT WHEN CURRENCY_CODE = 'EUR' THEN TRANSACTION_AMOUNT * 1.1 WHEN CURRENCY_CODE = 'GBP' THEN TRANSACTION_AMOUNT * 1.25 ELSE TRANSACTION_AMOUNT END` |
| Gold | Go_Fact_Revenue_Events | ORIGINAL_AMOUNT | Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT | `TRANSACTION_AMOUNT` |
| Gold | Go_Fact_Revenue_Events | CURRENCY_CODE | Silver | SI_BILLING_EVENTS | CURRENCY_CODE | `CURRENCY_CODE` |
| Gold | Go_Fact_Revenue_Events | EVENT_TYPE | Silver | SI_BILLING_EVENTS | EVENT_TYPE | `EVENT_TYPE` |
| Gold | Go_Fact_Revenue_Events | PAYMENT_METHOD | Silver | SI_BILLING_EVENTS | PAYMENT_METHOD | `PAYMENT_METHOD` |
| Gold | Go_Fact_Revenue_Events | LICENSE_TYPE | Silver | SI_LICENSES | LICENSE_TYPE | `COALESCE(l.LICENSE_TYPE, 'UNKNOWN')` |
| Gold | Go_Fact_Revenue_Events | CUSTOMER_PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `u.PLAN_TYPE` |
| Gold | Go_Fact_Revenue_Events | TRANSACTION_STATUS | Silver | SI_BILLING_EVENTS | TRANSACTION_STATUS | `TRANSACTION_STATUS` |
| Gold | Go_Fact_Revenue_Events | MRR_IMPACT | Silver | SI_BILLING_EVENTS | EVENT_TYPE, TRANSACTION_AMOUNT, CURRENCY_CODE | `CASE WHEN EVENT_TYPE IN ('Subscription', 'Upgrade') THEN [USD_CONVERTED_AMOUNT] WHEN EVENT_TYPE IN ('Downgrade', 'Refund') THEN -1 * [USD_CONVERTED_AMOUNT] ELSE 0 END` |
| Gold | Go_Fact_Revenue_Events | LOAD_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Revenue_Events | UPDATE_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Revenue_Events | SOURCE_SYSTEM | System | System | System | `'SILVER_LAYER'` |

### Business Transformation Rules

**Currency Standardization:**
- All amounts converted to USD using simplified exchange rates
- EUR: 1.1 multiplier
- GBP: 1.25 multiplier
- Other currencies: No conversion (use original amount)

**Revenue Recognition:**
- **New Customer Revenue**: First transaction for user
- **Expansion Revenue**: Upgrade events
- **Renewal Revenue**: Subscription renewals
- **Contraction Revenue**: Downgrades and refunds

**Data Quality Filter:**
```sql
WHERE be.DATA_QUALITY_SCORE >= 0.8
  AND be.TRANSACTION_STATUS = 'Completed'
```

---

## 4. Go_Fact_Feature_Usage Data Mapping

### Source to Target Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Fact_Feature_Usage | FACT_FEATURE_USAGE_ID | Silver | SI_FEATURE_USAGE | USAGE_ID | `CONCAT('FACT_FEAT_', USAGE_ID, '_', TO_CHAR(USAGE_DATE, 'YYYYMMDD'))` |
| Gold | Go_Fact_Feature_Usage | DATE_KEY | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` |
| Gold | Go_Fact_Feature_Usage | USER_KEY | Silver | SI_MEETINGS | HOST_ID | `m.HOST_ID` |
| Gold | Go_Fact_Feature_Usage | FEATURE_KEY | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `UPPER(REPLACE(FEATURE_NAME, ' ', '_'))` |
| Gold | Go_Fact_Feature_Usage | USAGE_DATE | Silver | SI_FEATURE_USAGE | USAGE_DATE | `USAGE_DATE` |
| Gold | Go_Fact_Feature_Usage | FEATURE_NAME | Silver | SI_FEATURE_USAGE | FEATURE_NAME | `FEATURE_NAME` |
| Gold | Go_Fact_Feature_Usage | FEATURE_CATEGORY | Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | `FEATURE_CATEGORY` |
| Gold | Go_Fact_Feature_Usage | USAGE_COUNT | Silver | SI_FEATURE_USAGE | USAGE_COUNT | `USAGE_COUNT` |
| Gold | Go_Fact_Feature_Usage | USAGE_DURATION_MINUTES | Silver | SI_FEATURE_USAGE | USAGE_DURATION | `COALESCE(USAGE_DURATION, 0)` |
| Gold | Go_Fact_Feature_Usage | MEETING_TYPE | Silver | SI_MEETINGS | MEETING_TYPE | `m.MEETING_TYPE` |
| Gold | Go_Fact_Feature_Usage | USER_PLAN_TYPE | Silver | SI_USERS | PLAN_TYPE | `u.PLAN_TYPE` |
| Gold | Go_Fact_Feature_Usage | PARTICIPANT_COUNT | Silver | SI_MEETINGS | PARTICIPANT_COUNT | `COALESCE(m.PARTICIPANT_COUNT, 0)` |
| Gold | Go_Fact_Feature_Usage | LOAD_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Feature_Usage | UPDATE_DATE | System | System | System | `CURRENT_DATE()` |
| Gold | Go_Fact_Feature_Usage | SOURCE_SYSTEM | System | System | System | `'SILVER_LAYER'` |

### Business Transformation Rules

**Feature Adoption Classification:**
- **High Adoption**: >= 50% user adoption rate
- **Growing**: 20-49% user adoption rate
- **Emerging**: 5-19% user adoption rate
- **Experimental**: < 5% user adoption rate

**Usage Intensity:**
- **High Intensity**: >= 10 minutes average usage
- **Medium Intensity**: 3-9 minutes average usage
- **Low Intensity**: < 3 minutes average usage

**Data Quality Filter:**
```sql
WHERE fu.DATA_QUALITY_SCORE >= 0.8
  AND fu.USAGE_COUNT > 0
```

---

## Data Quality and Validation Framework

### Cross-Fact Table Validation

#### Referential Integrity Checks

| Validation Rule | Description | SQL Logic |
|-----------------|-------------|----------|
| User Key Validation | Ensure all USER_KEY values exist in dimension | `LEFT JOIN GOLD.Go_Dim_User ON fact.USER_KEY = dim.USER_BUSINESS_KEY` |
| Date Key Validation | Ensure all DATE_KEY values are valid dates | `WHERE DATE_KEY IS NOT NULL AND DATE_KEY >= '2020-01-01'` |
| Positive Metrics | Ensure numeric measures are non-negative where applicable | `WHERE MEETING_DURATION_MINUTES >= 0 AND PARTICIPANT_COUNT >= 0` |
| Status Consistency | Validate status field values against allowed lists | `WHERE MEETING_STATUS IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')` |

#### Business Rule Validations

| Rule Name | Description | Implementation |
|-----------|-------------|----------------|
| Meeting Duration Positive | Meeting duration must be positive for completed meetings | `MEETING_DURATION_MINUTES > 0 WHERE MEETING_STATUS = 'Completed'` |
| Revenue Positive for Subscriptions | Subscription events must have positive amounts | `TRANSACTION_AMOUNT_USD > 0 WHERE EVENT_TYPE = 'Subscription'` |
| Support Resolution Time Positive | Resolution time must be positive for resolved tickets | `RESOLUTION_TIME_HOURS > 0 WHERE RESOLUTION_STATUS IN ('Resolved', 'Closed')` |
| Feature Usage Count Positive | Feature usage count must be positive | `USAGE_COUNT > 0` |

---

## Performance Optimization Guidelines

### Clustering Recommendations

| Fact Table | Primary Clustering Key | Secondary Clustering Key | Rationale |
|------------|----------------------|-------------------------|----------|
| Go_Fact_Meeting_Activity | DATE_KEY | USER_KEY | Time-based queries are most common |
| Go_Fact_Support_Metrics | DATE_KEY | SUPPORT_CATEGORY_KEY | Support reporting by time and category |
| Go_Fact_Revenue_Events | DATE_KEY | LICENSE_KEY | Financial reporting by time and license |
| Go_Fact_Feature_Usage | DATE_KEY | FEATURE_KEY | Feature analytics by time and feature |

### Incremental Loading Strategy

**Implementation Pattern:**
```sql
MERGE INTO GOLD.[FACT_TABLE] AS target
USING (
    -- Source query with incremental filter
    SELECT * FROM SILVER.[SOURCE_TABLE]
    WHERE UPDATE_DATE >= DATEADD('day', -1, CURRENT_DATE())
      AND DATA_QUALITY_SCORE >= 0.8
) AS source
ON target.[FACT_ID] = source.[CALCULATED_FACT_ID]
WHEN MATCHED THEN UPDATE SET [columns]
WHEN NOT MATCHED THEN INSERT [columns]
```

---

## Monitoring and Data Quality Metrics

### Automated Quality Checks

| Metric | Threshold | Action |
|--------|-----------|--------|
| Data Quality Score | >= 95% | Continue processing |
| Record Count Variance | <= 10% day-over-day | Alert if exceeded |
| Null Key Values | 0% | Fail pipeline if found |
| Duplicate Fact IDs | 0% | Fail pipeline if found |
| Cross-table Consistency | >= 99% | Alert if referential integrity issues |

### Pipeline Health Dashboard

**Key Metrics to Monitor:**
- Daily record counts by fact table
- Data quality score trends
- Processing duration and performance
- Error rates and resolution status
- Business metric validation results

---

## Conclusion

This comprehensive data mapping provides a robust framework for transforming Silver layer data into Gold layer fact tables optimized for analytics and reporting. The mapping ensures:

✅ **Data Quality**: Comprehensive validation and cleansing processes
✅ **Performance**: Optimized clustering and incremental loading strategies
✅ **Consistency**: Standardized transformation patterns across all fact tables
✅ **Scalability**: Efficient processing methods for growing data volumes
✅ **Monitoring**: Automated quality checks and alerting mechanisms
✅ **Auditability**: Complete lineage tracking and metadata preservation

Implementing these mappings will result in reliable, well-structured fact tables that support accurate business intelligence and analytics for the Zoom Platform Analytics System following Medallion architecture best practices.