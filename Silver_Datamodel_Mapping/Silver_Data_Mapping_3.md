_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Silver Layer in Zoom Platform Analytics System Medallion architecture with enhanced DQ checks for numeric field text unit cleaning and DD/MM/YYYY date format conversion
## *Version*: 3 
## *Updated on*: 
## *Changes*: Added two new critical DQ checks - SI_MEETINGS Section 2.8 for numeric field text unit cleaning ("108 mins" error) and SI_LICENSES Section 7.6 for DD/MM/YYYY date format conversion ("27/08/2024" error)
## *Reason*: Address failing models due to "108 mins" error in DURATION_MINUTES field and "27/08/2024" error in date fields, both classified as Critical (P1) checks with comprehensive error logging to SI_AUDIT_LOG
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following Medallion architecture principles. The mapping incorporates necessary cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

The Silver Layer serves as the "single source of truth" by applying data quality checks, standardization, and business rule validations to the raw data from the Bronze Layer. All transformations are designed to be compatible with Snowflake and support advanced analytics and reporting needs.

**Version 3 Updates**: This version includes two new critical DQ checks addressing specific format conversion issues:
1. **SI_MEETINGS Section 2.8**: Numeric field text unit cleaning to handle "108 mins" error in DURATION_MINUTES field
2. **SI_LICENSES Section 7.6**: DD/MM/YYYY date format conversion to handle "27/08/2024" error in date fields

Both checks are classified as Critical (P1) and include comprehensive error logging to SI_AUDIT_LOG as specified in the DQ recommendations.

## 2. Data Mapping for the Silver Layer

### 2.1 SI_USERS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_USERS | USER_ID | Bronze | BZ_USERS | USER_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_USERS | USER_NAME | Bronze | BZ_USERS | USER_NAME | Not null, Length <= 255 | TRIM() and standardize case |
| Silver | SI_USERS | EMAIL | Bronze | BZ_USERS | EMAIL | Not null, Valid email format | LOWER(TRIM()) and email format validation using REGEXP_LIKE |
| Silver | SI_USERS | COMPANY | Bronze | BZ_USERS | COMPANY | Length <= 255 | TRIM() and standardize case |
| Silver | SI_USERS | PLAN_TYPE | Bronze | BZ_USERS | PLAN_TYPE | Must be in ('Free', 'Basic', 'Pro', 'Enterprise') | Standardize to predefined values, default to 'Free' if null |
| Silver | SI_USERS | LOAD_TIMESTAMP | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_USERS | UPDATE_TIMESTAMP | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_USERS | SOURCE_SYSTEM | Bronze | BZ_USERS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_USERS | LOAD_DATE | Bronze | BZ_USERS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_USERS | UPDATE_DATE | Bronze | BZ_USERS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_USERS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validation results |
| Silver | SI_USERS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results |

### 2.2 SI_MEETINGS Table Mapping (Enhanced with Numeric Field Text Unit Cleaning - Critical P1)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length <= 500 | TRIM() and sanitize for PII |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp, EST format validation | **Enhanced**: Validate EST timezone format using REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'), Convert EST to UTC using CONVERT_TIMEZONE('America/New_York', 'UTC', TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')) |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Must be > START_TIME, EST format validation | **Enhanced**: Validate EST timezone format using REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'), Convert EST to UTC with logic validation |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | **Critical P1**: Not null, Range 0-1440, Must match calculated duration, Clean text units from numeric fields | **NEW CRITICAL DQ CHECK**: TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) AS CLEAN_DURATION_MINUTES. Log invalid conversions to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE'. Validate against DATEDIFF('minute', converted_START_TIME, converted_END_TIME) after cleaning |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness, validation results, timestamp format compliance, and numeric field cleaning success |
| Silver | SI_MEETINGS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results including EST timezone format validation and numeric field cleaning |

