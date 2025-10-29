_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver layer Data Mapping for Zoom Platform Analytics System following Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer in the Medallion architecture implementation for the Zoom Platform Analytics System. The Silver Layer serves as the cleansed and conformed data layer, incorporating necessary data validations, transformations, and business rules to ensure data quality and consistency.

**Key Mapping Approach:**
- **Data Cleansing**: Apply standardization, format validation, and data type conversions
- **Data Validation**: Implement comprehensive validation rules based on business constraints
- **Data Enrichment**: Add calculated fields and derived metrics for enhanced analytics
- **Error Handling**: Capture and track data quality issues in dedicated error tables
- **Audit Trail**: Maintain comprehensive audit logs for data lineage and processing tracking

**Compatibility**: All transformations and validations are designed to be compatible with Snowflake SQL and follow Medallion architecture best practices.

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | TRIM(UPPER(USER_ID)) |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length > 0 | TRIM(INITCAP(USER_NAME)) |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | TRIM(LOWER(EMAIL)) with REGEXP validation |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Length validation | TRIM(INITCAP(COMPANY)) |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in ('Free', 'Basic', 'Pro', 'Enterprise') | TRIM(UPPER(PLAN_TYPE)) |
| Silver | SI_USERS | REGISTRATION_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Not future date | DATE(LOAD_TIMESTAMP) |
| Silver | SI_USERS | LAST_LOGIN_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not future date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_USERS | ACCOUNT_STATUS | Bronze | BZ_USERS | - | Not null | CASE WHEN PLAN_TYPE IS NOT NULL THEN 'Active' ELSE 'Inactive' END |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Bronze | BZ_USERS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.2 SI_MEETINGS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | TRIM(UPPER(MEETING_ID)) |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(HOST_ID)) |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length validation | TRIM(MEETING_TOPIC) |
| Silver | SI_MEETINGS | MEETING_TYPE | Bronze | BZ_MEETINGS | - | Must be in predefined list | CASE WHEN MEETING_TOPIC LIKE '%Webinar%' THEN 'Webinar' ELSE 'Scheduled' END |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp | START_TIME |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Must be >= START_TIME | END_TIME |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | >= 0, <= 1440 minutes | COALESCE(DURATION_MINUTES, DATEDIFF('minute', START_TIME, END_TIME)) |
| Silver | SI_MEETINGS | HOST_NAME | Bronze | BZ_MEETINGS, BZ_USERS | USER_NAME | Not null | Lookup from SI_USERS based on HOST_ID |
| Silver | SI_MEETINGS | MEETING_STATUS | Bronze | BZ_MEETINGS | - | Not null | CASE WHEN END_TIME < CURRENT_TIMESTAMP() THEN 'Completed' ELSE 'Scheduled' END |
| Silver | SI_MEETINGS | RECORDING_STATUS | Bronze | BZ_MEETINGS | - | Must be 'Yes' or 'No' | 'No' (Default, to be enhanced with actual data) |
| Silver | SI_MEETINGS | PARTICIPANT_COUNT | Bronze | BZ_PARTICIPANTS | - | >= 0 | COUNT from BZ_PARTICIPANTS grouped by MEETING_ID |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Bronze | BZ_MEETINGS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.3 SI_PARTICIPANTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | TRIM(UPPER(PARTICIPANT_ID)) |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Must exist in SI_MEETINGS | TRIM(UPPER(MEETING_ID)) |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(USER_ID)) |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Valid timestamp | JOIN_TIME |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Must be >= JOIN_TIME | LEAVE_TIME |
| Silver | SI_PARTICIPANTS | ATTENDANCE_DURATION | Bronze | BZ_PARTICIPANTS | - | >= 0 | DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, CURRENT_TIMESTAMP())) |
| Silver | SI_PARTICIPANTS | PARTICIPANT_ROLE | Bronze | BZ_PARTICIPANTS | - | Must be in predefined list | 'Participant' (Default, to be enhanced with actual data) |
| Silver | SI_PARTICIPANTS | CONNECTION_QUALITY | Bronze | BZ_PARTICIPANTS | - | Must be in predefined list | 'Good' (Default, to be enhanced with actual data) |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Bronze | BZ_PARTICIPANTS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.4 SI_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | TRIM(UPPER(USAGE_ID)) |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Must exist in SI_MEETINGS | TRIM(UPPER(MEETING_ID)) |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length > 0 | TRIM(INITCAP(FEATURE_NAME)) |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | >= 0 | COALESCE(USAGE_COUNT, 0) |
| Silver | SI_FEATURE_USAGE | USAGE_DURATION | Bronze | BZ_FEATURE_USAGE | - | >= 0 | USAGE_COUNT * 1 (Default 1 minute per usage) |
| Silver | SI_FEATURE_USAGE | FEATURE_CATEGORY | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null | CASE WHEN FEATURE_NAME LIKE '%Audio%' THEN 'Audio' WHEN FEATURE_NAME LIKE '%Video%' THEN 'Video' ELSE 'Collaboration' END |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Not future date | USAGE_DATE |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Bronze | BZ_FEATURE_USAGE | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.5 SI_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | TRIM(UPPER(TICKET_ID)) |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(USER_ID)) |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Must be in ('Technical', 'Billing', 'Feature Request', 'Bug Report') | TRIM(INITCAP(TICKET_TYPE)) |
| Silver | SI_SUPPORT_TICKETS | PRIORITY_LEVEL | Bronze | BZ_SUPPORT_TICKETS | - | Must be in ('Low', 'Medium', 'High', 'Critical') | 'Medium' (Default, to be enhanced with actual data) |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Not future date | OPEN_DATE |
| Silver | SI_SUPPORT_TICKETS | CLOSE_DATE | Bronze | BZ_SUPPORT_TICKETS | - | Must be >= OPEN_DATE | NULL (To be populated when ticket is closed) |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Must be in ('Open', 'In Progress', 'Resolved', 'Closed') | TRIM(INITCAP(RESOLUTION_STATUS)) |
| Silver | SI_SUPPORT_TICKETS | ISSUE_DESCRIPTION | Bronze | BZ_SUPPORT_TICKETS | - | Length validation | 'Issue description not available' (Default) |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_NOTES | Bronze | BZ_SUPPORT_TICKETS | - | Length validation | NULL (To be populated when resolved) |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_TIME_HOURS | Bronze | BZ_SUPPORT_TICKETS | - | >= 0 | CASE WHEN CLOSE_DATE IS NOT NULL THEN DATEDIFF('hour', OPEN_DATE, CLOSE_DATE) ELSE NULL END |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Bronze | BZ_SUPPORT_TICKETS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.6 SI_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | TRIM(UPPER(EVENT_ID)) |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(USER_ID)) |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Must be in ('Subscription', 'Upgrade', 'Downgrade', 'Refund') | TRIM(INITCAP(EVENT_TYPE)) |
| Silver | SI_BILLING_EVENTS | TRANSACTION_AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | > 0 for non-refund events | ROUND(AMOUNT, 2) |
| Silver | SI_BILLING_EVENTS | TRANSACTION_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Not future date | EVENT_DATE |
| Silver | SI_BILLING_EVENTS | PAYMENT_METHOD | Bronze | BZ_BILLING_EVENTS | - | Must be in predefined list | 'Credit Card' (Default, to be enhanced with actual data) |
| Silver | SI_BILLING_EVENTS | CURRENCY_CODE | Bronze | BZ_BILLING_EVENTS | - | Valid ISO currency code | 'USD' (Default) |
| Silver | SI_BILLING_EVENTS | INVOICE_NUMBER | Bronze | BZ_BILLING_EVENTS | - | Unique when not null | CONCAT('INV-', EVENT_ID) |
| Silver | SI_BILLING_EVENTS | TRANSACTION_STATUS | Bronze | BZ_BILLING_EVENTS | - | Must be in predefined list | 'Completed' (Default) |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Bronze | BZ_BILLING_EVENTS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.7 SI_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | TRIM(UPPER(LICENSE_ID)) |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(ASSIGNED_TO_USER_ID)) |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Must be in ('Basic', 'Pro', 'Enterprise', 'Add-on') | TRIM(INITCAP(LICENSE_TYPE)) |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Valid date | START_DATE |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not null, Must be > START_DATE | END_DATE |
| Silver | SI_LICENSES | LICENSE_STATUS | Bronze | BZ_LICENSES | - | Must be in predefined list | CASE WHEN END_DATE < CURRENT_DATE() THEN 'Expired' WHEN START_DATE <= CURRENT_DATE() THEN 'Active' ELSE 'Pending' END |
| Silver | SI_LICENSES | ASSIGNED_USER_NAME | Bronze | BZ_LICENSES, BZ_USERS | USER_NAME | Not null | Lookup from SI_USERS based on ASSIGNED_TO_USER_ID |
| Silver | SI_LICENSES | LICENSE_COST | Bronze | BZ_LICENSES | - | >= 0 | CASE LICENSE_TYPE WHEN 'Basic' THEN 14.99 WHEN 'Pro' THEN 19.99 WHEN 'Enterprise' THEN 39.99 ELSE 0 END |
| Silver | SI_LICENSES | RENEWAL_STATUS | Bronze | BZ_LICENSES | - | Must be 'Yes' or 'No' | 'Yes' (Default) |
| Silver | SI_LICENSES | UTILIZATION_PERCENTAGE | Bronze | BZ_LICENSES | - | Between 0 and 100 | 75.0 (Default, to be calculated from actual usage) |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Bronze | BZ_LICENSES | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.8 SI_WEBINARS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_WEBINARS | WEBINAR_ID | Bronze | BZ_WEBINARS | WEBINAR_ID | Not null, Unique | TRIM(UPPER(WEBINAR_ID)) |
| Silver | SI_WEBINARS | HOST_ID | Bronze | BZ_WEBINARS | HOST_ID | Not null, Must exist in SI_USERS | TRIM(UPPER(HOST_ID)) |
| Silver | SI_WEBINARS | WEBINAR_TOPIC | Bronze | BZ_WEBINARS | WEBINAR_TOPIC | Length validation | TRIM(WEBINAR_TOPIC) |
| Silver | SI_WEBINARS | START_TIME | Bronze | BZ_WEBINARS | START_TIME | Not null, Valid timestamp | START_TIME |
| Silver | SI_WEBINARS | END_TIME | Bronze | BZ_WEBINARS | END_TIME | Not null, Must be >= START_TIME | END_TIME |
| Silver | SI_WEBINARS | DURATION_MINUTES | Bronze | BZ_WEBINARS | - | >= 0 | DATEDIFF('minute', START_TIME, END_TIME) |
| Silver | SI_WEBINARS | REGISTRANTS | Bronze | BZ_WEBINARS | REGISTRANTS | >= 0 | COALESCE(REGISTRANTS, 0) |
| Silver | SI_WEBINARS | ATTENDEES | Bronze | BZ_WEBINARS | - | >= 0, <= REGISTRANTS | REGISTRANTS * 0.7 (Default 70% attendance rate) |
| Silver | SI_WEBINARS | ATTENDANCE_RATE | Bronze | BZ_WEBINARS | - | Between 0 and 100 | CASE WHEN REGISTRANTS > 0 THEN (ATTENDEES * 100.0 / REGISTRANTS) ELSE 0 END |
| Silver | SI_WEBINARS | LOAD_TIMESTAMP | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_WEBINARS | UPDATE_TIMESTAMP | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_WEBINARS | SOURCE_SYSTEM | Bronze | BZ_WEBINARS | SOURCE_SYSTEM | Not null | COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') |
| Silver | SI_WEBINARS | DATA_QUALITY_SCORE | Bronze | BZ_WEBINARS | - | Between 0.00 and 1.00 | Calculated based on completeness and validity |
| Silver | SI_WEBINARS | LOAD_DATE | Bronze | BZ_WEBINARS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_WEBINARS | UPDATE_DATE | Bronze | BZ_WEBINARS | UPDATE_TIMESTAMP | Not null | DATE(UPDATE_TIMESTAMP) |

