_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Silver Layer in Zoom Platform Analytics System Medallion architecture with enhanced timestamp format validation
## *Version*: 2 
## *Updated on*: 
## *Changes*: Added enhanced timestamp format validation for SI_MEETINGS (EST timezone) and SI_PARTICIPANTS (MM/DD/YYYY HH:MM format) to address failing models
## *Reason*: Address failing models due to timestamp format issues - SI_MEETINGS with 'EST' timezone and SI_PARTICIPANTS with MM/DD/YYYY HH:MM format
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following Medallion architecture principles. The mapping incorporates necessary cleansing, validations, and business rules at the attribute level to ensure data quality, consistency, and usability across the organization.

The Silver Layer serves as the "single source of truth" by applying data quality checks, standardization, and business rule validations to the raw data from the Bronze Layer. All transformations are designed to be compatible with Snowflake and support advanced analytics and reporting needs.

**Version 2 Updates**: This version includes enhanced timestamp format validation specifically addressing failing models in SI_MEETINGS (EST timezone format issues) and SI_PARTICIPANTS (MM/DD/YYYY HH:MM format issues) to ensure robust data processing and model reliability.

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

### 2.2 SI_MEETINGS Table Mapping (Enhanced with EST Timezone Validation)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_MEETINGS | MEETING_ID | Bronze | BZ_MEETINGS | MEETING_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_MEETINGS | HOST_ID | Bronze | BZ_MEETINGS | HOST_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_MEETINGS | MEETING_TOPIC | Bronze | BZ_MEETINGS | MEETING_TOPIC | Length <= 500 | TRIM() and sanitize for PII |
| Silver | SI_MEETINGS | START_TIME | Bronze | BZ_MEETINGS | START_TIME | Not null, Valid timestamp, EST format validation | **Enhanced**: Validate EST timezone format using REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'), Convert EST to UTC using CONVERT_TIMEZONE('America/New_York', 'UTC', TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS')) |
| Silver | SI_MEETINGS | END_TIME | Bronze | BZ_MEETINGS | END_TIME | Not null, Must be > START_TIME, EST format validation | **Enhanced**: Validate EST timezone format using REGEXP_LIKE(END_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$'), Convert EST to UTC with logic validation |
| Silver | SI_MEETINGS | DURATION_MINUTES | Bronze | BZ_MEETINGS | DURATION_MINUTES | Not null, Range 0-1440, Must match calculated duration | Validate against DATEDIFF('minute', converted_START_TIME, converted_END_TIME) after timezone conversion |
| Silver | SI_MEETINGS | LOAD_TIMESTAMP | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_MEETINGS | UPDATE_TIMESTAMP | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_MEETINGS | SOURCE_SYSTEM | Bronze | BZ_MEETINGS | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_MEETINGS | LOAD_DATE | Bronze | BZ_MEETINGS | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_MEETINGS | UPDATE_DATE | Bronze | BZ_MEETINGS | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_MEETINGS | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness, validation results, and timestamp format compliance |
| Silver | SI_MEETINGS | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results including EST timezone format validation |

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

### 2.7 SI_LICENSES Table Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_LICENSES | LICENSE_ID | Bronze | BZ_LICENSES | LICENSE_ID | Not null, Unique | Direct copy with uniqueness validation |
| Silver | SI_LICENSES | LICENSE_TYPE | Bronze | BZ_LICENSES | LICENSE_TYPE | Not null, Length <= 100 | UPPER(TRIM()) for standardized categories |
| Silver | SI_LICENSES | ASSIGNED_TO_USER_ID | Bronze | BZ_LICENSES | ASSIGNED_TO_USER_ID | Not null, Must exist in SI_USERS | Direct copy with referential integrity check |
| Silver | SI_LICENSES | START_DATE | Bronze | BZ_LICENSES | START_DATE | Not null, Must be <= END_DATE | Validate chronological order |
| Silver | SI_LICENSES | END_DATE | Bronze | BZ_LICENSES | END_DATE | Not null, Must be >= START_DATE | Validate chronological order |
| Silver | SI_LICENSES | LOAD_TIMESTAMP | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null, Valid timestamp | Direct copy |
| Silver | SI_LICENSES | UPDATE_TIMESTAMP | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Valid timestamp | Direct copy |
| Silver | SI_LICENSES | SOURCE_SYSTEM | Bronze | BZ_LICENSES | SOURCE_SYSTEM | Not null | Direct copy |
| Silver | SI_LICENSES | LOAD_DATE | Bronze | BZ_LICENSES | LOAD_TIMESTAMP | Not null | DATE(LOAD_TIMESTAMP) |
| Silver | SI_LICENSES | UPDATE_DATE | Bronze | BZ_LICENSES | UPDATE_TIMESTAMP | Valid date | DATE(UPDATE_TIMESTAMP) |
| Silver | SI_LICENSES | DATA_QUALITY_SCORE | Calculated | N/A | N/A | Range 0-100 | Calculate based on completeness and validation results |
| Silver | SI_LICENSES | VALIDATION_STATUS | Calculated | N/A | N/A | Must be in ('PASSED', 'FAILED', 'WARNING') | Set based on validation rule results |

### 2.8 SI_DATA_QUALITY_ERRORS Table Mapping (Error Data Table)

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|--------------------|
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_ID | Generated | N/A | N/A | Not null, Unique | Generate UUID for each error record |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_TABLE | Calculated | N/A | N/A | Not null | Set to Bronze table name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_RECORD_KEY | Calculated | N/A | N/A | Not null | Set to primary key value of failed record |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TYPE | Calculated | N/A | N/A | Not null | Set based on validation failure type (including 'TIMESTAMP_FORMAT_ERROR') |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_CATEGORY | Calculated | N/A | N/A | Not null | Categorize as 'VALIDATION', 'TRANSFORMATION', 'BUSINESS_RULE', 'TIMESTAMP_FORMAT' |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_DESCRIPTION | Calculated | N/A | N/A | Not null | Detailed description of validation failure including timestamp format issues |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_COLUMN | Calculated | N/A | N/A | Not null | Column name where error occurred |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_VALUE | Calculated | N/A | N/A | Not null | Actual value that failed validation |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_SEVERITY | Calculated | N/A | N/A | Must be in ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') | Set based on business impact |
| Silver | SI_DATA_QUALITY_ERRORS | ERROR_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() when error detected |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_STATUS | Generated | N/A | N/A | Default 'OPEN' | Set to 'OPEN' initially |
| Silver | SI_DATA_QUALITY_ERRORS | RESOLUTION_NOTES | Generated | N/A | N/A | Optional | Initially null |
| Silver | SI_DATA_QUALITY_ERRORS | LOAD_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_DATA_QUALITY_ERRORS | UPDATE_TIMESTAMP | Generated | N/A | N/A | Not null | CURRENT_TIMESTAMP() |
| Silver | SI_DATA_QUALITY_ERRORS | SOURCE_SYSTEM | Calculated | N/A | N/A | Not null | Set to source system of failed record |

### 2.9 SI_PIPELINE_EXECUTION_LOG Table Mapping (Audit Table)

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

## 3. Enhanced Timestamp Format Validation Framework

### 3.1 EST Timezone Format Validation for SI_MEETINGS

#### 3.1.1 Format Detection and Validation
```sql
-- Validate EST timezone format
CASE 
  WHEN START_TIME::STRING LIKE '%EST%' THEN 
    CASE 
      WHEN REGEXP_LIKE(START_TIME::STRING, '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}(\\.\\d{3})? EST$') THEN 'VALID_EST_FORMAT'
      ELSE 'INVALID_EST_FORMAT'
    END
  ELSE 'STANDARD_FORMAT'
END as timestamp_format_status
```

#### 3.1.2 EST to UTC Conversion
```sql
-- Convert EST timestamps to UTC
CASE 
  WHEN START_TIME::STRING LIKE '%EST%' THEN 
    CONVERT_TIMEZONE('America/New_York', 'UTC', 
      TRY_TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
  ELSE START_TIME
END as standardized_start_time
```

#### 3.1.3 EST Format Error Handling
- Records with invalid EST format are routed to SI_DATA_QUALITY_ERRORS
- ERROR_TYPE set to 'TIMESTAMP_FORMAT_ERROR'
- ERROR_CATEGORY set to 'TIMESTAMP_FORMAT'
- ERROR_DESCRIPTION includes specific EST format validation failure details

### 3.2 MM/DD/YYYY HH:MM Format Validation for SI_PARTICIPANTS

#### 3.2.1 Format Detection and Validation
```sql
-- Validate MM/DD/YYYY HH:MM format
CASE 
  WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
    CASE 
      WHEN TRY_TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI') IS NOT NULL THEN 'VALID_MMDDYYYY_FORMAT'
      ELSE 'INVALID_MMDDYYYY_FORMAT'
    END
  ELSE 'STANDARD_FORMAT'
END as timestamp_format_status
```

#### 3.2.2 MM/DD/YYYY Format Conversion
```sql
-- Convert MM/DD/YYYY HH:MM to standard timestamp
CASE 
  WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
    TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
  ELSE JOIN_TIME
END as standardized_join_time
```

#### 3.2.3 MM/DD/YYYY Format Error Handling
- Records with invalid MM/DD/YYYY format are routed to SI_DATA_QUALITY_ERRORS
- ERROR_TYPE set to 'TIMESTAMP_FORMAT_ERROR'
- ERROR_CATEGORY set to 'TIMESTAMP_FORMAT'
- ERROR_DESCRIPTION includes specific MM/DD/YYYY format validation failure details

### 3.3 Cross-Format Timestamp Consistency Validation

#### 3.3.1 Mixed Format Detection
```sql
-- Detect mixed timestamp formats within records
SELECT 
  PARTICIPANT_ID,
  CASE 
    WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 'MM/DD/YYYY'
    WHEN JOIN_TIME::STRING LIKE '%EST%' THEN 'EST_FORMAT'
    ELSE 'STANDARD'
  END as join_time_format,
  CASE 
    WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 'MM/DD/YYYY'
    WHEN LEAVE_TIME::STRING LIKE '%EST%' THEN 'EST_FORMAT'
    ELSE 'STANDARD'
  END as leave_time_format
FROM BRONZE.BZ_PARTICIPANTS
```

#### 3.3.2 Format Consistency Validation
- Validate that JOIN_TIME and LEAVE_TIME use consistent formats within the same record
- Flag inconsistent format usage as data quality warnings
- Provide format standardization recommendations

## 4. Enhanced Data Quality and Validation Framework

### 4.1 Enhanced Data Quality Score Calculation
The DATA_QUALITY_SCORE for each record is calculated based on the following enhanced criteria:
- **Completeness (35%)**: Percentage of non-null required fields
- **Validity (25%)**: Percentage of fields passing format validation
- **Timestamp Format Compliance (20%)**: Percentage of timestamp fields passing format validation
- **Consistency (15%)**: Percentage of fields passing business rule validation
- **Referential Integrity (5%)**: Percentage of foreign key relationships validated

### 4.2 Enhanced Validation Status Assignment
- **PASSED**: All validation rules passed, DATA_QUALITY_SCORE >= 90, no timestamp format errors
- **WARNING**: Minor validation failures or timestamp format warnings, DATA_QUALITY_SCORE 70-89
- **FAILED**: Critical validation failures or timestamp format errors, DATA_QUALITY_SCORE < 70

### 4.3 Enhanced Error Handling Strategy
- Records failing timestamp format validation are routed to SI_DATA_QUALITY_ERRORS table
- Specific error codes for EST timezone and MM/DD/YYYY format issues
- Automated retry mechanisms for timestamp format conversion failures
- Format-specific remediation procedures documented in error resolution notes

## 5. Timestamp Format Remediation Strategies

### 5.1 EST Timezone Remediation for SI_MEETINGS

#### 5.1.1 Remediation View Creation
```sql
CREATE OR REPLACE VIEW SILVER.V_SI_MEETINGS_REMEDIATED AS
SELECT 
  MEETING_ID,
  HOST_ID,
  CASE 
    WHEN START_TIME::STRING LIKE '%EST%' THEN 
      CONVERT_TIMEZONE('America/New_York', 'UTC', 
        TO_TIMESTAMP(REPLACE(START_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
    ELSE START_TIME
  END as START_TIME,
  CASE 
    WHEN END_TIME::STRING LIKE '%EST%' THEN 
      CONVERT_TIMEZONE('America/New_York', 'UTC', 
        TO_TIMESTAMP(REPLACE(END_TIME::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS'))
    ELSE END_TIME
  END as END_TIME,
  DURATION_MINUTES,
  LOAD_TIMESTAMP,
  SOURCE_SYSTEM,
  VALIDATION_STATUS
FROM SILVER.SI_MEETINGS;
```

### 5.2 MM/DD/YYYY Format Remediation for SI_PARTICIPANTS

#### 5.2.1 Remediation View Creation
```sql
CREATE OR REPLACE VIEW SILVER.V_SI_PARTICIPANTS_REMEDIATED AS
SELECT 
  PARTICIPANT_ID,
  MEETING_ID,
  USER_ID,
  CASE 
    WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
      TO_TIMESTAMP(JOIN_TIME::STRING, 'MM/DD/YYYY HH24:MI')
    ELSE JOIN_TIME
  END as JOIN_TIME,
  CASE 
    WHEN LEAVE_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2}$' THEN 
      TO_TIMESTAMP(LEAVE_TIME::STRING, 'MM/DD/YYYY HH24:MI')
    ELSE LEAVE_TIME
  END as LEAVE_TIME,
  LOAD_TIMESTAMP,
  SOURCE_SYSTEM,
  VALIDATION_STATUS
FROM SILVER.SI_PARTICIPANTS;
```

### 5.3 Comprehensive Timestamp Format Monitoring

#### 5.3.1 Format Distribution Monitoring
```sql
-- Monitor timestamp format distribution across Silver layer
SELECT 
  'SI_MEETINGS' as table_name,
  'START_TIME' as column_name,
  CASE 
    WHEN START_TIME::STRING LIKE '%EST%' THEN 'EST_FORMAT'
    WHEN START_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' THEN 'MM_DD_YYYY_FORMAT'
    WHEN START_TIME::STRING REGEXP '^\\d{4}-\\d{2}-\\d{2}' THEN 'STANDARD_FORMAT'
    ELSE 'OTHER_FORMAT'
  END as format_type,
  COUNT(*) as record_count,
  ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 2) as percentage
FROM SILVER.SI_MEETINGS 
WHERE START_TIME IS NOT NULL
GROUP BY format_type

UNION ALL

SELECT 
  'SI_PARTICIPANTS',
  'JOIN_TIME',
  CASE 
    WHEN JOIN_TIME::STRING LIKE '%EST%' THEN 'EST_FORMAT'
    WHEN JOIN_TIME::STRING REGEXP '^\\d{1,2}/\\d{1,2}/\\d{4}' THEN 'MM_DD_YYYY_FORMAT'
    WHEN JOIN_TIME::STRING REGEXP '^\\d{4}-\\d{2}-\\d{2}' THEN 'STANDARD_FORMAT'
    ELSE 'OTHER_FORMAT'
  END as format_type,
  COUNT(*),
  ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 2)
FROM SILVER.SI_PARTICIPANTS 
WHERE JOIN_TIME IS NOT NULL
GROUP BY format_type;
```

## 6. Business Rule Implementation (Enhanced)

### 6.1 Meeting Classification Rules (Enhanced with Timestamp Validation)
- Meetings with DURATION_MINUTES < 5 are classified as "Brief"
- Meetings with 2+ participants are classified as "Collaborative"
- Classification logic validates timestamp format compliance before processing
- Meetings with timestamp format errors are excluded from classification until remediated

### 6.2 Plan Type Standardization
- All PLAN_TYPE values are standardized to: 'Free', 'Basic', 'Pro', 'Enterprise'
- Invalid or null values default to 'Free'
- Case-insensitive matching is applied during transformation

### 6.3 Support Ticket Status Validation
- RESOLUTION_STATUS values are standardized to: 'Open', 'In Progress', 'Resolved', 'Closed'
- Invalid status values are flagged as data quality errors

### 6.4 License Validity Rules
- START_DATE must be before or equal to END_DATE
- Active licenses must have END_DATE > CURRENT_DATE()
- Expired licenses are flagged but not excluded from Silver layer

### 6.5 Timestamp Format Business Rules
- All timestamp fields must be converted to UTC for consistency
- EST timezone timestamps are converted using America/New_York timezone
- MM/DD/YYYY format timestamps are converted to standard YYYY-MM-DD HH24:MI:SS format
- Mixed format usage within records triggers data quality warnings

## 7. Performance and Optimization Considerations (Enhanced)

### 7.1 Incremental Processing with Timestamp Validation
- Use UPDATE_TIMESTAMP from Bronze layer to identify changed records
- Implement CDC (Change Data Capture) patterns for efficient processing
- Partition Silver tables by LOAD_DATE for optimal query performance
- Cache timestamp format validation results to improve processing speed

### 7.2 Data Freshness Monitoring
- Monitor LOAD_TIMESTAMP differences between Bronze and Silver layers
- Set up alerts for data freshness SLA violations
- Track processing latency in SI_PIPELINE_EXECUTION_LOG
- Monitor timestamp format conversion success rates

### 7.3 Error Recovery Mechanisms (Enhanced)
- Implement retry logic for transient timestamp format conversion failures
- Maintain error resolution workflows with format-specific remediation steps
- Provide data steward interfaces for timestamp format error correction
- Automated format standardization for known patterns

## 8. Compliance and Security (Enhanced)

### 8.1 PII Data Handling
- USER_NAME and EMAIL fields are identified as PII
- MEETING_TOPIC may contain PII and requires sanitization
- Implement data masking for non-production environments
- Timestamp data is not considered PII but requires format standardization

### 8.2 Data Retention (Enhanced)
- Silver layer data retention follows Bronze layer policies
- Error data is retained for 2 years for audit purposes
- Pipeline execution logs are retained for 1 year
- Timestamp format validation logs are retained for 6 months

### 8.3 Access Control
- Implement role-based access control (RBAC) for Silver layer tables
- Separate read/write permissions for different user groups
- Audit all data access through Snowflake's built-in features
- Monitor access to timestamp format remediation views

## 9. Implementation Priority and Rollout Strategy

### 9.1 Priority Levels (Updated)
1. **Critical (P1)**: Timestamp format validation for SI_MEETINGS and SI_PARTICIPANTS, null checks, referential integrity
2. **High (P2)**: Data format validation, range checks, uniqueness constraints, timezone conversion validation
3. **Medium (P3)**: Business rule calculations, cross-table consistency, format remediation strategies
4. **Low (P4)**: Performance monitoring, data quality scoring

### 9.2 Rollout Phases
1. **Phase 1**: Implement timestamp format validation for SI_MEETINGS (EST timezone)
2. **Phase 2**: Implement timestamp format validation for SI_PARTICIPANTS (MM/DD/YYYY HH:MM)
3. **Phase 3**: Deploy comprehensive error handling and remediation views
4. **Phase 4**: Implement monitoring and alerting for timestamp format compliance

### 9.3 Success Metrics
- Timestamp format validation success rate > 95%
- Model failure rate due to timestamp issues < 1%
- Data quality score improvement > 10 points
- Processing time impact < 15% increase

---

**Note**: This enhanced data mapping addresses the specific timestamp format issues identified in SI_MEETINGS (EST timezone) and SI_PARTICIPANTS (MM/DD/YYYY HH:MM format) while maintaining all existing functionality. The implementation provides robust error handling, format standardization, and monitoring capabilities to ensure reliable data processing and model performance.