### 2.3 SI_PARTICIPANTS Table Mapping (Enhanced with MM/DD/YYYY HH:MM Format Validation)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PARTICIPANTS | PARTICIPANT_ID | Bronze | BZ_PARTICIPANTS | PARTICIPANT_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_PARTICIPANTS | MEETING_ID | Bronze | BZ_PARTICIPANTS | MEETING_ID | Not null, Must exist in SI_MEETINGS | Direct copy with referential integrity check |
| Silver | SI_PARTICIPANTS | USER_ID | Bronze | BZ_PARTICIPANTS | USER_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_PARTICIPANTS | JOIN_TIME | Bronze | BZ_PARTICIPANTS | JOIN_TIME | Not null, Must be >= meeting START_TIME, MM/DD/YYYY HH:MM format validation | **Enhanced**: Validate MM/DD/YYYY HH:MM format using REGEXP_LIKE(JOIN_TIME::STRING, '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'), Convert using TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI'), Validate boundary with meeting times |
| Silver | SI_PARTICIPANTS | LEAVE_TIME | Bronze | BZ_PARTICIPANTS | LEAVE_TIME | Not null, Must be > JOIN_TIME and <= meeting END_TIME, MM/DD/YYYY HH:MM format validation | **Enhanced**: Validate MM/DD/YYYY HH:MM format using REGEXP_LIKE(LEAVE_TIME::STRING, '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$'), Convert using TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI'), Validate boundary with meeting times |
| Silver | SI_PARTICIPANTS | LOAD_TIMESTAMP | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_PARTICIPANTS | UPDATE_TIMESTAMP | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_PARTICIPANTS | SOURCE_SYSTEM | Bronze | BZ_PARTICIPANTS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_PARTICIPANTS | LOAD_DATE | Bronze | BZ_PARTICIPANTS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_PARTICIPANTS | UPDATE_DATE | Bronze | BZ_PARTICIPANTS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_PARTICIPANTS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness, validation results, and timestamp format compliance |
| Silver | SI_PARTICIPANTS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results including MM/DD/YYYY HH:MM format validation |

### 2.4 SI_FEATURE_USAGE Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_FEATURE_USAGE | USAGE_ID | Bronze | BZ_FEATURE_USAGE | USAGE_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_FEATURE_USAGE | MEETING_ID | Bronze | BZ_FEATURE_USAGE | MEETING_ID | Not null, Must exist in SI_MEETINGS | Direct copy with referential integrity check |
| Silver | SI_FEATURE_USAGE | FEATURE_NAME | Bronze | BZ_FEATURE_USAGE | FEATURE_NAME | Not null, Length <= 100 | UPPER(TRIM()) for standardized naming |
| Silver | SI_FEATURE_USAGE | USAGE_COUNT | Bronze | BZ_FEATURE_USAGE | USAGE_COUNT | Not null, Non-negative integer | Validate >= 0 |
| Silver | SI_FEATURE_USAGE | USAGE_DATE | Bronze | BZ_FEATURE_USAGE | USAGE_DATE | Not null, Must align with meeting date | Validate DATE matches DATE(meeting.START_TIME) |
| Silver | SI_FEATURE_USAGE | LOAD_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_FEATURE_USAGE | UPDATE_TIMESTAMP | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_FEATURE_USAGE | SOURCE_SYSTEM | Bronze | BZ_FEATURE_USAGE | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_FEATURE_USAGE | LOAD_DATE | Bronze | BZ_FEATURE_USAGE | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_FEATURE_USAGE | UPDATE_DATE | Bronze | BZ_FEATURE_USAGE | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_FEATURE_USAGE | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validation results |
| Silver | SI_FEATURE_USAGE | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results |