### 2.9 SI_DATA_QUALITY_ERRORS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Bronze | - | - | Not null, Unique | UUID() or auto-generated identifier |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Bronze | - | - | Not null | Name of Bronze table being processed |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_ID | Bronze | - | - | Not null | Primary key of source record with error |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Bronze | - | - | Must be in predefined list | Type of validation error detected |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Bronze | - | - | Not null | Column name where error was found |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Bronze | - | - | Not null | Detailed description of the error |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Bronze | - | - | Must be in ('Critical', 'High', 'Medium', 'Low') | Severity level of the error |
| Silver | SI_DATA_QUALITY_ERRORS | DETECTED_TIMESTAMP | Bronze | - | - | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Bronze | - | - | Must be in predefined list | 'Open' (Default) |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_ACTION | Bronze | - | - | Length validation | NULL (To be populated when resolved) |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_TIMESTAMP | Bronze | - | - | Must be >= DETECTED_TIMESTAMP | NULL (To be populated when resolved) |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLVED_BY | Bronze | - | - | Length validation | NULL (To be populated when resolved) |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_DATE | Bronze | - | - | Not null | CURRENT_DATE() |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_DATE | Bronze | - | - | Not null | CURRENT_DATE() |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Bronze | - | - | Not null | 'DATA_QUALITY_ENGINE' |

### 2.10 SI_PIPELINE_AUDIT Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ID | Bronze | - | - | Not null, Unique | UUID() or auto-generated identifier |
| Silver | SI_PIPELINE_AUDIT | PIPELINE_NAME | Bronze | - | - | Not null | Name of the data pipeline being executed |
| Silver | SI_PIPELINE_AUDIT | START_TIME | Bronze | - | - | Not null | Pipeline execution start timestamp |
| Silver | SI_PIPELINE_AUDIT | END_TIME | Bronze | - | - | Must be >= START_TIME | Pipeline execution end timestamp |
| Silver | SI_PIPELINE_AUDIT | STATUS | Bronze | - | - | Must be in ('Success', 'Failed', 'Partial Success', 'Cancelled') | Execution status |
| Silver | SI_PIPELINE_AUDIT | ERROR_MESSAGE | Bronze | - | - | Length validation | Error details if pipeline failed |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_DURATION_SECONDS | Bronze | - | - | >= 0 | DATEDIFF('second', START_TIME, END_TIME) |
| Silver | SI_PIPELINE_AUDIT | SOURCE_TABLES_PROCESSED | Bronze | - | - | Not null | Comma-separated list of source tables |
| Silver | SI_PIPELINE_AUDIT | TARGET_TABLES_UPDATED | Bronze | - | - | Not null | Comma-separated list of target tables |
| Silver | SI_PIPELINE_AUDIT | RECORDS_PROCESSED | Bronze | - | - | >= 0 | Total number of records processed |
| Silver | SI_PIPELINE_AUDIT | RECORDS_INSERTED | Bronze | - | - | >= 0 | Number of new records inserted |
| Silver | SI_PIPELINE_AUDIT | RECORDS_UPDATED | Bronze | - | - | >= 0 | Number of existing records updated |
| Silver | SI_PIPELINE_AUDIT | RECORDS_REJECTED | Bronze | - | - | >= 0 | Number of records rejected due to quality issues |
| Silver | SI_PIPELINE_AUDIT | EXECUTED_BY | Bronze | - | - | Not null | User or system executing the pipeline |
| Silver | SI_PIPELINE_AUDIT | EXECUTION_ENVIRONMENT | Bronze | - | - | Must be in ('Dev', 'Test', 'Prod') | Environment where pipeline was executed |
| Silver | SI_PIPELINE_AUDIT | DATA_LINEAGE_INFO | Bronze | - | - | Length validation | JSON string with lineage information |
| Silver | SI_PIPELINE_AUDIT | LOAD_DATE | Bronze | - | - | Not null | CURRENT_DATE() |
| Silver | SI_PIPELINE_AUDIT | UPDATE_DATE | Bronze | - | - | Not null | CURRENT_DATE() |
| Silver | SI_PIPELINE_AUDIT | SOURCE_SYSTEM | Bronze | - | - | Not null | 'SILVER_PIPELINE_ENGINE' |