### 2.5 SI_SUPPORT_TICKETS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_SUPPORT_TICKETS | TICKET_ID | Bronze | BZ_SUPPORT_TICKETS | TICKET_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_SUPPORT_TICKETS | USER_ID | Bronze | BZ_SUPPORT_TICKETS | USER_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_SUPPORT_TICKETS | TICKET_TYPE | Bronze | BZ_SUPPORT_TICKETS | TICKET_TYPE | Not null, Length <= 100 | UPPER(TRIM()) for standardized categories |
| Silver | SI_SUPPORT_TICKETS | RESOLUTION_STATUS | Bronze | BZ_SUPPORT_TICKETS | RESOLUTION_STATUS | Not null, Must be in ('Open', 'In Progress', 'Resolved', 'Closed') | Standardize to predefined values |
| Silver | SI_SUPPORT_TICKETS | OPEN_DATE | Bronze | BZ_SUPPORT_TICKETS | OPEN_DATE | Not null, Must not be future date | Validate <= CURRENT_DATE() |
| Silver | SI_SUPPORT_TICKETS | LOAD_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_SUPPORT_TICKETS | SOURCE_SYSTEM | Bronze | BZ_SUPPORT_TICKETS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_SUPPORT_TICKETS | LOAD_DATE | Bronze | BZ_SUPPORT_TICKETS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_SUPPORT_TICKETS | UPDATE_DATE | Bronze | BZ_SUPPORT_TICKETS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_SUPPORT_TICKETS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validation results |
| Silver | SI_SUPPORT_TICKETS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results |

### 2.6 SI_BILLING_EVENTS Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_BILLING_EVENTS | EVENT_ID | Bronze | BZ_BILLING_EVENTS | EVENT_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_BILLING_EVENTS | USER_ID | Bronze | BZ_BILLING_EVENTS | USER_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_BILLING_EVENTS | EVENT_TYPE | Bronze | BZ_BILLING_EVENTS | EVENT_TYPE | Not null, Length <= 100 | UPPER(TRIM()) for standardized categories |
| Silver | SI_BILLING_EVENTS | AMOUNT | Bronze | BZ_BILLING_EVENTS | AMOUNT | Not null, Positive number with 2 decimal precision | Validate > 0 and ROUND(amount, 2) |
| Silver | SI_BILLING_EVENTS | EVENT_DATE | Bronze | BZ_BILLING_EVENTS | EVENT_DATE | Not null, Must not be future date | Validate <= CURRENT_DATE() |
| Silver | SI_BILLING_EVENTS | LOAD_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_BILLING_EVENTS | UPDATE_TIMESTAMP | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_BILLING_EVENTS | SOURCE_SYSTEM | Bronze | BZ_BILLING_EVENTS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_BILLING_EVENTS | LOAD_DATE | Bronze | BZ_BILLING_EVENTS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_BILLING_EVENTS | UPDATE_DATE | Bronze | BZ_BILLING_EVENTS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_BILLING_EVENTS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validation results |
| Silver | SI_BILLING_EVENTS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results |

### 2.7 SI_LICENSES Table Mapping (Enhanced with DD/MM/YYYY Date Format Conversion - Critical P1)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not null, Length <= 100 | UPPER(TRIM()) for standardized categories |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | **Critical P1**: Not null, Must be <= END_DATE, DD/MM/YYYY format conversion | **NEW CRITICAL DQ CHECK**: TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') AS CLEAN_START_DATE. Log invalid conversions to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE'. Validate chronological order after conversion |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | **Critical P1**: Not null, Must be >= START_DATE, DD/MM/YYYY format conversion | **NEW CRITICAL DQ CHECK**: TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') AS CLEAN_END_DATE. Log invalid conversions to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE'. Validate chronological order after conversion |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness, validation results, and date format conversion success |
| Silver | SI_LICENSES | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results including DD/MM/YYYY date format conversion |