## 3. Data Quality and Validation Summary

### 3.1 Key Validation Rules Applied

1. **Referential Integrity**: All foreign key relationships validated (HOST_ID, USER_ID, MEETING_ID)
2. **Data Type Validation**: Proper data type conversions and format validations
3. **Business Rule Validation**: Enumerated values, date ranges, and logical constraints
4. **Completeness Checks**: Not null validations for critical fields
5. **Format Standardization**: Consistent casing, trimming, and formatting
6. **Range Validations**: Numeric ranges and date boundaries
7. **Uniqueness Constraints**: Primary key and unique identifier validations

### 3.2 Error Handling Approach

1. **Error Capture**: All validation failures captured in SI_DATA_QUALITY_ERRORS table
2. **Severity Classification**: Errors classified by severity (Critical, High, Medium, Low)
3. **Resolution Tracking**: Error resolution status and actions tracked
4. **Audit Trail**: Complete audit trail maintained in SI_PIPELINE_AUDIT table

### 3.3 Data Quality Score Calculation

Data Quality Score is calculated based on:
- **Completeness**: Percentage of non-null values in required fields
- **Validity**: Percentage of values passing format and range validations
- **Consistency**: Percentage of values passing referential integrity checks
- **Accuracy**: Percentage of values passing business rule validations

**Formula**: DQ_Score = (Completeness + Validity + Consistency + Accuracy) / 4

## 4. Implementation Recommendations

### 4.1 Error Handling and Logging

1. **Implement comprehensive error logging** for all validation failures
2. **Create alerting mechanisms** for critical data quality issues
3. **Establish data quality thresholds** for pipeline success/failure determination
4. **Implement retry logic** for transient errors

### 4.2 Performance Optimization

1. **Use incremental loading** strategies where possible
2. **Implement proper indexing** on frequently joined columns
3. **Consider partitioning** large tables by date
4. **Optimize transformation logic** for Snowflake's columnar architecture

### 4.3 Monitoring and Maintenance

1. **Regular data quality monitoring** and reporting
2. **Periodic review and update** of validation rules
3. **Performance monitoring** of transformation processes
4. **Regular cleanup** of error and audit tables

This Silver layer data mapping provides a robust foundation for the Medallion architecture implementation, ensuring data quality, consistency, and usability across the Zoom Platform Analytics System.