### 2.8 SI_DATA_QUALITY_ERRORS Table Mapping (Error Data Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Generated | N/A | N/A | Not null, Unique | Generate UUID for each error record |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Calculated | N/A | N/A | Not null | Set to Bronze table name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_KEY | Calculated | N/A | N/A | Not null | Set to primary key value of failed record |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Calculated | N/A | N/A | Not null | Set based on validation failure type (including 'FORMAT_CONVERSION_FAILURE') |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_CATEGORY | Calculated | N/A | N/A | Not null | Categorize as 'VALIDATION', 'TRANSFORMATION', 'BUSINESS_RULE', 'TIMESTAMP_FORMAT', 'NUMERIC_CLEANING', 'DATE_FORMAT' |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Calculated | N/A | N/A | Not null | Detailed description of validation failure including format conversion issues |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Calculated | N/A | N/A | Not null | Column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_VALUE | Calculated | N/A | N/A | Not null | Actual value that failed validation |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Calculated | N/A | N/A | Must be in ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') | Set based on business impact |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() when error detected |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Generated | N/A | N/A | Default 'OPEN' | Set to 'OPEN' initially |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_NOTES | Generated | N/A | N/A | Optional | Initially null |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Calculated | N/A | N/A | Not null | Set to source system of failed record |

### 2.9 SI_AUDIT_LOG Table Mapping (Independent Silver Audit Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_AUDIT_LOG | AUDIT_ID | Generated | N/A | N/A | Not null, Unique | Generate UUID for each audit record |
| Silver | SI_AUDIT_LOG | TABLE_NAME | Generated | N/A | N/A | Not null | Set to Silver table name where operation occurred |
| Silver | SI_AUDIT_LOG | COLUMN_NAME | Generated | N/A | N/A | Not null | Set to column name where operation occurred |
| Silver | SI_AUDIT_LOG | RECORD_ID | Generated | N/A | N/A | Not null | Set to primary key value of affected record |
| Silver | SI_AUDIT_LOG | ERROR_TYPE | Generated | N/A | N/A | Not null | Set to specific error type (e.g., 'FORMAT_CONVERSION_FAILURE') |
| Silver | SI_AUDIT_LOG | ERROR_DESCRIPTION | Generated | N/A | N/A | Not null | Detailed description of the operation or error |
| Silver | SI_AUDIT_LOG | ORIGINAL_VALUE | Generated | N/A | N/A | Optional | Original value before transformation |
| Silver | SI_AUDIT_LOG | AUDIT_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() when audit record created |
| Silver | SI_AUDIT_LOG | OPERATION_TYPE | Generated | N/A | N/A | Not null | Type of operation ('INSERT', 'UPDATE', 'DELETE', 'VALIDATION') |
| Silver | SI_AUDIT_LOG | PROCESSED_BY | Generated | N/A | N/A | Not null | User or system that performed the operation |
| Silver | SI_AUDIT_LOG | SOURCE_SYSTEM | Generated | N/A | N/A | Not null | Source system identifier |

### 2.10 SI_PIPELINE_EXECUTION_LOG Table Mapping (Audit Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_ID | Generated | N/A | N/A | Not null, Unique | Generate UUID for each pipeline execution |
| Silver | SI_PIPELINE_EXECUTION_LOG | PIPELINE_NAME | Generated | N/A | N/A | Not null | Set to specific pipeline name (e.g., 'BRONZE_TO_SILVER_USERS') |
| Silver | SI_PIPELINE_EXECUTION_LOG | PIPELINE_TYPE | Generated | N/A | N/A | Not null | Set to 'BRONZE_TO_SILVER' |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_START_TIME | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() at pipeline start |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_END_TIME | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() at pipeline completion |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_DURATION_SECONDS | Calculated | N/A | N/A | Not null, Positive number | DATEDIFF('second', EXECUTION_START_TIME, EXECUTION_END_TIME) |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_STATUS | Generated | N/A | N/A | Must be in ('SUCCESS', 'FAILED', 'WARNING') | Set based on pipeline execution result |
| Silver | SI_PIPELINE_EXECUTION_LOG | SOURCE_TABLE | Generated | N/A | N/A | Not null | Set to Bronze table name being processed |
| Silver | SI_PIPELINE_EXECUTION_LOG | TARGET_TABLE | Generated | N/A | N/A | Not null | Set to Silver table name being populated |
| Silver | SI_PIPELINE_EXECUTION_LOG | RECORDS_PROCESSED | Calculated | N/A | N/A | Not null, Non-negative | Count of records processed from Bronze |
| Silver | SI_PIPELINE_EXECUTION_LOG | RECORDS_SUCCESS | Calculated | N/A | N/A | Not null, Non-negative | Count of records successfully loaded to Silver |
| Silver | SI_PIPELINE_EXECUTION_LOG | RECORDS_FAILED | Calculated | N/A | N/A | Not null, Non-negative | Count of records that failed validation |
| Silver | SI_PIPELINE_EXECUTION_LOG | RECORDS_SKIPPED | Calculated | N/A | N/A | Not null, Non-negative | Count of records skipped due to business rules |
| Silver | SI_PIPELINE_EXECUTION_LOG | DATA_QUALITY_SCORE_AVG | Calculated | N/A | N/A | Range 0-100 | Average data quality score for processed records |
| Silver | SI_PIPELINE_EXECUTION_LOG | ERROR_COUNT | Calculated | N/A | N/A | Not null, Non-negative | Count of errors encountered |
| Silver | SI_PIPELINE_EXECUTION_LOG | WARNING_COUNT | Calculated | N/A | N/A | Not null, Non-negative | Count of warnings generated |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTION_TRIGGER | Generated | N/A | N/A | Not null | Set to trigger type ('SCHEDULED', 'MANUAL', 'EVENT') |
| Silver | SI_PIPELINE_EXECUTION_LOG | EXECUTED_BY | Generated | N/A | N/A | Not null | Set to user or system that triggered execution |
| Silver | SI_PIPELINE_EXECUTION_LOG | CONFIGURATION_USED | Generated | N/A | N/A | Optional | JSON object with pipeline configuration |
| Silver | SI_PIPELINE_EXECUTION_LOG | ERROR_DETAILS | Generated | N/A | N/A | Optional | JSON object with error details |
| Silver | SI_PIPELINE_EXECUTION_LOG | PERFORMANCE_METRICS | Generated | N/A | N/A | Optional | JSON object with performance metrics |
| Silver | SI_PIPELINE_EXECUTION_LOG | LOAD_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_PIPELINE_EXECUTION_LOG | UPDATE_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |

## 3. New Critical DQ Checks Implementation (P1 Priority)

### 3.1 SI_MEETINGS → Section 2.8: Numeric Field Text Unit Cleaning (Critical P1)

#### 3.1.1 Problem Statement
Address "108 mins" error in DURATION_MINUTES field where numeric values contain text units that prevent proper casting to numeric data types.

#### 3.1.2 Implementation SQL
```sql
-- Clean text units from DURATION_MINUTES field
SELECT 
  MEETING_ID,
  DURATION_MINUTES as original_duration,
  TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) AS CLEAN_DURATION_MINUTES,
  CASE 
    WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NULL THEN 'CONVERSION_FAILED'
    ELSE 'CONVERSION_SUCCESS'
  END as conversion_status
FROM BRONZE.BZ_MEETINGS 
WHERE DURATION_MINUTES::STRING REGEXP '[^0-9.]';

-- Log invalid conversions to SI_AUDIT_LOG
INSERT INTO SILVER.SI_AUDIT_LOG (
  TABLE_NAME, 
  COLUMN_NAME, 
  RECORD_ID, 
  ERROR_TYPE, 
  ERROR_DESCRIPTION, 
  ORIGINAL_VALUE, 
  AUDIT_TIMESTAMP,
  OPERATION_TYPE,
  PROCESSED_BY,
  SOURCE_SYSTEM
)
SELECT 
  'SI_MEETINGS' as table_name,
  'DURATION_MINUTES' as column_name,
  MEETING_ID as record_id,
  'FORMAT_CONVERSION_FAILURE' as error_type,
  'Failed to convert duration with text units to numeric value' as error_description,
  DURATION_MINUTES::STRING as original_value,
  CURRENT_TIMESTAMP() as audit_timestamp,
  'VALIDATION' as operation_type,
  'SILVER_DQ_PROCESS' as processed_by,
  SOURCE_SYSTEM as source_system
FROM BRONZE.BZ_MEETINGS 
WHERE DURATION_MINUTES::STRING REGEXP '[^0-9.]'
AND TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NULL;
```

#### 3.1.3 Validation and Monitoring
```sql
-- Validation check for successful cleaning
SELECT 
  COUNT(*) as records_with_text_units,
  COUNT(CASE WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN 1 END) as successful_cleanings,
  COUNT(CASE WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NULL THEN 1 END) as failed_cleanings,
  ROUND((COUNT(CASE WHEN TRY_TO_NUMBER(REGEXP_REPLACE(DURATION_MINUTES::STRING, '[^0-9.]', '')) IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)), 2) as success_rate_percent
FROM BRONZE.BZ_MEETINGS 
WHERE DURATION_MINUTES::STRING REGEXP '[^0-9.]';
```

### 3.2 SI_LICENSES → Section 7.6: DD/MM/YYYY Date Format Conversion (Critical P1)

#### 3.2.1 Problem Statement
Address "27/08/2024" error in START_DATE and END_DATE fields where DD/MM/YYYY formatted dates need conversion to Snowflake-compatible format.

#### 3.2.2 Implementation SQL
```sql
-- Convert DD/MM/YYYY formatted dates to Snowflake-compatible format
SELECT 
  LICENSE_ID,
  START_DATE as original_start_date,
  TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') AS CLEAN_START_DATE,
  END_DATE as original_end_date,
  TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') AS CLEAN_END_DATE,
  CASE 
    WHEN TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NULL THEN 'START_DATE_CONVERSION_FAILED'
    WHEN TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NULL THEN 'END_DATE_CONVERSION_FAILED'
    ELSE 'CONVERSION_SUCCESS'
  END as conversion_status
FROM BRONZE.BZ_LICENSES 
WHERE START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
OR END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$';

-- Log invalid conversions to SI_AUDIT_LOG
INSERT INTO SILVER.SI_AUDIT_LOG (
  TABLE_NAME, 
  COLUMN_NAME, 
  RECORD_ID, 
  ERROR_TYPE, 
  ERROR_DESCRIPTION, 
  ORIGINAL_VALUE, 
  AUDIT_TIMESTAMP,
  OPERATION_TYPE,
  PROCESSED_BY,
  SOURCE_SYSTEM
)
SELECT 
  'SI_LICENSES' as table_name,
  'START_DATE' as column_name,
  LICENSE_ID as record_id,
  'FORMAT_CONVERSION_FAILURE' as error_type,
  'Failed to convert DD/MM/YYYY date format to Snowflake date' as error_description,
  START_DATE::STRING as original_value,
  CURRENT_TIMESTAMP() as audit_timestamp,
  'VALIDATION' as operation_type,
  'SILVER_DQ_PROCESS' as processed_by,
  SOURCE_SYSTEM as source_system
FROM BRONZE.BZ_LICENSES 
WHERE START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
AND TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NULL

UNION ALL

SELECT 
  'SI_LICENSES' as table_name,
  'END_DATE' as column_name,
  LICENSE_ID as record_id,
  'FORMAT_CONVERSION_FAILURE' as error_type,
  'Failed to convert DD/MM/YYYY date format to Snowflake date' as error_description,
  END_DATE::STRING as original_value,
  CURRENT_TIMESTAMP() as audit_timestamp,
  'VALIDATION' as operation_type,
  'SILVER_DQ_PROCESS' as processed_by,
  SOURCE_SYSTEM as source_system
FROM BRONZE.BZ_LICENSES 
WHERE END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
AND TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NULL;
```

#### 3.2.3 Validation and Monitoring
```sql
-- Validation check for successful date format conversion
SELECT 
  COUNT(*) as records_with_ddmmyyyy_format,
  COUNT(CASE WHEN TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 1 END) as successful_start_date_conversions,
  COUNT(CASE WHEN TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 1 END) as successful_end_date_conversions,
  COUNT(CASE WHEN TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NULL THEN 1 END) as failed_start_date_conversions,
  COUNT(CASE WHEN TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NULL THEN 1 END) as failed_end_date_conversions,
  ROUND((COUNT(CASE WHEN TRY_TO_DATE(START_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)), 2) as start_date_success_rate_percent,
  ROUND((COUNT(CASE WHEN TRY_TO_DATE(END_DATE::STRING, 'DD/MM/YYYY') IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)), 2) as end_date_success_rate_percent
FROM BRONZE.BZ_LICENSES 
WHERE START_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$'
OR END_DATE::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}$';
```

## 4. Enhanced Data Quality and Validation Framework

### 4.1 Enhanced Data Quality Score Calculation
The DATA_QUALITY_SCORE for each record is calculated based on the following enhanced criteria:
- **Completeness (30%)**: Percentage of non-null required fields
- **Validity (25%)**: Percentage of fields passing format validation
- **Format Conversion Compliance (25%)**: Percentage of fields passing new critical format conversion checks
- **Consistency (15%)**: Percentage of fields passing business rule validation
- **Referential Integrity (5%)**: Percentage of foreign key relationships validated

### 4.2 Enhanced Validation Status Assignment
- **PASSED**: All validation rules passed, DATA_QUALITY_SCORE >= 90, no format conversion errors
- **WARNING**: Minor validation failures or format conversion warnings, DATA_QUALITY_SCORE 70-89
- **FAILED**: Critical validation failures or format conversion errors, DATA_QUALITY_SCORE < 70

### 4.3 Enhanced Error Handling Strategy
- Records failing format conversion validation are logged to SI_AUDIT_LOG table
- Specific error codes for numeric text unit cleaning and DD/MM/YYYY format issues
- Automated retry mechanisms for format conversion failures
- Format-specific remediation procedures documented in audit logs

## 5. Implementation Priority and Rollout Strategy (Updated)

### 5.1 Priority Levels (Updated with New Critical Checks)
1. **Critical (P1)**: 
   - **NEW**: Numeric field text unit cleaning for SI_MEETINGS ("108 mins" error)
   - **NEW**: DD/MM/YYYY date format conversion for SI_LICENSES ("27/08/2024" error)
   - Timestamp format validation for SI_MEETINGS and SI_PARTICIPANTS
   - Null checks, referential integrity, business logic constraints
2. **High (P2)**: Data format validation, range checks, uniqueness constraints, timezone conversion validation
3. **Medium (P3)**: Business rule calculations, cross-table consistency, format remediation strategies
4. **Low (P4)**: Performance monitoring, data quality scoring

### 5.2 Rollout Phases (Updated)
1. **Phase 1**: Implement new critical DQ checks for SI_MEETINGS (numeric field cleaning) and SI_LICENSES (DD/MM/YYYY conversion)
2. **Phase 2**: Deploy comprehensive error logging to SI_AUDIT_LOG for new checks
3. **Phase 3**: Implement monitoring and alerting for format conversion compliance
4. **Phase 4**: Re-run DBT Silver job after adding these fixes
5. **Phase 5**: Validate model performance and error reduction

### 5.3 Success Metrics (Updated)
- Format conversion success rate > 98% for both new critical checks
- Model failure rate due to "108 mins" and "27/08/2024" errors < 0.1%
- Data quality score improvement > 15 points
- Processing time impact < 10% increase
- Audit log completeness > 99% for format conversion failures

## 6. Business Rule Implementation (Enhanced)

### 6.1 Meeting Classification Rules (Enhanced with Format Validation)
- Meetings with DURATION_MINUTES < 5 are classified as "Brief" (after numeric cleaning)
- Meetings with 2+ participants are classified as "Collaborative"
- Classification logic validates format conversion compliance before processing
- Meetings with format conversion errors are excluded from classification until remediated

### 6.2 License Validity Rules (Enhanced with Date Format Validation)
- START_DATE must be before or equal to END_DATE (after DD/MM/YYYY conversion)
- Active licenses must have END_DATE > CURRENT_DATE() (after conversion)
- Expired licenses are flagged but not excluded from Silver layer
- Date format conversion must succeed before applying business rules

### 6.3 Format Conversion Business Rules
- All numeric fields with text units must be cleaned before processing
- All DD/MM/YYYY date formats must be converted to standard Snowflake date format
- Failed format conversions are logged to SI_AUDIT_LOG as 'FORMAT_CONVERSION_FAILURE'
- Format conversion errors trigger Critical (P1) data quality alerts

## 7. Performance and Optimization Considerations (Enhanced)

### 7.1 Incremental Processing with Format Validation
- Use UPDATE_TIMESTAMP from Bronze layer to identify changed records
- Implement CDC (Change Data Capture) patterns for efficient processing
- Cache format conversion validation results to improve processing speed
- Partition Silver tables by LOAD_DATE for optimal query performance

### 7.2 Data Freshness Monitoring (Enhanced)
- Monitor LOAD_TIMESTAMP differences between Bronze and Silver layers
- Set up alerts for data freshness SLA violations
- Track processing latency in SI_PIPELINE_EXECUTION_LOG
- Monitor format conversion success rates and processing time impact

### 7.3 Error Recovery Mechanisms (Enhanced)
- Implement retry logic for transient format conversion failures
- Maintain error resolution workflows with format-specific remediation steps
- Provide data steward interfaces for format conversion error correction
- Automated format standardization for known patterns

## 8. Compliance and Security (Enhanced)

### 8.1 PII Data Handling
- USER_NAME and EMAIL fields are identified as PII
- MEETING_TOPIC may contain PII and requires sanitization
- Implement data masking for non-production environments
- Format conversion data is not considered PII but requires audit logging

### 8.2 Data Retention (Enhanced)
- Silver layer data retention follows Bronze layer policies
- Error data is retained for 2 years for audit purposes
- Pipeline execution logs are retained for 1 year
- Format conversion audit logs are retained for 18 months

### 8.3 Access Control (Enhanced)
- Implement role-based access control (RBAC) for Silver layer tables
- Separate read/write permissions for different user groups
- Audit all data access through Snowflake's built-in features
- Monitor access to format conversion audit logs

## 9. Post-Implementation Actions

### 9.1 DBT Silver Job Re-run
- **CRITICAL**: Re-run the DBT Silver job after adding these fixes
- Validate that "108 mins" errors are resolved in SI_MEETINGS processing
- Validate that "27/08/2024" errors are resolved in SI_LICENSES processing
- Monitor job execution time and success rates

### 9.2 Model Validation
- Test all downstream models that depend on SI_MEETINGS.DURATION_MINUTES
- Test all downstream models that depend on SI_LICENSES.START_DATE and END_DATE
- Validate that model failures due to format issues are eliminated

### 9.3 Monitoring and Alerting
- Set up real-time alerts for format conversion failures
- Monitor SI_AUDIT_LOG for 'FORMAT_CONVERSION_FAILURE' entries
- Create dashboards for format conversion success rates
- Implement automated notifications for Critical (P1) format issues

---

**Note**: This enhanced data mapping addresses the specific format conversion issues identified in the DQ recommendations while maintaining all existing functionality. The two new Critical (P1) DQ checks for SI_MEETINGS (numeric field text unit cleaning) and SI_LICENSES (DD/MM/YYYY date format conversion) include comprehensive error logging to SI_AUDIT_LOG and are designed to resolve the "108 mins" and "27/08/2024" errors that were causing model failures. The implementation provides robust error handling, format standardization, and monitoring capabilities to ensure reliable data processing and model performance.